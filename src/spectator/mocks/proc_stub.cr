require "./stub"

module Spectator::Mocks
  # Stub that calls a proc and returns its return value.
  class ProcStub(T) < Stub
    def initialize(method_name : Symbol, @proc : -> T, arguments : AbstractArgumentsPattern? = nil)
      super(method_name, arguments)
    end

    def initialize(method_name : Symbol, arguments : AbstractArgumentsPattern? = nil, &@proc : -> T)
      super(method_name, arguments)
    end

    def call(args : Arguments, return_type : U.class, & : -> U) forall U
      {% if T <= U %}
        @proc.call
      {% else %}
        raise TypeCastError.new("Attempted to return a #{T} from stub, but method `#{method_name}` expects type #{U}")
      {% end %}
    end

    private def with_arguments(arguments : AbstractArgumentsPattern?)
      {{@type.name(generic_args: false)}}.new(method_name, @proc, arguments)
    end
  end
end
