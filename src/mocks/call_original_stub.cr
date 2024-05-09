require "./stub"

module Mocks
  # Stub that calls the original method and returns its return value.
  class CallOriginalStub < Stub
    def call(args : Args, return_type : U.class = Nil) forall Args, U
      raise "CallOriginalStub cannot be called directly"
      Mocks.fake_value(U) # ameba:disable Lint/UnreachableCode
    end

    def handled?
      false
    end

    private def with_arguments(arguments : AbstractArgumentsPattern?)
      {{@type.name}}.new(method_name, arguments)
    end
  end
end
