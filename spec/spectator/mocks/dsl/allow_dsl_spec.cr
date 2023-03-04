require "../../../spec_helper"

include Spectator::Mocks::DSL

private double EmptyTestDouble

private double SimpleTestDouble, value = 1, typed_value : Int32 = 2, typed : Int32

private double ComplexTestDouble, value = 1, typed_value : Int32 = 2, typed : Int32 do
end

describe Spectator::Mocks::DSL do
  describe "#allow" do
    context "with a double" do
      it "can redefine standard methods" do
        double = EmptyTestDouble.new
        allow(double).to receive(:to_s).and_return("override")
        double.to_s.should eq("override")
      end

      it "can redefine simple value methods" do
        double = SimpleTestDouble.new
        allow(double).to receive(:value).and_return(42)
        double.value.should eq(42)
      end

      it "can redefine simple typed-value methods" do
        double = SimpleTestDouble.new
        allow(double).to receive(:typed_value).and_return(42)
        double.typed_value.should eq(42)
      end

      it "can redefine simple typed methods" do
        double = SimpleTestDouble.new
        allow(double).to receive(:typed).and_return(42)
        double.typed.should eq(42)
      end
    end

    context "with a mock" do
    end
  end
end
