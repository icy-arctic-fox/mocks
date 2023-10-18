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
  end
end
