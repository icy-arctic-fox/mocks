require "../spec_helper"

describe Mocks::LazyDouble do
  it "defines methods that return the values specified" do
    double = Mocks::LazyDouble.new(test_method: 5)
    double.test_method.should eq(5)
  end

  it "raises by default for an undefined method" do
    double = Mocks::LazyDouble.new
    expect_raises(UnexpectedMessage, /test_method/) { double.test_method }
  end

  it "can have stubs defined for lazily defined methods" do
    double = Mocks::LazyDouble.new(test_method: 0)
    define_stubs(double, test_method: 42)
    double.test_method.should eq(42)
  end

  it "can lazily redefine existing methods" do
    double = Mocks::LazyDouble.new(to_s: "foo")
    double.to_s.should eq("foo")
  end

  it "can have stubs defined for standard methods" do
    double = Mocks::LazyDouble.new
    define_stubs(double, to_s: "foo")
    double.to_s.should eq("foo")
  end

  it "can have stubs defined for parent methods" do
    double = Mocks::LazyDouble.new
    other = Mocks::LazyDouble.new
    define_stubs(double, itself: other)
    double.itself.should be(other)
  end

  describe "#initialize" do
    it "accepts a non-string name" do
      double = Mocks::LazyDouble.new(:init_name_test)
      double.to_s.should contain("init_name_test")
    end

    it "sets keyword arguments as stubs" do
      # Hash of a reference type can't be 0.
      double = Mocks::LazyDouble.new(to_s: "foobar", hash: 0_u64)
      double.to_s.should eq("foobar")
      double.hash.should eq(0)
    end
  end

  describe "#to_s" do
    it "contains the double's name" do
      double = Mocks::LazyDouble.new("Foobar")
      double.to_s.should contain("Foobar")
    end

    it "contains the double's type" do
      double = Mocks::LazyDouble.new("Foobar")
      double.to_s.should contain("LazyDouble")
    end

    it "contains 'anonymous' when no name is given" do
      double = Mocks::LazyDouble.new
      double.to_s.should contain("anonymous")
    end
  end

  it "allows calling standard methods by default" do
    double = Mocks::LazyDouble.new

    (double == double).should eq(true), "`double == double` was not true"
    (double == nil).should eq(false), "`double == nil` was not false"
    (double == "foo").should eq(false), "`double == \"foo\"` was not false"

    (double === double).should eq(true), "`double === double` was not true"
    (double === nil).should eq(false), "`double === nil` was not false"
    (double === "foo").should eq(false), "`double === \"foo\" was not false"

    double.to_s.should contain("Mocks::LazyDouble"), "`double.to_s` should contain its type name"
    double.inspect.should contain(double.class.name), "`double.inspect` should contain its type name"

    double.same?(double).should eq(true), "`double.same?(mock)` was not true"
    double.same?(nil).should eq(false), "`double.same?(nil)` was not false"
    double.same?("foo").should eq(false), "`double.same?(\"foo\")` was not false"
  end
end
