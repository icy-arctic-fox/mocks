require "./nil_stub"
require "./receive_expectation_modifiers"
require "./stub"
require "./stubbable"

module Spectator::Mocks
  # Expectation that checks if a stubbable object received a method call the specified number of times.
  class ReceiveCountExpectation(T)
    include ReceiveExpectationModifiers

    # Creates an expectation with a stub.
    # A stub is used to pattern match calls made to an object.
    def initialize(@stub : T, @count : Range(Int32?, Int32?))
      {% raise "Type argument T must be a Stub" unless T < Stub %}
    end

    # Creates an expectation that will match all calls with a specific method name.
    def self.new(method_name : Symbol, count : Int = 1)
      stub = NilStub.new(method_name)
      new(stub, count..count)
    end

    # Creates an expectation that will match all calls with a specific method name.
    def self.new(method_name : Symbol, count : Range(Int32?, Int32?))
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
      "Expected:   #{actual_value.inspect}\nto receive: #{@stub} #{humanize_count}"
    end

    # Error message displayed when the expectation fails in the negated case.
    def negative_failure_message(actual_value)
      "Expected:       #{actual_value.inspect}\nnot to receive: #{@stub} #{humanize_count}"
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
      {{@type.name(generic_args: false)}}.new(yield @stub)
    end
  end
end
