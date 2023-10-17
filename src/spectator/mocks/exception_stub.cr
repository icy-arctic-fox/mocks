require "./arguments"
require "./stub"

module Spectator::Mocks
  # Stub that raises an exception.
  class ExceptionStub < Stub
    # Creates a stub that throws the specified exception.
    def initialize(method_name : Symbol, @exception : Exception, arguments : AbstractArgumentsPattern? = nil)
      super(method_name, arguments)
    end

    def call(args : Arguments, return_type : U.class = U, & : -> U) forall U
      raise @exception
      yield # This never reached code is intentional.
    end

    private def with_arguments(arguments : AbstractArgumentsPattern?)
      {{@type.name(generic_args: false)}}.new(@exception, method_name, arguments)
    end
  end
end
