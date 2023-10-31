require "./stubbable"
require "./stubbed"

module Spectator::Mocks
  struct NullObject(T)
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
        {% if T.has_method?(@def.name.stringify) %} # The `.has_method?` macro method does not inspect parent types.
          delegate_current_call({{"@object." + @def.name.stringify}})
        {% else %}
          self
        {% end %}
      end
      {% end %}
    end
  end
end
