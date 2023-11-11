require "./arguments"

module Mocks
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
    getter named : KeywordArguments

    # Creates a pattern to match against arguments passed to a method.
    def initialize(@positional : Positional, @named : KeywordArguments)
      {% raise "Positional arguments must be a Tuple" unless Positional <= Tuple %}
      {% raise "KeywordArguments must be a NamedTuple" unless KeywordArguments <= NamedTuple %}
    end

    # Creates a pattern to match against arguments written as a normal parameter list.
    def self.build(*args, **named) : AbstractArgumentsPattern
      new(args, named)
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
      return io << "(no args)" if @positional.empty? && @named.empty?

      io << '('

      # Add positional arguments.
      @positional.each_with_index do |value, i|
        io << ", " if i > 0
        value.inspect(io)
      end

      # Add named arguments.
      @named.each_with_index(@positional.size) do |key, value, i|
        io << ", " if i > 0
        io << key << ": "
        value.inspect(io)
      end

      io << ')'
    end

    # Returns the arguments as-if they were passed to a method.
    def to_args : Arguments
      Arguments.new(NamedTuple.new, nil, @positional, @named)
    end

    def_equals_and_hash @positional, @named

    # Checks if arguments passed to a method match those specified by this pattern.
    def ===(arguments : Arguments(Args, Splat, DoubleSplat)) : Bool forall Args, Splat, DoubleSplat
      {% begin %}
        {% named_positional_keys = Args.keys.select { |key| KeywordArguments.keys.includes?(key) }
           keyword_argument_keys = (KeywordArguments.keys - named_positional_keys).sort
           actual_positional_arg_count = Args.size + (Splat == Nil ? 0 : Splat.size)
           expected_positional_arg_count = Positional.size + named_positional_keys.size
           splat_offset = Args.size - named_positional_keys.size %}
        {% if actual_positional_arg_count != expected_positional_arg_count %}
          # The number of positional arguments doesn't match.
          false
        {% elsif keyword_argument_keys != DoubleSplat.keys.sort %}
          # There are either more or less keyword arguments than expected.
          false
        {% else %}
          # Check positional arguments.
          {% for key, i in Args.keys %}
            {% if named_positional_keys.includes?(key) %}
              return false unless compare(@named[{{key.symbolize}}], arguments.args[{{key.symbolize}}])
            {% elsif i < Positional.size %}
              return false unless compare(@positional[{{i}}], arguments.args[{{key.symbolize}}])
            {% end %}
          {% end %}

          {% if Splat != Nil %}
            # Check splat arguments.
            {% for i in (0...Splat.size) %}
              return false unless compare(@positional[{{i + splat_offset}}], arguments.splat[{{i}}])
            {% end %}
          {% end %}

          # Check keyword arguments.
          {% for key in keyword_argument_keys %}
            return false unless compare(@named[{{key.symbolize}}], arguments.kwargs[{{key.symbolize}}])
          {% end %}

          # Comparison of all arguments passed.
          true
        {% end %}
      {% end %}
    end

    # Default comparison of two values.
    # Calls the case equality operator.
    private def compare(left, right)
      left === right
    end

    # Specialization of comparison for ranges.
    # The standard library's `Range#===` method does not restrict the argument's type.
    # If *any* combination of arguments can't be compared, then a compiler error is raised.
    # This method performs a check that satisfies the compiler by ensuring the types are compatible.
    private def compare(left : Range, right : T) forall T
      # Ensure the right-side is a type of the range's beginning and end or it is comparable with those types.
      # The `Comparable` mix-in is a standard module that provides the comparison operators that `Range` looks for.
      if (right.is_a?(typeof(left.begin)) || right.is_a?(Comparable(typeof(left.begin)))) &&
         (right.is_a?(typeof(left.end)) || right.is_a?(Comparable(typeof(left.end))))
        left === right
      else
        left == right
      end
    end

    # Specialization of comparison for procs.
    # The proc must accept a single argument of compatible type to *right*.
    # If this condition is satisfied, then the proc can be called (via ===).
    # Otherwise, compare the proc via standard equality.
    private def compare(left : Proc(*T, R), right : U) forall T, R, U
      {% if T.size == 1 && U <= T[0] %}
        left === right
      {% else %}
        left == right
      {% end %}
    end
  end
end
