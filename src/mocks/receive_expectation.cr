require "./nil_stub"
require "./receive_count_expectation"
require "./receive_count_expectation_modifiers"
require "./receive_expectation_modifiers"
require "./stub"
require "./stubbable"

module Mocks
  # Expectation that checks if a stubbable object received a method call.
  class ReceiveExpectation(T)
    include ReceiveCountExpectationModifiers
    include ReceiveExpectationModifiers

    # Creates an expectation with a stub.
    # A stub is used to pattern match calls made to an object.
    def initialize(@stub : T)
      {% raise "Type argument T must be a Stub" unless T < Stub %}
    end

    # Creates an expectation that will match all calls with a specific method name.
    def self.new(method_name : Symbol)
      stub = NilStub.new(method_name)
      new(stub)
    end

    # Checks if a stubbable object received a call defined by this expectation.
    def match(actual_value : Stubbable)
      proxy = actual_value.__mocks
      proxy.calls.any? &.match?(@stub)
    end

    # Fallback method that produces a compiler error message when attempting to check a non-stubbable object.
    def match(actual_value)
      {% raise "The `have_received` expectation must be used on stubbable types (mocks and doubles)" %}
    end

    # Error message displayed when the expectation fails.
    def failure_message(actual_value)
      String.build do |message|
        message << "  Expected: " << actual_value.inspect << '\n'
        message << "to receive: " << @stub << '\n'
        message << "       got: "

        calls = actual_value.__mocks.calls
        relevant_calls = calls.select { |call| call.method_name == @stub.method_name }
        if calls.empty?
          message << "no calls"
        elsif relevant_calls.empty?
          message << calls.size << " unrelated call(s)\n\n"
          Call.build_call_list(calls, message)
        else
          message << relevant_calls.size << " call(s)\n\n"
          Call.build_call_list(relevant_calls, message)
        end
      end
    end

    # Error message displayed when the expectation fails in the negated case.
    def negative_failure_message(actual_value)
      String.build do |message|
        message << "      Expected: " << actual_value.inspect << '\n'
        message << "not to receive: " << @stub << '\n'

        calls = actual_value.__mocks.calls.select &.match?(@stub)
        message << "           got: " << calls.size << " call(s)\n\n"

        Call.build_call_list(calls, message)
      end
    end

    private def with_stub(& : Stub -> Stub)
      {{@type.name(generic_args: false)}}.new(yield @stub)
    end

    private def with_count(count)
      ReceiveCountExpectation.new(@stub, count)
    end
  end
end
