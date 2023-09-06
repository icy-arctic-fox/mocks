require "../../../spec_helper"

private double TestDouble, test_method: 42

describe Spectator::Mocks::DSL do
  describe "#have_received" do
    it "can detect a method was called" do
      dbl = TestDouble.new
      dbl.test_method
      dbl.should have_received(:test_method)
    end

    it "can detect a method wasn't called" do
      dbl = TestDouble.new
      dbl.should_not have_received(:test_method)
    end
  end
end
