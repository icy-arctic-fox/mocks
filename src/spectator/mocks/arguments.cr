module Spectator::Mocks
  # Stores arguments passed by a method call.
  #
  # *Args* must be a `NamedTuple` type representing the standard arguments.
  # *Splat* must be a `Tuple` type representing the extra positional arguments.
  # *DoubleSplat* must be a `NamedTuple` type representing extra keyword arguments.
  class Arguments(Args, Splat, DoubleSplat)
    # Named tuple containing the positional arguments in order.
    getter args : Args

    # Name of the splat argument, if one was provided.
    # Will be nil if there was no splat argument.
    getter splat_name : Symbol?

    # Tuple containing the extra arguments captured by a splat.
    # Will be nil if there was no splat argument.
    getter splat : Splat

    # Named tuple containing the additional keyword arguments.
    getter kwargs : DoubleSplat

    # Creates arguments as they would be available when passed to a method.
    def initialize(@args : Args, @splat_name : Symbol?, @splat : Splat, @kwargs : DoubleSplat)
      {% raise "Positional arguments (generic type Args) must be a NamedTuple" unless Args <= NamedTuple %}
      {% raise "Splat arguments (generic type Splat) must be a Tuple or Nil" unless Splat <= Tuple || Splat == Nil %}
      {% raise "Keyword arguments (generic type DoubleSplat) must be a NamedTuple" unless DoubleSplat <= NamedTuple %}
    end

    # Creates an empty set of arguments.
    def self.none : Arguments
      Arguments.new(NamedTuple.new, nil, nil, NamedTuple.new)
    end

    # Retrieves all positional arguments, including the spat arguments, in the order they were passed.
    def positional : Tuple
      raise NotImplementedError.new("Arguments#positional")
    end

    # Retrieves the positional, non-splat arguments and additional keyword arguments.
    def named : NamedTuple
      raise NotImplementedError.new("Arguments#named")
    end

    # Retrieves the positional argument at the specified index.
    def [](index : Int)
      raise NotImplementedError.new("Arguments#[]")
    end

    # Retrieves a positional, non-splat argument or keyword argument by the specified name.
    def [](arg : Symbol)
      raise NotImplementedError.new("Arguments#[]")
    end

    # Generates the string representation of the arguments.
    def to_s(io : IO) : Nil
      raise NotImplementedError.new("Arguments#to_s")
    end

    def_equals_and_hash @args, @splat_name, @splat, @kwargs
  end
end
