module Spectator::Mocks
  enum ReceiveCountKeyword
    Once  = 1
    Twice = 2
  end

  module ReceiveCountExpectationModifiers
    # Modifies the expectation to check for exactly one matching call.
    #
    # ```
    # double.some_method
    # double.should have_received(:some_method).once
    # ```
    def once
      exactly(1)
    end

    # Modifies the expectation to check for exactly two matching calls.
    #
    # ```
    # double.some_method
    # double.some_method
    # double.should have_received(:some_method).twice
    # ```
    def twice
      exactly(2)
    end

    # Modifies the expectation to check for an exact number of calls.
    #
    # ```
    # 3.times { double.some_method }
    # double.should have_received(:some_method).exactly(3).times
    # ```
    def exactly(n : Int)
      with_count(n..n)
    end

    # Modifies the expectation to check for an exact number of calls.
    #
    # ```
    # double.some_method
    # double.should have_received(:some_method).exactly(:once)
    # ```
    def exactly(count : ReceiveCountKeyword)
      exactly(count.to_i)
    end

    # Modifies the expectation to check for at least a specified number of calls.
    #
    # ```
    # 3.times { double.some_method }
    # double.should have_received(:some_method).at_least(:once)
    # ```
    def at_least(count : ReceiveCountKeyword)
      at_least(count.to_i)
    end

    # Modifies the expectation to check for at least a specified number of calls.
    # ```
    # 3.times { double.some_method }
    # double.should have_received(:some_method).at_least(1).time
    # ```
    def at_least(n : Int)
      with_count(n..)
    end

    # Modifies the expectation to check for at most a specified number of calls.
    #
    # ```
    # 2.times { double.some_method }
    # double.should have_received(:some_method).at_most(:twice)
    # ```
    def at_most(count : ReceiveCountKeyword)
      at_most(count.to_i)
    end

    # Modifies the expectation to check for at most a specified number of calls.
    # ```
    # 2.times { double.some_method }
    # double.should have_received(:some_method).at_most(3).times
    # ```
    def at_most(n : Int)
      with_count(..n)
    end

    # Returns a new expectation with a modified call count.
    private abstract def with_count(count)
  end
end
