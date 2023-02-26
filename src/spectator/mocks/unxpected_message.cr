module Spectator::Mocks
  class UnexpectedMessage < Exception
    getter method_name : Symbol

    def initialize(@method_name : Symbol, message = nil)
      super(message)
    end
  end
end
