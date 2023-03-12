module Spectator::Mocks
  # Exception raised when a method was called that wasn't allowed or expected.
  class UnexpectedMessage < Exception
    # Name of the method that was called.
    getter method_name : Symbol

    def initialize(@method_name : Symbol, message = "Unexpected method `#{method_name}` was called")
      super(message)
    end
  end
end
