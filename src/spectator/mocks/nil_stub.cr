require "./arguments"
require "./stub"

module Spectator::Mocks
  # Stub that does nothing and returns nil.
  class NilStub < Stub
    def call(args : Arguments, & : -> _)
      type = typeof(yield)
      return if type.nilable?

      raise TypeCastError.new("Attempted to return nil from stub, but method `#{method_name}` expects to return #{type}")
    end
  end
end
