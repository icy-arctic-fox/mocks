require "../../spec_helper"

private class StubbableType
  include Spectator::Mocks::Stubbable

  stub def method_syntax
    :default
  end

  stub def nil_method_syntax : Nil
  end

  stub type_decl_syntax : Symbol

  stub nil_type_decl_syntax : Nil

  stub type_decl_value_syntax : Symbol = :default

  stub nil_type_decl_value_syntax : Int32? = nil

  def existing_method_syntax(arg)
    arg
  end

  def existing_method_syntax
    :existing
  end

  stub :existing_method_syntax

  stub private def visibility_syntax(arg)
    arg
  end

  def proxy_visibility_syntax(arg)
    visibility_syntax(arg)
  end
end

private def nil_stub(method_name)
  Spectator::Mocks::NilStub.new(method_name)
end

private def value_stub(method_name, value)
  Spectator::Mocks::ValueStub.new(method_name, value)
end

describe Spectator::Mocks::Stubbable do
  describe "#stub" do
    context "with a method definition" do
      it "defines a method with a default implementation" do
        object = StubbableType.new
        object.method_syntax.should eq(:default)
      end

      it "can change the method's behavior" do
        object = StubbableType.new
        stub = value_stub(:method_syntax, :override)
        object.__mocks.add_stub(stub)
        object.method_syntax.should eq(:override)
      end

      it "raises when the stub's return types doesn't match the default implementation's return type" do
        object = StubbableType.new
        stub = value_stub(:method_syntax, 42)
        object.__mocks.add_stub(stub)
        expect_raises(TypeCastError, /Symbol/) { object.method_syntax }
      end

      it "supports Nil as a type" do
        object = StubbableType.new
        stub = value_stub(:nil_method_syntax, 42)
        object.__mocks.add_stub(stub)
        expect_raises(TypeCastError, /Nil/) { object.nil_method_syntax }

        stub = nil_stub(:nil_method_syntax)
        object.__mocks.add_stub(stub)
        object.nil_method_syntax.should be_nil
      end
    end

    context "with a type declaration" do
      it "defines a method that raises by default" do
        object = StubbableType.new
        expect_raises(Spectator::Mocks::UnexpectedMessage, /type_decl_syntax/) { object.type_decl_syntax }
      end

      it "can change the method's behavior" do
        object = StubbableType.new
        stub = value_stub(:type_decl_syntax, :override)
        object.__mocks.add_stub(stub)
        object.type_decl_syntax.should eq(:override)
      end

      it "raises when the stub's return types doesn't match the default implementation's return type" do
        object = StubbableType.new
        stub = value_stub(:type_decl_syntax, 42)
        object.__mocks.add_stub(stub)
        expect_raises(TypeCastError, /Symbol/) { object.type_decl_syntax }
      end

      it "supports Nil as a type" do
        object = StubbableType.new
        stub = value_stub(:nil_type_decl_syntax, 42)
        object.__mocks.add_stub(stub)
        expect_raises(TypeCastError, /Nil/) { object.nil_type_decl_syntax }

        stub = nil_stub(:nil_type_decl_syntax)
        object.__mocks.add_stub(stub)
        object.nil_type_decl_syntax.should be_nil
      end
    end

    context "with a type declaration and value" do
      it "defines a method that returns the value" do
        object = StubbableType.new
        object.type_decl_value_syntax.should eq(:default)
      end

      it "can change the method's behavior" do
        object = StubbableType.new
        stub = value_stub(:type_decl_value_syntax, :override)
        object.__mocks.add_stub(stub)
        object.type_decl_value_syntax.should eq(:override)
      end

      it "raises when the stub's return type doesn't match the default implementation's return type" do
        object = StubbableType.new
        stub = value_stub(:type_decl_value_syntax, 42)
        object.__mocks.add_stub(stub)
        expect_raises(TypeCastError, /Symbol/) { object.type_decl_value_syntax }
      end

      it "supports nil as a value" do
        object = StubbableType.new
        stub = value_stub(:nil_type_decl_value_syntax, 42)
        object.__mocks.add_stub(stub)
        object.nil_type_decl_value_syntax.should eq(42)

        stub = nil_stub(:nil_type_decl_value_syntax)
        object.__mocks.add_stub(stub)
        object.nil_type_decl_value_syntax.should be_nil
      end
    end

    context "with a method name" do
      it "redefines a method to be stubbable" do
        object = StubbableType.new
        object.existing_method_syntax(:existing).should eq(:existing)
      end

      it "can change the method's behavior" do
        object = StubbableType.new
        stub = value_stub(:existing_method_syntax, 5)
        object.__mocks.add_stub(stub)
        object.existing_method_syntax(42).should eq(5)
      end

      it "raises when the stub's return type doesn't match the default implementation's return type" do
        object = StubbableType.new
        stub = value_stub(:existing_method_syntax, :wrong_type)
        object.__mocks.add_stub(stub)
        expect_raises(TypeCastError, /Int32/) { object.existing_method_syntax(42) }
      end

      it "redefines all methods with the same name" do
        object = StubbableType.new
        stub = value_stub(:existing_method_syntax, :override)
        object.__mocks.add_stub(stub)
        object.existing_method_syntax.should eq(:override)
      end
    end

    context "with a visibility modifier" do
      it "redefines a method to be stubbable" do
        object = StubbableType.new
        object.proxy_visibility_syntax(42).should eq(42)
      end

      it "can change the method's behavior" do
        object = StubbableType.new
        stub = value_stub(:visibility_syntax, 5)
        object.__mocks.add_stub(stub)
        object.proxy_visibility_syntax(42).should eq(5)
      end
    end
  end
end
