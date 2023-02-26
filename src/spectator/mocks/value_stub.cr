module Spectator::Mocks
  # Stub that returns a static value.
  class ValueStub(T) < Stub
    def initialize(method_name : Symbol, @value : T, arguments : AbstractArgumentsPattern? = nil)
      super(method_name, arguments)
    end

    def call(args : Arguments, & : -> U) : U forall U
      {% if T <= U %}
        @value
      {% else %}
        raise TypeCastError.new("Attempted to return #{@value.inspect} (#{U}) from stub, but method `#{method_name}` expects type #{T}")
      {% end %}
    end
  end
end
