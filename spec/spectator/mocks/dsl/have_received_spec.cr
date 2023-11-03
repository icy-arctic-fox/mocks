require "../../../spec_helper"

private double TestDouble, test_method: 42

describe Spectator::Mocks::DSL do
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
    end
  end
end
