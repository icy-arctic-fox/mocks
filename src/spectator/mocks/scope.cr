require "./registry"

module Spectator::Mocks
  # Provides isolation between logical areas.
  # Each area has its own registry.
  class Scope
    @@stack = [] of self

    # Retrieves the active scope.
    def self.current : self
      @@stack.last { raise "Mocks and related functionality cannot be used outside of a test scope" }
    end

    # Starts a new scope.
    # `#pop` should be called after the scope is no longer needed.
    def self.push : self
      scope = new
      @@stack << scope
      scope
    end

    # Starts a new scope for the duration of the block.
    # Yields the new scope to the block and returns the value from the block.
    # `#pop` is called automatically as part of this method.
    def self.push(& : self -> _)
      push
      yield current
    ensure
      pop
    end

    # Ends a previous scope.
    # This should be called for each `#push` without a block.
    def self.pop : Nil
      raise "Cannot pop scope - not in a scope (unbalanced push/pop?)" if @@stack.empty?

      @@stack.pop
    end

    # Registry for the scope.
    getter registry : Registry = Registry.new
  end
end
