require "./arguments"
require "./stub"

module Mocks
  # Stub that raises an exception.
  class ExceptionStub < Stub
    # Creates a stub that throws the specified exception.
    def initialize(method_name : Symbol, @exception : Exception, arguments : AbstractArgumentsPattern? = nil)
      super(method_name, arguments)
    end

    def call(args : Arguments, return_type : U.class = U, & : -> U) forall U
      raise @exception
      # This unreachable code is intentional (compiler infers return type from yield).
      yield # ameba:disable Lint/UnreachableCode
    end

    private def with_arguments(arguments : AbstractArgumentsPattern?)
      {{@type.name(generic_args: false)}}.new(method_name, @exception, arguments)
    end
  end
end
