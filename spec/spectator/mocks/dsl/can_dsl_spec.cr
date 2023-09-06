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

private class EmptyClass; end

private mock EmptyClassMock < EmptyClass

private abstract class SimpleClass
  def value
    0
  end

  def typed_value : Int32
    0
  end

  abstract def typed : Int32
end

private mock SimpleClassMock < SimpleClass, value: 1, typed_value: 2

private class ComplexClass
  def value
    0
  end

  def typed_value : Int32
    0
  end

  def method
    0
  end

  def override
    0
  end
end

private mock ComplexClassMock < ComplexClass, value: 1, typed_value: 2 do
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
      it "can redefine standard methods" do
        mock = EmptyClassMock.new
        mock.can receive(:to_s).and_return("override")
        mock.to_s.should eq("override")
      end

      it "can redefine simple value methods" do
        mock = SimpleClassMock.new
        mock.can receive(:value).and_return(42)
        mock.value.should eq(42)
      end

      it "can redefine simple typed-value methods" do
        mock = SimpleClassMock.new
        mock.can receive(:typed_value).and_return(42)
        mock.typed_value.should eq(42)
      end

      it "can redefine simple typed methods" do
        mock = SimpleClassMock.new
        mock.can receive(:typed).and_return(42)
        mock.typed.should eq(42)
      end

      it "can redefine stubs from the block" do
        mock = ComplexClassMock.new
        mock.can receive(:method).and_return(42)
        mock.method.should eq(42)
      end

      it "can redefine simple stubs overridden in the block" do
        mock = ComplexClassMock.new
        mock.can receive(:override).and_return(42)
        mock.override.should eq(42)
      end

      it "can redefine multiple stubs" do
        mock = SimpleClassMock.new
        mock.can receive(value: 3, typed_value: 4, typed: 5)
        mock.value.should eq(3)
        mock.typed_value.should eq(4)
        mock.typed.should eq(5)
      end
    end
  end
end
