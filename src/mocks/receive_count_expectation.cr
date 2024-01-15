require "./nil_stub"
require "./receive_expectation_modifiers"
require "./stub"
require "./stubbable"

module Mocks
  alias Count = Range(Int32?, Int32?)
  alias CountUnion = Range(Int32, Int32) | Range(Int32?, Int32) | Range(Int32, Int32?) | Range(Int32?, Int32?)

  # Expectation that checks if a stubbable object received a method call the specified number of times.
  class ReceiveCountExpectation(T)
    include ReceiveExpectationModifiers

    # Creates an expectation with a stub.
    # A stub is used to pattern match calls made to an object.
    def initialize(@stub : T, @count : Count)
      {% raise "Type argument T must be a Stub" unless T < Stub %}
    end

    # Creates an expectation with a stub.
    # A stub is used to pattern match calls made to an object.
    def initialize(@stub : T, count : CountUnion)
      {% raise "Type argument T must be a Stub" unless T < Stub %}
      @count = Count.new(count.begin.as(Int32?), count.end.as(Int32?), count.exclusive?)
    end

    # Creates an expectation that will match all calls with a specific method name.
    def self.new(method_name : Symbol, count : Int = 1)
      stub = NilStub.new(method_name)
      new(stub, count..count)
    end

    # Creates an expectation that will match all calls with a specific method name.
    def self.new(method_name : Symbol, count : CountUnion)
      stub = NilStub.new(method_name)
      new(stub, count)
    end

    # Checks if a stubbable object received a call defined by this expectation.
    def match(actual_value : Stubbable)
      proxy = actual_value.__mocks
      count = proxy.calls.count &.match?(@stub)
      count.in?(@count)
    end

    # Fallback method that produces a compiler error message when attempting to check a non-stubbable object.
    def match(actual_value)
      {% raise "The `have_received` expectation must be used on stubbable types (mocks and doubles)" %}
    end

    # Error message displayed when the expectation fails.
    def failure_message(actual_value)
      String.build do |message|
        message << "  Expected: " << actual_value.inspect << '\n'
        message << "to receive: " << @stub << ' ' << humanize_count << '\n'
        message << "       got: "
        call_list_message(actual_value, message)
      end
    end

    # Error message displayed when the expectation fails in the negated case.
    def negative_failure_message(actual_value)
      String.build do |message|
        message << "      Expected: " << actual_value.inspect << '\n'
        message << "not to receive: " << @stub << ' ' << humanize_count << '\n'
        message << "           got: "
        call_list_message(actual_value, message)
      end
    end

    private def call_list_message(actual_value, message)
      calls = actual_value.__mocks.calls
      relevant_calls = calls.select { |call| call.method_name == @stub.method_name }

      if calls.empty?
        message << "no calls"
      elsif relevant_calls.empty?
        message << "no calls to #" << @stub.method_name
      else
        matching_calls = relevant_calls.map &.match?(@stub)
        message << matching_calls.count(&.itself) << " matching calls\n\n"
        Call.build_call_list(relevant_calls, message) do |call, i|
          matching_calls[i]
        end
      end
    end

    # Returns itself - this is for the fluent syntax.
    # ```
    # double.should have_received(:some_method).exactly(1).time
    # double.should have_received(:some_method).at_least(1).time
    # double.should have_received(:some_method).at_most(1).time
    # ```
    def time
      self
    end

    # Returns itself - this is for the fluent syntax.
    # ```
    # double.should have_received(:some_method).exactly(3).times
    # double.should have_received(:some_method).at_least(3).times
    # double.should have_received(:some_method).at_most(3).times
    # ```
    def times
      self
    end

    # Produces a string explaining the desired call count.
    private def humanize_count
      b = @count.begin
      e = @count.end
      if b && e
        if b == e
          "#{b} times"
        else
          "#{b} to #{e} times #{@count.exclusive? ? "(exclusive)" : "(inclusive)"}"
        end
      elsif b
        "at least #{b} times"
      elsif e
        "at most #{e} times"
      else
        "any number of times"
      end
    end

    private def with_stub(& : Stub -> Stub)
      stub = yield @stub
      {{@type.name(generic_args: false)}}.new(stub, @count)
    end
  end
end
