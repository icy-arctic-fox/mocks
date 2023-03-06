require "./stub"
require "./stubbable"
require "./value_stub"

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

    def initialize(name = nil)
      @name = name.try &.to_s
    end

    def initialize(stubs : Enumerable(Stub))
      initialize(nil, stubs)
    end

    def initialize(name, stubs : Enumerable(Stub))
      @name = name.try &.to_s
      proxy = __mocks
      stubs.each do |stub|
        proxy.add_stub(stub)
      end
    end

    def initialize(name = nil, **value_stubs)
      @name = name.try &.to_s
      proxy = __mocks
      value_stubs.each do |method_name, value|
        stub = ValueStub.new(method_name, value)
        proxy.add_stub(stub)
      end
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
