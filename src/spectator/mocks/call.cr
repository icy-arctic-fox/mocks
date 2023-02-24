require "./arguments"

module Spectator::Mocks
  # Base class for all method call types.
  abstract class AbstractCall
  end

  # Information about a method call and the arguments passed to it.
  class Call(Args) < AbstractCall
    # Name of the method.
    getter method_name : Symbol

    # Arguments passed to the method.
    getter arguments : Args

    # Creates the method call.
    def initialize(@method_name : Symbol, @arguments : Args)
      {% raise "Generic type Args must be an Arguments" unless Args <= Arguments %}
    end

    # Creates a method call with no arguments.
    def self.new(method_name : Symbol)
      new(method_name, Arguments.none)
    end

    # Produces the string representation of the method call.
    def to_s(io : IO) : Nil
      io << '#' << method_name << arguments
    end
  end
end
