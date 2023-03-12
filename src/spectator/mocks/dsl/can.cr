require "../stub"
require "../stubbable"

module Spectator::Mocks
  module Stubbable
    # Prevent `can` from being stubbed.
    {% UNSAFE_METHODS << :can %}

    # Applies a stub to an object.
    # Begins the fluent language for defining stubs for an object.
    #
    # ```
    # dbl.can receive(:foo)
    # ```
    def can(stub : Stub) : Nil
      __mocks.add_stub(stub)
    end

    # Applies multiple stubs to an object.
    #
    # ```
    # dbl.can receive(answer: 42, foo: "bar")
    # ```
    def can(collection : StubCollection) : Nil
      collection.apply(__mocks)
    end
  end
end
