require "../allow"

module Spectator::Mocks
  module DSL
    # Wrapper for a stubbable object.
    # Begins the fluent language for defining stubs for an object.
    #
    # The *stubbable* argument must be a mock or double (something that can be stubbed).
    # ```
    # allow(dbl).to receive(:foo)
    # ```
    def allow(stubbable : Stubbable)
      Allow.new(stubbable.__mocks)
    end
  end
end
