require "../../spec_helper"

alias Double = Spectator::Mocks::Double

Double.define EmptyTestDouble

private def define_stubs(double : Double, **value_stubs : **T) forall T
  proxy = double.__mocks
  # Avoid NamedTuple#each since it produces a union of types for each value.
  # This may throw-off the types used by stubs.
  {% for key in T %}
    stub = Spectator::Mocks::ValueStub.new({{key.symbolize}}, value_stubs[{{key.symbolize}}])
    proxy.add_stub(stub)
  {% end %}
end

describe Double do
  describe ".define" do
    it "defines a double" do
      EmptyTestDouble.new.should be_a(Double)
    end
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
