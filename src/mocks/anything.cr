module Mocks
  # Object that matches any value or reference (including nil).
  struct Anything
    # Returns true.
    def ==(other)
      true
    end
  end
end
