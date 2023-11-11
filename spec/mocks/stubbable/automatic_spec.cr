require "../../spec_helper"

private module ParentModule
  def parent_module_method
    :parent_module
  end
end

private abstract class Parent
  extend ParentModule
  include ParentModule

  def parent_method
    :parent
  end

  def self.parent_class_method
    :parent_class
  end

  abstract def abstract_method

  abstract def abstract_typed_method : Int32
end

private module ChildModule
  def child_module_method
    :child_module
  end
end

private class Child < Parent
  extend ChildModule
  include ChildModule

  def existing_method
    :existing
  end

  def self.existing_class_method
    :existing_class
  end

  include Mocks::Stubbable::Automatic

  def new_method
    :new
  end

  def self.new_class_method
    :new_class
  end

  # Abstract methods from a parent without a return type must be specified like this.
  stub abstract def abstract_method : Symbol
end

private class Sub < Child
  def sub_method
    :sub
  end

  def self.sub_class_method
    :sub_class
  end
end

private def value_stub(method_name, value)
  Mocks::ValueStub.new(method_name, value)
end

describe Mocks::Stubbable::Automatic do
  it "makes existing methods stubbable" do
    obj = Child.new
    stub = value_stub(:existing_method, :stubbed)
    obj.__mocks.add_stub(stub)
    obj.existing_method.should eq(:stubbed)
  end

  it "makes existing class methods stubbable" do
    stub = value_stub(:existing_class_method, :stubbed)
    Child.__mocks.add_stub(stub)
    Child.existing_class_method.should eq(:stubbed)
  end

  it "makes new methods stubbable" do
    obj = Child.new
    stub = value_stub(:new_method, :stubbed)
    obj.__mocks.add_stub(stub)
    obj.new_method.should eq(:stubbed)
  end

  it "makes new class methods stubbable" do
    stub = value_stub(:new_class_method, :stubbed)
    Child.__mocks.add_stub(stub)
    Child.new_class_method.should eq(:stubbed)
  end

  it "makes parent methods stubbable" do
    obj = Child.new
    stub = value_stub(:parent_method, :stubbed)
    obj.__mocks.add_stub(stub)
    obj.parent_method.should eq(:stubbed)
  end

  it "makes parent class methods stubbable" do
    stub = value_stub(:parent_class_method, :stubbed)
    Child.__mocks.add_stub(stub)
    Child.parent_class_method.should eq(:stubbed)
  end

  it "makes abstract untyped methods stubbable" do
    obj = Child.new
    stub = value_stub(:abstract_method, :stubbed)
    obj.__mocks.add_stub(stub)
    obj.abstract_method.should eq(:stubbed)
  end

  it "makes abstract typed methods stubbable" do
    obj = Child.new
    stub = value_stub(:abstract_typed_method, 42)
    obj.__mocks.add_stub(stub)
    obj.abstract_typed_method.should eq(42)
  end

  it "makes abstract methods raise by default" do
    obj = Child.new
    expect_raises(UnexpectedMessage, /abstract_method/) { obj.abstract_method }
  end

  it "makes parent module methods stubbable" do
    obj = Child.new
    stub = value_stub(:parent_module_method, :stubbed)
    obj.__mocks.add_stub(stub)
    obj.parent_module_method.should eq(:stubbed)
  end

  # Class methods brought in by extending a module are not stubbable.
  pending "makes parent module class methods stubbable" do
    stub = value_stub(:parent_module_method, :stubbed)
    Child.__mocks.add_stub(stub)
    Child.parent_module_method.should eq(:stubbed)
  end

  it "makes module methods stubbable" do
    obj = Child.new
    stub = value_stub(:child_module_method, :stubbed)
    obj.__mocks.add_stub(stub)
    obj.child_module_method.should eq(:stubbed)
  end

  # Class methods brought in by extending a module are not stubbable.
  pending "makes module class methods stubbable" do
    stub = value_stub(:child_module_method, :stubbed)
    Child.__mocks.add_stub(stub)
    Child.child_module_method.should eq(:stubbed)
  end

  it "makes sub-type methods stubbable" do
    obj = Sub.new
    stub = value_stub(:sub_method, :stubbed)
    obj.__mocks.add_stub(stub)
    obj.sub_method.should eq(:stubbed)
  end

  it "makes sub-type class methods stubbable" do
    stub = value_stub(:sub_class_method, :stubbed)
    Sub.__mocks.add_stub(stub)
    Sub.sub_class_method.should eq(:stubbed)
  end
end
