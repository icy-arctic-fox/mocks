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

describe Spectator::Mocks::DSL do
  describe "#can" do
    context "with a double" do
      it "can redefine standard methods" do
        double = EmptyTestDouble.new
        double.can receive(:to_s).and_return("override")
        double.to_s.should eq("override")
      end

      it "can redefine simple value methods" do
        double = SimpleTestDouble.new
        double.can receive(:value).and_return(42)
        double.value.should eq(42)
      end

      it "can redefine simple typed-value methods" do
        double = SimpleTestDouble.new
        double.can receive(:typed_value).and_return(42)
        double.typed_value.should eq(42)
      end

      it "can redefine simple typed methods" do
        double = SimpleTestDouble.new
        double.can receive(:typed).and_return(42)
        double.typed.should eq(42)
      end

      it "can redefine stubs from the block" do
        double = ComplexTestDouble.new
        double.can receive(:method).and_return(42)
        double.method.should eq(42)
      end

      it "can redefine simple stubs overridden in the block" do
        double = ComplexTestDouble.new
        double.can receive(:override).and_return(42)
        double.override.should eq(42)
      end

      it "can redefine multiple stubs" do
        double = SimpleTestDouble.new
        double.can receive(value: 3, typed_value: 4, typed: 5)
        double.value.should eq(3)
        double.typed_value.should eq(4)
        double.typed.should eq(5)
      end
    end

    context "with a mock" do
    end
  end
end
