require "./arguments"
require "./arguments_pattern"
require "./call"
require "./stub_modifiers"

module Mocks
  # Stand-in behavior for a method.
  abstract class Stub
    include StubModifiers

    # Name of the method being applied to.
    getter method_name : Symbol

    # Arguments necessary to trigger the stub.
    # If nil, any arguments will trigger the stub.
    getter arguments : AbstractArgumentsPattern?

    # Creates the stub.
    def initialize(@method_name : Symbol, @arguments : AbstractArgumentsPattern? = nil)
    end

    # Invokes the stub.
    # *args* are the arguments passed to the method call.
    # The *return_type* indicates the type expected to be returned by the stub.
    # The type returned by this method must match *return_type*.
    abstract def call(args : Args, return_type : U.class = Nil) forall Args, U

    # Indicates whether the stub can handle a method call.
    # Returns false if a stubbable object should use its default behavior (i.e. the original method).
    def handled?
      true
    end

    # Constructs the string representation of the stub.
    def to_s(io : IO) : Nil
      io << '#' << method_name
      if args = @arguments
        io << args
      else
        io << "(any args)"
      end
    end

    # Checks if the stub can be used for a method call.
    def ===(call : Call) : Bool
      return false unless method_name == call.method_name
      return true unless args = @arguments # Match any arguments.

      args === call.arguments
    end
  end
end
