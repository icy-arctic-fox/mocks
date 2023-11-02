module Spectator::Mocks
  enum ReceiveCount
    None  = 0
    Once  = 1
    Twice = 2
  end

  module ReceiveExpectationModifiers
    def once
      exactly(1)
    end

    def twice
      exactly(2)
    end

    def exactly(n : Int)
      with_count(n..n)
    end

    def at_least(count : ReceiveCount)
      at_least(count.to_i)
    end

    def at_least(n : Int)
      with_count(n..)
    end

    def at_most(count : ReceiveCount)
      at_most(count.to_i)
    end

    def at_most(n : Int)
      with_count(..n)
    end

    # Returns a new expectation with a modified call count.
    private abstract def with_count(count : Range(Int32?, Int32?))
  end
end
