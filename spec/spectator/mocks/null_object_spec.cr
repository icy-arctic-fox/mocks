require "../../spec_helper"

private double TestDouble, value: 0

def null_double(double = TestDouble.new)
  Spectator::Mocks::NullObject.new(double)
end

describe Spectator::Mocks::NullObject do
  context "with one level deep" do
    pending "returns itself for non-existent methods" do
      double = null_double
      double.nonexistent.should be(double)
    end

    pending "supports block arguments" do
      double = null_double
      double.nonexistent { 0 }.should be(double)
    end
  end

  context "with multiple levels deep" do
    pending "returns itself for non-existent methods" do
      double = null_double
      double.one.two.three.nonexistent.should be(double)
    end

    pending "supports block arguments" do
      double = null_double
      double.one.two.three.nonexistent { 0 }.should be(double)
    end
  end

  pending "supports stubs specific to the double's methods" do
    double = null_double
    stub = Spectator::Mocks::ValueStub.new(:value, 1)
    double.__mocks.add_stub(stub)
    double.value.should eq(1)
  end

  pending "forwards methods calls to the underlying double" do
    double = null_double
    double.value.should eq(0)
  end

  pending "supports stubs on standard methods" do
    double = null_double
    stub = Spectator::Mocks::ValueStub.new(:to_s, "This is a test")
    double.__mocks.add_stub(stub)
    double.to_s.should eq("This is a test")
  end

  pending "supports stubs on non-existent methods" do
    double = null_double
    stub = Spectator::Mocks::ValueStub.new(:nonexistent, "This is a test")
    double.__mocks.add_stub(stub)
    double.nonexistent.should eq("This is a test")
  end
end
