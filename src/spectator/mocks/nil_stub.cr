require "./arguments"
require "./stub"

module Spectator::Mocks
  # Stub that does nothing and returns nil.
  class NilStub < Stub
    def call(args : Arguments, & : -> T) : T forall T
      {% if T <= NoReturn %}
        # NoReturn <= Nil is true, an explicit check for it is required.
        raise TypeCastError.new("Attempted to return nil from stub, but method `#{method_name}` must not return")
      {% elsif !(Nil <= T) %}
        # A non-nil value is expected to be returned.
        # Raising prevents a compilation error.
        raise TypeCastError.new("Attempted to return nil from stub, but method `#{method_name}` expects type #{T}")
      {% end %}
    end

    private def with_arguments(arguments : AbstractArgumentsPattern?)
      {{@type.name(generic_args: false)}}.new(method_name, arguments)
    end
  end
end
