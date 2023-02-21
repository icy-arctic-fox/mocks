require "./arguments"

module Spectator::Mocks
  # Base type that all generic argument pattern types inherit from.
  # This allows storing all variations of generic implementations.
  abstract class AbstractArgumentsPattern
  end

  # Arguments matched against to determine if a stub should be used or a call had expected arguments.
  #
  # The *Positional* type parameter must be a `Tuple`.
  # The *KeywordArguments* type parameter must be a `NamedTuple`.
  class ArgumentsPattern(Positional, KeywordArguments) < AbstractArgumentsPattern
    # Positional arguments.
    getter positional : Positional

    # Keyword arguments.
    getter kwargs : KeywordArguments

    # Creates a pattern to match against arguments passed to a method.
    def initialize(@positional : Positional, @kwargs : KeywordArguments)
      {% raise "Positional arguments must be a Tuple" unless Positional <= Tuple %}
      {% raise "KeywordArguments must be a NamedTuple" unless KeywordArguments <= NamedTuple %}
    end

    # Creates a pattern to match against arguments written as a normal parameter list.
    def self.build(*args, **kwargs) : AbstractArgumentsPattern
      new(args, kwargs)
    end

    # Creates an empty set of arguments to match against.
    # Matching against this indicates no arguments were passed.
    def self.none : AbstractArgumentsPattern
      ArgumentsPattern.new(Tuple.new, NamedTuple.new).as(AbstractArgumentsPattern)
    end

    # Returns a value that matches against any and all arguments.
    def self.any : AbstractArgumentsPattern?
      nil.as(AbstractArgumentsPattern?)
    end

    # Generates the string representation of the argument pattern.
    def to_s(io : IO) : Nil
      raise NotImplementedError.new("ArgumentsPattern#to_s")
    end

    # Returns the arguments as-if they were passed to a method.
    def to_args : Arguments
      raise NotImplementedError.new("ArgumentsPattern#to_args")
    end

    def_equals_and_hash @positional, @kwargs

    # Checks if arguments passed to a method match those specified by this pattern.
    def ===(arguments : Arguments) : Bool
      raise NotImplementedError.new("ArgumentsPattern#===")
    end
  end
end
