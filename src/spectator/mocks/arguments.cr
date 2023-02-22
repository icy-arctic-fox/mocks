module Spectator::Mocks
  # Base type that all generic argument types inherit from.
  # This allows storing all variations of generic implementations.
  abstract class AbstractArguments
  end

  # Stores arguments passed by a method call.
  #
  # *Args* must be a `NamedTuple` type representing the standard arguments.
  # *Splat* must be a `Tuple` type representing the extra positional arguments.
  # *DoubleSplat* must be a `NamedTuple` type representing extra keyword arguments.
  class Arguments(Args, Splat, DoubleSplat) < AbstractArguments
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
    def self.none : AbstractArguments
      Arguments.new(NamedTuple.new, nil, nil, NamedTuple.new).as(AbstractArguments)
    end

    # Indicates no arguments were passed.
    def empty?
      args.empty? && ((splat = @splat).nil? || splat.empty?) && kwargs.empty?
    end

    # Retrieves all positional arguments, including the spat arguments, in the order they were passed.
    def positional : Tuple
      {% if Splat == Nil %}
        @args.values
      {% else %}
        @args.values + @splat
      {% end %}
    end

    # Retrieves the positional, non-splat arguments and additional keyword arguments.
    def named : NamedTuple
      @kwargs.merge(@args)
    end

    # Retrieves the positional argument at the specified index.
    def [](index : Int)
      positional[index]
    end

    # Retrieves a positional, non-splat argument or keyword argument by the specified name.
    def [](arg : Symbol)
      named[arg]
    end

    # Generates the string representation of the arguments.
    def to_s(io : IO) : Nil
      return io << "(no args)" if empty?

      io << '('

      # Add the positional arguments.
      @args.each_with_index do |_name, value, i|
        io << ", " if i > 0
        value.inspect(io)
      end

      # Add the splat arguments.
      if (splat = @splat) && !splat.empty?
        io << ", " unless @args.empty?
        splat.each_with_index do |value, i|
          io << ", " if i > 0
          value.inspect(io)
        end
      end

      # Add the keyword arguments.
      offset = @args.size
      offset += splat.size if splat = @splat
      @kwargs.each_with_index(offset) do |key, value, i|
        io << ", " if i > 0
        io << key << ": "
        value.inspect(io)
      end

      io << ')'
    end

    def_equals_and_hash @args, @splat_name, @splat, @kwargs
  end
end
