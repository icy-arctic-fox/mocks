require "./arguments"

module Spectator::Mocks
  # Information about a method call and the arguments passed to it.
  class Call
    # Name of the method.
    getter method_name : Symbol

    # Arguments passed to the method.
    getter arguments : AbstractArguments

    # Creates the method call.
    def initialize(@method_name : Symbol, @arguments : AbstractArguments = Arguments.none)
    end

    # Produces the string representation of the method call.
    def to_s(io : IO) : Nil
      io << '#' << method_name << arguments
    end
  end
end
