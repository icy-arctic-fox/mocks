require "./stubbable"

module Spectator::Mocks
  abstract class Double
    include Stubbable::Automatic

    macro define(name, *stubs, &block)
      class {{name.id}} < ::Spectator::Mocks::Double
        {% for stub in stubs %}
          stub_any_args {{stub}}
        {% end %}

        {{block.body if block}}
      end
    end

    @name : String?

    def initialize(@name : String? = nil)
    end

    def initialize(@name : String?, stubs : Enumerable(Stub))
      proxy = __mocks
      stubs.each do |stub|
        proxy.add_stub(stub)
      end
    end

    def to_s(io : IO) : Nil
      raise NotImplementedError.new("Double#to_s")
    end
  end
end
