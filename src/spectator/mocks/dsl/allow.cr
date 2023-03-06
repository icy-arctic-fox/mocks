require "../allow"

module Spectator::Mocks
  module DSL
    def allow(stubbable : Stubbable)
      Allow.new(stubbable.__mocks)
    end
  end
end
