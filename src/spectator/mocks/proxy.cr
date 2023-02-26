require "./call"
require "./scope"

module Spectator::Mocks
  struct Proxy(T)
    def initialize(@object : T, @scope : Scope = Scope.current)
    end

    def add_stub(stub : Stub) : Nil
      @scope.registry.add_stub(@object, stub)
    end

    def find_stub(call : Call) : Stub?
      @scope.registry.find_stub(@object, call)
    end
  end
end
