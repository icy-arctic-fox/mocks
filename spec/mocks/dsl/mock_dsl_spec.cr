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

class InjectedClass
  def kwargs
    :original
  end

  def block
    :original
  end

  def test_method
    :original
  end
end

struct InjectedStruct
  def kwargs
    :original
  end

  def block
    :original
  end

  def test_method
    :original
  end
end

module InjectedModule
  extend self

  def kwargs
    :original
  end

  def block
    :original
  end

  def test_method
    :original
  end
end

mock!(InjectedClass, kwargs: :default) do
  def block
    :default
  end
end

mock!(InjectedStruct, kwargs: :default) do
  def block
    :default
  end
end

mock!(InjectedModule, kwargs: :default) do
  def block
    :default
  end
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

  describe "#mock!" do
    context "with a class" do
      it "injects mock functionality" do
        obj = InjectedClass.new
        obj.__mocks.should_not be_nil
      end

      it "prevents calls the original method" do
        obj = InjectedClass.new
        expect_raises(::Mocks::UnexpectedMessage, /test_method/) { obj.test_method }
      end

      it "can allow calling the original method" do
        obj = InjectedClass.new
        stub = ::Mocks::CallOriginalStub.new(:test_method)
        obj.__mocks.add_stub(stub)
        obj.test_method.should eq(:original)
      end

      it "can redefine existing methods" do
        obj = InjectedClass.new
        stub = value_stub(:test_method, :override)
        obj.__mocks.add_stub(stub)
        obj.test_method.should eq(:override)
      end

      it "defines default stubs with keyword arguments" do
        obj = InjectedClass.new
        obj.kwargs.should eq(:default)
      end

      it "defines default stubs with a block" do
        obj = InjectedClass.new
        obj.block.should eq(:default)
      end
    end

    context "with a struct" do
      it "injects mock functionality" do
        obj = InjectedStruct.new
        obj.__mocks.should_not be_nil
      end

      it "prevents calls the original method" do
        obj = InjectedStruct.new
        expect_raises(::Mocks::UnexpectedMessage, /test_method/) { obj.test_method }
      end

      it "can allow calling the original method" do
        obj = InjectedStruct.new
        stub = ::Mocks::CallOriginalStub.new(:test_method)
        obj.__mocks.add_stub(stub)
        obj.test_method.should eq(:original)
      end

      it "can redefine existing methods" do
        obj = InjectedStruct.new
        stub = value_stub(:test_method, :override)
        obj.__mocks.add_stub(stub)
        obj.test_method.should eq(:override)
      end

      it "defines default stubs with keyword arguments" do
        obj = InjectedStruct.new
        obj.kwargs.should eq(:default)
      end

      it "defines default stubs with a block" do
        obj = InjectedStruct.new
        obj.block.should eq(:default)
      end
    end

    context "with a module" do
      it "injects mock functionality" do
        obj = InjectedModule
        obj.__mocks.should_not be_nil
      end

      it "prevents calls the original method" do
        obj = InjectedModule
        expect_raises(::Mocks::UnexpectedMessage, /test_method/) { obj.test_method }
      end

      it "can allow calling the original method" do
        obj = InjectedModule
        stub = ::Mocks::CallOriginalStub.new(:test_method)
        obj.__mocks.add_stub(stub)
        obj.test_method.should eq(:original)
      end

      it "can redefine existing methods" do
        obj = InjectedModule
        stub = value_stub(:test_method, :override)
        obj.__mocks.add_stub(stub)
        obj.test_method.should eq(:override)
      end

      it "defines default stubs with keyword arguments" do
        obj = InjectedModule
        obj.kwargs.should eq(:default)
      end

      it "defines default stubs with a block" do
        obj = InjectedModule
        obj.block.should eq(:default)
      end
    end
  end
end
