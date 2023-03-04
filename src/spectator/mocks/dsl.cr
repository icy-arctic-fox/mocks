require "./allow"
require "./double"
require "./mock"
require "./nil_stub"

module Spectator::Mocks
  module DSL
    macro double(name, *stubs, &block)
      ::Spectator::Mocks::Double.define({{name}}, {{*stubs}}) {{block}}
    end

    macro mock(type, *stubs, &block)
      ::Spectator::Mocks::Mock.define({{name}}, {{*stubs}}) {{block}}
    end

    def allow(stubbable : Stubbable)
      Allow.new(stubbable.__mocks)
    end

    def receive(method : Symbol)
      NilStub.new(method)
    end
  end
end
