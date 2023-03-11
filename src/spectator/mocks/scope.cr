require "./registry"

module Spectator::Mocks
  # Provides isolation between logical areas.
  # Each area has its own registry.
  class Scope
    @@stack = [new]

    # Retrieves the active scope.
    def self.current : self
      @@stack.last
    end

    # Registry for the scope.
    getter registry : Registry = Registry.new
  end
end
