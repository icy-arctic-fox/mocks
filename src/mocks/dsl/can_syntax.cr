require "../stub"
require "../stubbable"
require "../stub_collection"

module Mocks::DSL
  module CanSyntax
    # Prevent `can` from being stubbed.
    {% Stubbable::UNSAFE_METHODS << :can %}

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
