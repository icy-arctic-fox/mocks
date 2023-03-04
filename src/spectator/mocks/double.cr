require "./stubbable"

module Spectator::Mocks
  abstract class Double
    include Stubbable::Automatic

    macro define(name, *stubs, &block)
      class {{name.id}} < ::Spectator::Mocks::Double
        {% for stub in stubs %}
          stub {{stub}}
        {% end %}

        {{block.body if block}}
      end
    end

    @stubs : Array(Stub)

    def initialize(@name : String, stubs : Enumerable(Stub))
      @stubs = stubs.to_a
    end
  end
end
