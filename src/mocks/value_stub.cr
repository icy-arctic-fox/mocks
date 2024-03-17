require "./stub"

module Mocks
  # Stub that returns a static value.
  class ValueStub(T) < Stub
    def initialize(method_name : Symbol, @value : T, arguments : AbstractArgumentsPattern? = nil)
      super(method_name, arguments)
    end

    def call(args : Args, return_type : U.class = U, & : Args -> U) forall Args, U
      {% if T <= U %}
        @value
      {% elsif U == Nil %}
        nil # Ignore value.
      {% else %}
        raise TypeCastError.new("Attempted to return #{@value.inspect} (#{T}) from stub, but method `#{method_name}` expects type #{U}")
      {% end %}
    end

    private def with_arguments(arguments : AbstractArgumentsPattern?)
      {{@type.name(generic_args: false)}}.new(method_name, @value, arguments)
    end
  end
end
