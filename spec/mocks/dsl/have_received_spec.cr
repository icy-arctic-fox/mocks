require "../../spec_helper"

private double TestDouble, test_method: 42

describe Mocks::DSL do
  describe "#have_received" do
    it "detects a method was called" do
      dbl = TestDouble.new
      dbl.test_method
      dbl.should have_received(:test_method)
    end

    it "detects a method wasn't called" do
      dbl = TestDouble.new
      dbl.should_not have_received(:test_method)
    end

    describe "#with" do
      it "detects a method was called with arguments" do
        dbl = TestDouble.new
        dbl.test_method(42)
        dbl.should have_received(:test_method).with(42)
      end

      it "detects a method was called with arguments (case equality)" do
        dbl = TestDouble.new
        dbl.test_method(42)
        dbl.should have_received(:test_method).with(Int32)
      end

      it "detects a method wasn't called with arguments" do
        dbl = TestDouble.new
        dbl.test_method(42)
        dbl.should_not have_received(:test_method).with(5)
      end

      it "detects a method wasn't called with arguments (case equality)" do
        dbl = TestDouble.new
        dbl.test_method(42)
        dbl.should_not have_received(:test_method).with(String)
      end

      describe "#once" do
        it "detects a method was called exactly once with arguments" do
          dbl = TestDouble.new
          dbl.test_method(42)
          dbl.should have_received(:test_method).with(42).once
        end

        it "detects the difference between arguments" do
          dbl = TestDouble.new
          dbl.test_method(42)
          dbl.test_method(0)
          dbl.should have_received(:test_method).with(42).once
        end
      end

      describe "#twice" do
        it "detects a method was called exactly twice with arguments" do
          dbl = TestDouble.new
          2.times { dbl.test_method(42) }
          dbl.should have_received(:test_method).with(42).twice
        end

        it "detects the difference between arguments" do
          dbl = TestDouble.new
          dbl.test_method(42)
          dbl.test_method(0)
          dbl.test_method(42)
          dbl.should have_received(:test_method).with(42).twice
        end
      end

      describe "#exactly" do
        it "detects a method was called the specified amount with arguments" do
          dbl = TestDouble.new
          3.times { dbl.test_method(42) }
          dbl.should have_received(:test_method).with(42).exactly(3).times
        end

        it "detects the difference between arguments" do
          dbl = TestDouble.new
          dbl.test_method(42)
          dbl.test_method(42)
          dbl.test_method(0)
          dbl.test_method(42)
          dbl.should have_received(:test_method).with(42).exactly(3).times
        end
      end

      describe "#exactly(:once)" do
        it "detects a method was called exactly once with arguments" do
          dbl = TestDouble.new
          dbl.test_method(42)
          dbl.should have_received(:test_method).with(42).exactly(:once)
        end

        it "detects the difference between arguments" do
          dbl = TestDouble.new
          dbl.test_method(42)
          dbl.test_method(0)
          dbl.should have_received(:test_method).with(42).exactly(:once)
        end
      end

      describe "#exactly(:twice)" do
        it "detects a method was called exactly twice with arguments" do
          dbl = TestDouble.new
          2.times { dbl.test_method(42) }
          dbl.should have_received(:test_method).with(42).exactly(:twice)
        end

        it "detects the difference between arguments" do
          dbl = TestDouble.new
          dbl.test_method(42)
          dbl.test_method(0)
          dbl.test_method(42)
          dbl.should have_received(:test_method).with(42).exactly(:twice)
        end
      end

      describe "#at_least" do
        it "detects a method was called at least the amount specified" do
          dbl = TestDouble.new
          4.times { dbl.test_method(42) }
          dbl.should have_received(:test_method).with(42).at_least(3).times
        end

        it "detects the difference between arguments" do
          dbl = TestDouble.new
          3.times { dbl.test_method(42) }
          dbl.test_method(0)
          dbl.should have_received(:test_method).with(42).at_least(3).times
        end
      end

      describe "#at_least(:once)" do
        it "detects a method was called at least once" do
          dbl = TestDouble.new
          2.times { dbl.test_method(42) }
          dbl.should have_received(:test_method).with(42).at_least(:once)
        end

        it "detects the difference between arguments" do
          dbl = TestDouble.new
          dbl.test_method(42)
          dbl.test_method(0)
          dbl.should have_received(:test_method).with(42).at_least(:once)
        end
      end

      describe "#at_least(:twice)" do
        it "detects a method was called at least twice" do
          dbl = TestDouble.new
          3.times { dbl.test_method(42) }
          dbl.should have_received(:test_method).with(42).at_least(:twice)
        end

        it "detects the difference between arguments" do
          dbl = TestDouble.new
          dbl.test_method(42)
          dbl.test_method(0)
          dbl.test_method(42)
          dbl.should have_received(:test_method).with(42).at_least(:twice)
        end
      end

      describe "#at_most" do
        it "detects a method was called at most the amount specified" do
          dbl = TestDouble.new
          2.times { dbl.test_method(42) }
          dbl.should have_received(:test_method).with(42).at_most(3).times
        end

        it "detects the difference between arguments" do
          dbl = TestDouble.new
          3.times { dbl.test_method(42) }
          dbl.test_method(0)
          dbl.should have_received(:test_method).with(42).at_most(3).times
        end
      end

      describe "#at_most(:once)" do
        it "detects a method was called at most once" do
          dbl = TestDouble.new
          dbl.should have_received(:test_method).with(42).at_most(:once)
        end

        it "detects the difference between arguments" do
          dbl = TestDouble.new
          dbl.test_method(42)
          dbl.test_method(0)
          dbl.should have_received(:test_method).with(42).at_most(:once)
        end
      end

      describe "#at_most(:twice)" do
        it "detects a method was called at most twice" do
          dbl = TestDouble.new
          dbl.test_method(42)
          dbl.should have_received(:test_method).with(42).at_most(:twice)
        end

        it "detects the difference between arguments" do
          dbl = TestDouble.new
          dbl.test_method(42)
          dbl.test_method(0)
          dbl.test_method(42)
          dbl.should have_received(:test_method).with(42).at_most(:twice)
        end
      end
    end

    describe "#once" do
      it "detects a method was called exactly once" do
        dbl = TestDouble.new
        dbl.test_method
        dbl.should have_received(:test_method).once
      end

      it "detects a method wasn't called" do
        dbl = TestDouble.new
        dbl.should_not have_received(:test_method).once
      end

      it "detect a method was called more than once" do
        dbl = TestDouble.new
        2.times { dbl.test_method }
        dbl.should_not have_received(:test_method).once
      end

      describe "#with" do
        it "matches arguments" do
          dbl = TestDouble.new
          dbl.test_method(42)
          dbl.should have_received(:test_method).once.with(42)
        end
      end
    end

    describe "#twice" do
      it "detects a method was called exactly twice" do
        dbl = TestDouble.new
        2.times { dbl.test_method }
        dbl.should have_received(:test_method).twice
      end

      it "detects a method was called once" do
        dbl = TestDouble.new
        dbl.should_not have_received(:test_method).twice
      end

      it "detect a method was called more than twice" do
        dbl = TestDouble.new
        3.times { dbl.test_method }
        dbl.should_not have_received(:test_method).once
      end

      describe "#with" do
        it "matches arguments" do
          dbl = TestDouble.new
          2.times { dbl.test_method(42) }
          dbl.should have_received(:test_method).twice.with(42)
        end
      end
    end

    describe "#exactly" do
      it "detects a method was called exactly an amount" do
        dbl = TestDouble.new
        3.times { dbl.test_method }
        dbl.should have_received(:test_method).exactly(3).times
      end

      it "detects a method was called less than the amount" do
        dbl = TestDouble.new
        2.times { dbl.test_method }
        dbl.should_not have_received(:test_method).exactly(3).times
      end

      it "detect a method was called more than the amount" do
        dbl = TestDouble.new
        4.times { dbl.test_method }
        dbl.should_not have_received(:test_method).exactly(3).times
      end

      describe "#with" do
        it "matches arguments" do
          dbl = TestDouble.new
          3.times { dbl.test_method(42) }
          dbl.should have_received(:test_method).exactly(3).times.with(42)
        end
      end
    end

    describe "#exactly(:once)" do
      it "detects a method was called exactly once" do
        dbl = TestDouble.new
        dbl.test_method
        dbl.should have_received(:test_method).exactly(:once)
      end

      it "detects a method wasn't called" do
        dbl = TestDouble.new
        dbl.should_not have_received(:test_method).exactly(:once)
      end

      it "detect a method was called more than once" do
        dbl = TestDouble.new
        2.times { dbl.test_method }
        dbl.should_not have_received(:test_method).exactly(:once)
      end

      describe "#with" do
        it "matches arguments" do
          dbl = TestDouble.new
          dbl.test_method(42)
          dbl.should have_received(:test_method).exactly(:once).with(42)
        end
      end
    end

    describe "#exactly(:twice)" do
      it "detects a method was called exactly twice" do
        dbl = TestDouble.new
        2.times { dbl.test_method }
        dbl.should have_received(:test_method).exactly(:twice)
      end

      it "detects a method wasn't called enough" do
        dbl = TestDouble.new
        dbl.test_method
        dbl.should_not have_received(:test_method).exactly(:twice)
      end

      it "detect a method was called more than twice" do
        dbl = TestDouble.new
        3.times { dbl.test_method }
        dbl.should_not have_received(:test_method).exactly(:twice)
      end

      describe "#with" do
        it "matches arguments" do
          dbl = TestDouble.new
          2.times { dbl.test_method(42) }
          dbl.should have_received(:test_method).exactly(:twice).with(42)
        end
      end
    end

    describe "#at_least" do
      it "detects a method was called an amount" do
        dbl = TestDouble.new
        3.times { dbl.test_method }
        dbl.should have_received(:test_method).at_least(3).times
      end

      it "detects a method was called more than the amount" do
        dbl = TestDouble.new
        4.times { dbl.test_method }
        dbl.should have_received(:test_method).at_least(3).times
      end

      it "detects a method was called less than the amount" do
        dbl = TestDouble.new
        2.times { dbl.test_method }
        dbl.should_not have_received(:test_method).at_least(3).times
      end

      describe "#with" do
        it "matches arguments" do
          dbl = TestDouble.new
          4.times { dbl.test_method(42) }
          dbl.should have_received(:test_method).at_least(3).with(42)
        end
      end
    end

    describe "#at_least(:once)" do
      it "detects a method was called exactly once" do
        dbl = TestDouble.new
        dbl.test_method
        dbl.should have_received(:test_method).at_least(:once)
      end

      it "detects a method wasn't called" do
        dbl = TestDouble.new
        dbl.should_not have_received(:test_method).at_least(:once)
      end

      it "detect a method was called more than once" do
        dbl = TestDouble.new
        2.times { dbl.test_method }
        dbl.should have_received(:test_method).at_least(:once)
      end

      describe "#with" do
        it "matches arguments" do
          dbl = TestDouble.new
          2.times { dbl.test_method(42) }
          dbl.should have_received(:test_method).at_least(:once).with(42)
        end
      end
    end

    describe "#at_least(:twice)" do
      it "detects a method was called exactly twice" do
        dbl = TestDouble.new
        2.times { dbl.test_method }
        dbl.should have_received(:test_method).at_least(:twice)
      end

      it "detects a method wasn't called enough" do
        dbl = TestDouble.new
        dbl.test_method
        dbl.should_not have_received(:test_method).at_least(:twice)
      end

      it "detect a method was called more than twice" do
        dbl = TestDouble.new
        3.times { dbl.test_method }
        dbl.should have_received(:test_method).at_least(:twice)
      end

      describe "#with" do
        it "matches arguments" do
          dbl = TestDouble.new
          3.times { dbl.test_method(42) }
          dbl.should have_received(:test_method).at_least(:twice).with(42)
        end
      end
    end

    describe "#at_most" do
      it "detects a method was called an amount" do
        dbl = TestDouble.new
        3.times { dbl.test_method }
        dbl.should have_received(:test_method).at_most(3).times
      end

      it "detects a method was called less than the amount" do
        dbl = TestDouble.new
        2.times { dbl.test_method }
        dbl.should have_received(:test_method).at_most(3).times
      end

      it "detects a method was called more than the amount" do
        dbl = TestDouble.new
        4.times { dbl.test_method }
        dbl.should_not have_received(:test_method).at_most(3).times
      end

      describe "#with" do
        it "matches arguments" do
          dbl = TestDouble.new
          2.times { dbl.test_method(42) }
          dbl.should have_received(:test_method).at_most(3).times.with(42)
        end
      end
    end

    describe "#at_most(:once)" do
      it "detects a method was called exactly once" do
        dbl = TestDouble.new
        dbl.test_method
        dbl.should have_received(:test_method).at_most(:once)
      end

      it "detects a method wasn't called" do
        dbl = TestDouble.new
        dbl.should have_received(:test_method).at_most(:once)
      end

      it "detect a method was called more than once" do
        dbl = TestDouble.new
        2.times { dbl.test_method }
        dbl.should_not have_received(:test_method).at_most(:once)
      end

      describe "#with" do
        it "matches arguments" do
          dbl = TestDouble.new
          dbl.test_method(42)
          dbl.should have_received(:test_method).at_most(:once).with(42)
        end
      end
    end

    describe "#at_most(:twice)" do
      it "detects a method was called exactly twice" do
        dbl = TestDouble.new
        2.times { dbl.test_method }
        dbl.should have_received(:test_method).at_most(:twice)
      end

      it "detects a method was called once" do
        dbl = TestDouble.new
        dbl.test_method
        dbl.should have_received(:test_method).at_most(:twice)
      end

      it "detect a method was called more than twice" do
        dbl = TestDouble.new
        3.times { dbl.test_method }
        dbl.should_not have_received(:test_method).at_most(:twice)
      end

      describe "#with" do
        it "matches arguments" do
          dbl = TestDouble.new
          2.times { dbl.test_method(42) }
          dbl.should have_received(:test_method).at_most(:twice).with(42)
        end
      end
    end
  end
end
