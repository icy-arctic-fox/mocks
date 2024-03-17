require "./stub"

module Mocks
  # Stub that calls the original method and returns its return value.
  class CallOriginalStub < Stub
    def call(args : Args, return_type : U.class = U, & : Args -> U) forall Args, U
      yield args
    end

    private def with_arguments(arguments : AbstractArgumentsPattern?)
      {{@type.name}}.new(method_name, arguments)
    end
  end
end
