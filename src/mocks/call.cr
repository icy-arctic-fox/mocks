require "./arguments"

module Mocks
  # Base class for all method call types.
  abstract class AbstractCall
    # Dispatch for comparing a concrete call to a concrete stub.
    abstract def match?(stub : Stub) : Bool
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

    # Creates a method call containing from the current invocation.
    macro capture
      %args = ::Mocks::Arguments.capture
      {{@type.name(generic_args: false)}}.new({{@def.name.symbolize}}, %args)
    end

    def match?(stub : Stub) : Bool
      stub === self
    end

    # Produces the string representation of the method call.
    def to_s(io : IO) : Nil
      io << '#' << method_name << arguments
    end
  end
end
