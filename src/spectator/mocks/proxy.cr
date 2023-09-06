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

    # Records a method call made to the object this proxy represents.
    # See: `Registry#call_call`
    def add_call(call : Call) : Nil
      @scope.registry.add_call(@object, call)
    end

    # Retrieves all calls made to an object.
    # See: `Registry#calls`
    def calls : Enumerable
      @scope.registry.calls(@object)
    end

    # Clears all previously defined stubs and recorded calls.
    # See: `Registry#clear`
    def reset : Nil
      @scope.registry.clear(@object)
    end
  end
end
