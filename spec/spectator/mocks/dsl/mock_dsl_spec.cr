require "../../../spec_helper"

class OriginalClass
  def method
    :original_class
  end
end

abstract struct OriginalStruct
  def method
    :original_struct
  end
end

module OriginalModule
  def method
    :original_module
  end
end

mock MockSimpleClass < OriginalClass, method: :stubbed_class

mock MockSimpleStruct < OriginalStruct, method: :stubbed_struct

mock MockSimpleModule < OriginalModule, method: :stubbed_module

private def value_stub(method_name, value)
  Spectator::Mocks::ValueStub.new(method_name, value)
end

describe Spectator::Mocks::DSL do
  describe "#mock" do
    context "with a class" do
      it "defines a sub-type of the original" do
        obj = MockSimpleClass.new
        obj.should be_a(OriginalClass)
      end

      it "defines default behavior with simple value stubs" do
        obj = MockSimpleClass.new
        obj.method.should eq(:stubbed_class)
      end

      it "can redefine behavior of a simple value stub" do
        obj = MockSimpleClass.new
        stub = value_stub(:method, :override)
        obj.__mocks.add_stub(stub)
        obj.method.should eq(:override)
      end
    end

    context "with a struct" do
      it "defines a sub-type of the original" do
        obj = MockSimpleStruct.new
        obj.should be_a(OriginalStruct)
      end

      it "defines default behavior with simple value stubs" do
        obj = MockSimpleStruct.new
        obj.method.should eq(:stubbed_struct)
      end

      it "can redefine behavior of a simple value stub" do
        obj = MockSimpleStruct.new
        stub = value_stub(:method, :override)
        obj.__mocks.add_stub(stub)
        obj.method.should eq(:override)
      end
    end

    # Creating an instance of a mock module causes a stack overflow (infinite recursion).
    context "with a module" do
      pending "defines a sub-type of the original" do
        obj = MockSimpleModule.new
        obj.should be_a(OriginalModule)
      end

      pending "defines default behavior with simple value stubs" do
        obj = MockSimpleModule.new
        obj.method.should eq(:stubbed_module)
      end

      pending "can redefine behavior of a simple value stub" do
        obj = MockSimpleModule.new
        stub = value_stub(:method, :override)
        obj.__mocks.add_stub(stub)
        obj.method.should eq(:override)
      end
    end
  end
end
