require "../spec_helper"

private double TestDouble, value: 0

def null_double(double = TestDouble.new)
  Mocks::NullObject.new(double)
end

describe Mocks::NullObject do
  context "with one level deep" do
    it "returns itself for non-existent methods" do
      double = null_double
      double.nonexistent.should be(double)
    end

    it "supports block arguments" do
      double = null_double
      double.nonexistent { 0 }.should be(double)
    end
  end

  context "with multiple levels deep" do
    it "returns itself for non-existent methods" do
      double = null_double
      double.one.two.three.nonexistent.should be(double)
    end

    it "supports block arguments" do
      double = null_double
      double.one.two.three.nonexistent { 0 }.should be(double)
    end
  end

  it "supports stubs specific to the double's methods" do
    double = null_double
    stub = Mocks::ValueStub.new(:value, 1)
    double.__mocks.add_stub(stub)
    double.value.should eq(1)
  end

  it "forwards methods calls to the underlying double" do
    double = null_double
    double.value.should eq(0)
  end

  it "supports stubs on standard methods" do
    double = null_double
    stub = Mocks::ValueStub.new(:to_s, "This is a test")
    double.__mocks.add_stub(stub)
    double.to_s.should eq("This is a test")
  end

  pending "supports stubs on non-existent methods" do
    double = null_double
    stub = Mocks::ValueStub.new(:nonexistent, "This is a test")
    double.__mocks.add_stub(stub)
    double.nonexistent.should eq("This is a test")
  end

  context "equality" do
    it "works with ==" do
      double = null_double
      (double == double).should be_true
    end

    it "works with ===" do
      double = null_double
      (double === double).should be_true
    end

    it "works with same?" do
      double = null_double
      double.same?(double).should be_true
    end
  end
end
