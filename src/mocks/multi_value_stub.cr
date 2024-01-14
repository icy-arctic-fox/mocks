require "./stub"

module Mocks
  # Stub that returns one of a set of values.
  # Values are returned once, except for the last value.
  # The last value is returned when all other values are exhausted.
  class MultiValueStub(T) < Stub
    def initialize(method_name : Symbol, @values : Array(T), arguments : AbstractArgumentsPattern? = nil)
      super(method_name, arguments)
    end

    def call(args : Arguments, return_type : U.class = U, & : -> U) forall U
      value = @values.size == 1 ? @values.first : @values.shift

      {% if T <= U %}
        value
      {% elsif U == Nil %}
        nil # Ignore value.
      {% else %}
        raise TypeCastError.new("Attempted to return #{value.inspect} (#{T}) from stub, but method `#{method_name}` expects type #{U}")
      {% end %}
    end

    private def with_arguments(arguments : AbstractArgumentsPattern?)
      {{@type.name(generic_args: false)}}.new(method_name, @values, arguments)
    end
  end
end
