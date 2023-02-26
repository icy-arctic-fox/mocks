require "./registry"

module Spectator::Mocks
  class Scope
    @@stack = [new]

    def self.current : self
      @@stack.last
    end

    getter registry : Registry = Registry.new
  end
end
