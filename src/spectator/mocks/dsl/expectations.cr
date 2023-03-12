require "../receive_expectation"

module Spectator::Mocks::DSL
  # Expectation DSL methods for the Spec framework.
  module Expectations
    # Creates an expectation that a method was called on an object.
    #
    # The *method* is the name of the method to expect was called.
    #
    # This is also the start of a fluent interface for defining stubs.
    # See: `ReceiveExpectation`
    #
    # Should syntax:
    # ```
    # dbl.should have_received(:some_method)
    # dbl.should have_received(:some_method).with(42)
    # ```
    def have_received(method : Symbol)
      ReceiveExpectation.new(method)
    end
  end
end
