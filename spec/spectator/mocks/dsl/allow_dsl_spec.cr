require "../../../spec_helper"

# 'allow' syntax must be manually dragged in for Spec framework.
require "../../../../src/spectator/mocks/dsl/allow_syntax"
include Spectator::Mocks::DSL::AllowSyntax

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

      it "can redefine stubs from the block" do
        double = ComplexTestDouble.new
        allow(double).to receive(:method).and_return(42)
        double.method.should eq(42)
      end

      it "can redefine simple stubs overridden in the block" do
        double = ComplexTestDouble.new
        allow(double).to receive(:override).and_return(42)
        double.override.should eq(42)
      end

      it "can redefine multiple methods" do
        double = SimpleTestDouble.new
        allow(double).to receive(value: 3, typed_value: 4, typed: 5)
        double.value.should eq(3)
        double.typed_value.should eq(4)
        double.typed.should eq(5)
      end
    end

    context "with a mock" do
      it "can redefine standard methods" do
        mock = EmptyClassMock.new
        allow(mock).to receive(:to_s).and_return("override")
        mock.to_s.should eq("override")
      end

      it "can redefine simple value methods" do
        mock = SimpleClassMock.new
        allow(mock).to receive(:value).and_return(42)
        mock.value.should eq(42)
      end

      it "can redefine simple typed-value methods" do
        mock = SimpleClassMock.new
        allow(mock).to receive(:typed_value).and_return(42)
        mock.typed_value.should eq(42)
      end

      it "can redefine simple typed methods" do
        mock = SimpleClassMock.new
        allow(mock).to receive(:typed).and_return(42)
        mock.typed.should eq(42)
      end

      it "can redefine stubs from the block" do
        mock = ComplexClassMock.new
        allow(mock).to receive(:method).and_return(42)
        mock.method.should eq(42)
      end

      it "can redefine simple stubs overridden in the block" do
        mock = ComplexClassMock.new
        allow(mock).to receive(:override).and_return(42)
        mock.override.should eq(42)
      end

      it "can redefine multiple methods" do
        mock = SimpleClassMock.new
        allow(mock).to receive(value: 3, typed_value: 4, typed: 5)
        mock.value.should eq(3)
        mock.typed_value.should eq(4)
        mock.typed.should eq(5)
      end
    end
  end
end
