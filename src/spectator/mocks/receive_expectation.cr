require "./nil_stub"
require "./receive_expectation_modifiers"
require "./stub"
require "./stubbable"

module Spectator::Mocks
  # Expectation that checks if a stubbable object received a method call.
  class ReceiveExpectation(T)
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
      "Expected:   #{actual_value.inspect}\nto receive: #{@stub}"
    end

    # Error message displayed when the expectation fails in the negated case.
    def negative_failure_message(actual_value)
      "Expected:       #{actual_value.inspect}\nnot to receive: #{@stub}"
    end

    private def with_stub(& : Stub -> Stub)
      {{@type.name(generic_args: false)}}.new(yield @stub)
    end
  end
end
