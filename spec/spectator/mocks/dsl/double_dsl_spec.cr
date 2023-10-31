require "../../../spec_helper"

private double EmptyTestDouble

private double SimpleTestDouble, value = 1, typed_value : Int32 = 2, typed : Int32

private double ComplexTestDouble, value: 1, override: 2 do
  def method
    3
  end

  def override
    4
  end
end

private double AbstractTestDouble do
  stub do_not_call_me : Symbol

  stub abstract def abstract_method : Symbol
end

describe Spectator::Mocks::DSL do
  describe "#double" do
    it "defines a stubbable type" do
      EmptyTestDouble.new.should be_a(Spectator::Mocks::Stubbable)
    end

    it "applies simple value stubs" do
      double = SimpleTestDouble.new
      double.value.should eq(1)
    end

    it "applies simple typed-value stubs" do
      double = SimpleTestDouble.new
      double.typed_value.should eq(2)
    end

    it "applies simple typed stubs" do
      double = SimpleTestDouble.new
      typeof(double.typed).should eq(Int32)
      expect_raises(UnexpectedMessage, /typed/) { double.typed }
    end

    it "applies stubs from the block" do
      double = ComplexTestDouble.new
      double.method.should eq(3)
    end

    it "overrides simple stubs with stubs from the block" do
      double = ComplexTestDouble.new
      double.override.should eq(4)
    end

    it "raises for abstract typed stubs" do
      double = AbstractTestDouble.new
      expect_raises(UnexpectedMessage, /do_not_call_me/) { double.do_not_call_me }
    end

    it "raises for abstract methods" do
      double = AbstractTestDouble.new
      expect_raises(UnexpectedMessage, /abstract_method/) { double.abstract_method }
    end
  end

  describe "#as_null_object" do
    pending "creates a chainable double" do
      double = EmptyTestDouble.new.as_null_object
      double.one.two.three.should be(double)
    end
  end
end
