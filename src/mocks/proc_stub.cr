require "./stub"

module Mocks
  # Stub that calls a proc and returns its return value.
  class ProcStub(T) < Stub
    def initialize(method_name : Symbol, @proc : -> T, arguments : AbstractArgumentsPattern? = nil)
      super(method_name, arguments)
    end

    def initialize(method_name : Symbol, arguments : AbstractArgumentsPattern? = nil, &@proc : -> T)
      super(method_name, arguments)
    end

    def call(args : Args, return_type : U.class = Nil) forall Args, U
      {% if T <= U %}
        @proc.call
      {% elsif U == Nil %}
        @proc.call # Still call the proc,
        nil        # but ignore the value.
      {% else %}
        raise TypeCastError.new("Attempted to return a #{T} from stub, but method `#{method_name}` expects type #{U}")
      {% end %}
    end

    private def with_arguments(arguments : AbstractArgumentsPattern?)
      {{@type.name(generic_args: false)}}.new(method_name, @proc, arguments)
    end
  end
end
