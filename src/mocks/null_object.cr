require "./stubbable"
require "./stubbed"

module Mocks
  # Double that responds to all methods, typically used for method chains.
  # Calling a method that exists on the underlying double will delegate to that method.
  # Conversely, calling a method that doesn't exist will return the same instance.
  # ```
  # double(TestDouble, some_method: 42)
  # TestDouble.new.some_method # => 42
  # null_object = NullObject.new(TestDouble.new)
  # null_object.some_method  # => 42
  # null_object.other_method # => null_object
  # ```
  class NullObject(T)
    include Stubbable

    delegate __mocks, to: @object

    stub_existing do
      delegate_current_call({{"@object." + @def.name.stringify}})
    end

    def initialize(@object : T)
      {% raise "Type argument of NullObject must be Stubbable, #{T} is not Stubbable" unless T <= Stubbable %}
    end

    # Constructs a string representation of the double.
    stub def inspect(io : IO) : Nil
      io << "#<" << self.class << ' '
      @object.to_s(io)
      io << '>'
    end

    macro method_missing(call)
      {% verbatim do %}
        stubbed_method_body(as: :infer) do
          # Call original method if it exists.
          {% if T.has_method?(@def.name.stringify) ||
                  @type.ancestors.any? &.has_method?(@def.name.stringify) %}
            delegate_current_call({{"@object." + @def.name.stringify}})
          {% else %}
            self
          {% end %}
        end
      {% end %}
    end

    stub def ==(other : self)
      @object == other.@object
    end

    stub def ===(other : self)
      @object == other.@object
    end

    stub def same?(other : Reference)
      if other.is_a?(self)
        @object.same?(other.@object)
      else
        @object.same?(other)
      end
    end
  end
end
