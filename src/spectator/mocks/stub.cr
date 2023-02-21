require "./arguments"
require "./arguments_pattern"
require "./call"

module Spectator::Mocks
  # Stand-in behavior for a method.
  abstract class Stub
    # Name of the method being applied to.
    getter method_name : Symbol

    # Arguments necessary to trigger the stub.
    # If nil, any arguments will trigger the stub.
    getter args : ArgumentsPattern?

    # Creates the stub.
    def initialize(@method_name : Symbol, @args : ArgumentsPattern? = nil)
    end

    # Invokes the stub.
    # *args* are the arguments passed to the method call.
    # A block must be passed that invokes the original method or fallback behavior.
    # The type returned by the block is used to derive the type returned by this method.
    abstract def call(args : Arguments, & : -> _)

    # Checks if the stub can be used for a method call.
    def ===(call : Call) : Bool
      raise NotImplementedError.new("Stub#===")
    end
  end
end
