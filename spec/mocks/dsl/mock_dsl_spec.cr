require "../../spec_helper"

private abstract class OriginalClass
  def method
    :original_class
  end

  abstract def abstract_method

  abstract def abstract_typed_method : Symbol
end

private abstract struct OriginalStruct
  def method
    :original_struct
  end

  abstract def abstract_method

  abstract def abstract_typed_method : Symbol
end

private module OriginalModule
  def method
    :original_module
  end

  abstract def abstract_method

  abstract def abstract_typed_method : Symbol
end

private mock MockSimpleClass < OriginalClass, method: :stubbed_class

private mock MockComplexClass < OriginalClass, method: :stubbed_class do
  stub abstract def abstract_method : Symbol
end

private mock MockSimpleStruct < OriginalStruct, method: :stubbed_struct

private mock MockComplexStruct < OriginalStruct, method: :stubbed_struct do
  stub abstract def abstract_method : Symbol
end

private mock MockSimpleModule < OriginalModule, method: :stubbed_module

private mock MockComplexModule < OriginalModule, method: :stubbed_module do
  stub abstract def abstract_method : Symbol
end

private def value_stub(method_name, value)
  Mocks::ValueStub.new(method_name, value)
end

describe Mocks::DSL do
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

      it "raises for abstract methods" do
        obj = MockSimpleClass.new
        expect_raises(UnexpectedMessage, /abstract_method/) { obj.abstract_method }
      end

      it "can have stubs applied to abstract methods" do
        obj = MockComplexClass.new
        stub = value_stub(:abstract_method, :override)
        obj.__mocks.add_stub(stub)
        obj.abstract_method.should eq(:override)
      end

      it "raises for abstract typed methods" do
        obj = MockSimpleClass.new
        expect_raises(UnexpectedMessage, /abstract_typed_method/) { obj.abstract_typed_method }
      end

      it "can have stubs applied to abstract typed methods" do
        obj = MockSimpleClass.new
        stub = value_stub(:abstract_typed_method, :override)
        obj.__mocks.add_stub(stub)
        obj.abstract_typed_method.should eq(:override)
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

      it "raises for abstract methods" do
        obj = MockSimpleStruct.new
        expect_raises(UnexpectedMessage, /abstract_method/) { obj.abstract_method }
      end

      it "can have stubs applied to abstract methods" do
        obj = MockComplexStruct.new
        stub = value_stub(:abstract_method, :override)
        obj.__mocks.add_stub(stub)
        obj.abstract_method.should eq(:override)
      end

      it "raises for abstract typed methods" do
        obj = MockSimpleStruct.new
        expect_raises(UnexpectedMessage, /abstract_typed_method/) { obj.abstract_typed_method }
      end

      it "can have stubs applied to abstract typed methods" do
        obj = MockSimpleStruct.new
        stub = value_stub(:abstract_typed_method, :override)
        obj.__mocks.add_stub(stub)
        obj.abstract_typed_method.should eq(:override)
      end
    end

    context "with a module" do
      it "defines a sub-type of the original" do
        obj = MockSimpleModule.new
        obj.should be_a(OriginalModule)
      end

      it "defines default behavior with simple value stubs" do
        obj = MockSimpleModule.new
        obj.method.should eq(:stubbed_module)
      end

      it "can redefine behavior of a simple value stub" do
        obj = MockSimpleModule.new
        stub = value_stub(:method, :override)
        obj.__mocks.add_stub(stub)
        obj.method.should eq(:override)
      end

      it "raises for abstract methods" do
        obj = MockSimpleModule.new
        expect_raises(UnexpectedMessage, /abstract_method/) { obj.abstract_method }
      end

      it "can have stubs applied to abstract methods" do
        obj = MockComplexModule.new
        stub = value_stub(:abstract_method, :override)
        obj.__mocks.add_stub(stub)
        obj.abstract_method.should eq(:override)
      end

      it "raises for abstract typed methods" do
        obj = MockSimpleModule.new
        expect_raises(UnexpectedMessage, /abstract_typed_method/) { obj.abstract_typed_method }
      end

      it "can have stubs applied to abstract typed methods" do
        obj = MockSimpleModule.new
        stub = value_stub(:abstract_typed_method, :override)
        obj.__mocks.add_stub(stub)
        obj.abstract_typed_method.should eq(:override)
      end
    end
  end
end
