require "./proxy"
require "./stub"

module Spectator::Mocks
  # Wrapper for stubbable objects to use in the "allow" syntax.
  struct Allow(T)
    # Creates the wrapper.
    # Takes a *proxy* from the stubbable object.
    def initialize(@proxy : Proxy(T))
    end

    # DSL method to apply a stub.
    def to(stub : Stub)
      @proxy.add_stub(stub)
    end
  end
end
