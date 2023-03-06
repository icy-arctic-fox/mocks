require "./double"
require "./mock"
require "./nil_stub"
require "./proc_stub"

module Spectator::Mocks
  module DSL
    macro double(name, *stubs, &block)
      ::Spectator::Mocks::Double.define({{name}}, {{*stubs}}) {{block}}
    end

    macro mock(type, *stubs, &block)
      ::Spectator::Mocks::Mock.define({{name}}, {{*stubs}}) {{block}}
    end

    def receive(method : Symbol)
      NilStub.new(method)
    end

    def receive(method : Symbol, &block : -> T) forall T
      ProcStub.new(method, block)
    end
  end
end

# Automatically include DSL methods and use 'can' syntax
# for Crystal's Spec framework.
{% if @top_level.has_constant?(:Spec) %}
  require "./dsl/can"

  module Spec::Methods
    include Spectator::Mocks::DSL
  end
{% end %}
