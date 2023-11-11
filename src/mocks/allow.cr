require "./proxy"
require "./stub"

module Mocks
  # Wrapper for stubbable objects to use in the "allow" syntax.
  struct Allow(T)
    # Creates the wrapper.
    # Takes a *proxy* from the stubbable object.
    def initialize(@proxy : Proxy(T))
    end

    # DSL method to apply a stub.
    #
    # ```
    # allow(dbl).to receive(:foo)
    # ```
    def to(stub : Stub)
      @proxy.add_stub(stub)
    end

    # DSL method to apply a collection of stubs.
    #
    # ```
    # allow(dbl).to receive(answer: 42, foo: "bar")
    # ```
    def to(collection : StubCollection)
      collection.apply(@proxy)
    end
  end
end
