require "./call"
require "./scope"

module Spectator::Mocks
  # Forwards stub and call operations to a registry for a single object.
  struct Proxy(T)
    # Creates a new proxy for the specified object and scope.
    def initialize(@object : T, @scope : Scope = Scope.current)
    end

    # Adds a stub to the object this proxy represents.
    # See: `Registry#add_stub`
    def add_stub(stub : Stub) : Nil
      @scope.registry.add_stub(@object, stub)
    end

    # Finds a stub to the object this proxy represents.
    # See: `Registry#find_stub`
    def find_stub(call : Call) : Stub?
      @scope.registry.find_stub(@object, call)
    end
  end
end
