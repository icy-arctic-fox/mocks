require "../spec_helper"

alias Double = Mocks::Double

private Double.define EmptyTestDouble

private Double.define SimpleTestDouble, typed : Symbol, typed_assignment : Symbol = :original, assignment = :value

describe Double do
  describe ".define" do
    it "defines a double" do
      EmptyTestDouble.new.should be_a(Double)
    end

    it "defines a stubbable method by type declaration" do
      double = SimpleTestDouble.new
      typeof(double.typed).should eq(Symbol)
    end

    it "defines a stubbable method by type declaration with assignment" do
      double = SimpleTestDouble.new
      double.typed_assignment.should eq(:original)
    end

    it "defines a stubbable method by assignment" do
      double = SimpleTestDouble.new
      double.assignment.should eq(:value)
    end
  end

  it "raises by default for a method without a value" do
    double = SimpleTestDouble.new
    expect_raises(UnexpectedMessage, /typed/) { double.typed }
  end

  it "can have stubs defined for a type declaration" do
    double = SimpleTestDouble.new
    define_stubs(double, typed: :stubbed)
    double.typed.should eq(:stubbed)
  end

  it "can have stubs defined for a type declaration with assignment" do
    double = SimpleTestDouble.new
    define_stubs(double, typed_assignment: :stubbed)
    double.typed_assignment.should eq(:stubbed)
  end

  it "can have stubs defined for an assignment" do
    double = SimpleTestDouble.new
    define_stubs(double, assignment: :stubbed)
    double.assignment.should eq(:stubbed)
  end

  it "can have stubs defined for standard methods" do
    double = EmptyTestDouble.new
    define_stubs(double, to_s: "foo")
    double.to_s.should eq("foo")
  end

  it "can have stubs defined for parent methods" do
    double = EmptyTestDouble.new
    other = EmptyTestDouble.new
    define_stubs(double, itself: other)
    double.itself.should be(other)
  end

  describe "#initialize" do
    it "accepts a non-string name" do
      double = EmptyTestDouble.new(:empty)
      double.to_s.should contain("empty")
    end

    it "sets keyword arguments as stubs" do
      # Hash of a reference type can't be 0.
      double = EmptyTestDouble.new(to_s: "foobar", hash: 0_u64)
      double.to_s.should eq("foobar")
      double.hash.should eq(0)
    end
  end

  describe "#to_s" do
    it "contains the double's name" do
      double = EmptyTestDouble.new("Foobar")
      double.to_s.should contain("Foobar")
    end

    it "contains the double's type" do
      double = EmptyTestDouble.new("Foobar")
      double.to_s.should contain(EmptyTestDouble.to_s)
    end

    it "contains 'anonymous' when no name is given" do
      double = EmptyTestDouble.new
      double.to_s.should contain("anonymous")
    end
  end
end
