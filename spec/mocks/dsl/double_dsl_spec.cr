require "../../spec_helper"

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

describe Mocks::DSL do
  describe "#double" do
    it "defines a stubbable type" do
      EmptyTestDouble.new.should be_a(Mocks::Stubbable)
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

  describe "#new_double" do
    it "creates a lazy double" do
      double = new_double(test_method: 42)
      double.test_method.should eq(42)
    end

    it "uses the name for the double" do
      double = new_double(:dsl_test)
      double.to_s.should contain("dsl_test")
    end
  end

  describe "#as_null_object" do
    it "creates a chainable double" do
      double = EmptyTestDouble.new.as_null_object
      double.one.two.three.should be(double)
    end

    context "with a lazy double" do
      it "uses the initial stubs" do
        double = new_double(test_method: 42).as_null_object
        double.test_method.should eq(42)
      end

      it "uses the name for the double" do
        double = new_double(:dsl_test).as_null_object
        double.to_s.should contain("dsl_test")
      end

      it "returns itself for undefined methods" do
        double = new_double.as_null_object
        double.nonexistent.should be(double)
      end
    end
  end
end
