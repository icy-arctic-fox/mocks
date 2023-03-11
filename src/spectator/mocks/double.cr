require "./stub"
require "./stubbable"
require "./value_stub"

module Spectator::Mocks
  abstract class Double
    include Stubbable::Automatic

    macro define(name, *stubs, &block)
      class {{name.id}} < {{@type.name}}
        {% for stub in stubs %}
          stub_any_args {{stub}}
        {% end %}

        {{block.body if block}}
      end
    end

    @name : String?

    def initialize(name = nil)
      @name = name.try &.to_s
    end

    protected def initialize(name, value_stubs : T) forall T
      {% raise "Type argument T must be a NamedTuple" unless T < NamedTuple %}

      initialize(name)
      proxy = __mocks

      # Avoid producing a stub where each value is a union (don't use `#each`).
      # This is done by capturing the NamedTuple's type (and keys) via T.
      # A layer of indirection is necessary since the syntax `**kwargs : **T` isn't valid.
      {% for key in T.keys %}
        proxy.add_stub(ValueStub.new({{key.symbolize}}, value_stubs[{{key.symbolize}}]))
      {% end %}
    end

    def self.new(name = nil, **value_stubs)
      new(name, value_stubs)
    end

    def to_s(io : IO) : Nil
      io << "#<" << self.class << ":0x"
      object_id.to_s(io, 16)
      if name = @name
        io << "\"#{name}\""
      else
        io << "anonymous"
      end
      io << '>'
    end
  end
end
