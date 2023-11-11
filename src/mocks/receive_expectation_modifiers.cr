module Mocks
  module ReceiveExpectationModifiers
    # Modifies the expectation to check for the specified arguments.
    def with(*args, **kwargs)
      with_stub &.with(*args, **kwargs)
    end

    # Returns a new expectation with a modified stub.
    private abstract def with_stub(& : Stub -> Stub)
  end
end
