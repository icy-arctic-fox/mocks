require "./proxy"
require "./stub"

module Spectator::Mocks
  struct Allow(T)
    def initialize(@proxy : Proxy(T))
    end

    def to(stub : Stub)
      @proxy.add_stub(stub)
    end
  end
end
