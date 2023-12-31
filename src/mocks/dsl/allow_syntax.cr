require "../allow"
require "../stubbable"

module Mocks::DSL
  # Methods to enable the "allow" syntax.
  # This module should be included wherever necessary to specify DSL methods.
  module AllowSyntax
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

    # Fallback method that provides a helpful compiler error message for types that aren't stubbable.
    def allow(object)
      {% raise "`allow` requires a stubbable type (mock or double)" %}
    end
  end
end
