require "./stubbable"
require "./stubbed"

module Mocks
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
          {% if T.has_method?(@def.name.stringify) ||
                  @type.ancestors.any? { |ancestor| ancestor.has_method?(@def.name.stringify) } %}
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
