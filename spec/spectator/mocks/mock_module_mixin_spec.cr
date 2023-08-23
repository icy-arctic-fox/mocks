require "../../spec_helper"

private alias Mock = Spectator::Mocks::Mock

private module ModuleMixin
  def simple_concrete_untyped_method
    :original
  end

  def simple_concrete_typed_method : Symbol
    :original
  end

  def complex_concrete_untyped_method
    :original
  end

  def complex_concrete_typed_method : Symbol
    :original
  end

  abstract def simple_abstract_untyped_method

  abstract def simple_abstract_typed_method : Symbol

  abstract def complex_abstract_untyped_method

  abstract def complex_abstract_typed_method : Symbol
end

private Mock.define(ModuleMixinMock < ModuleMixin,
  simple_concrete_untyped_method: :mock,
  simple_concrete_typed_method: :mock,
  simple_abstract_untyped_method: :mock,
  simple_abstract_typed_method: :mock) do
  def complex_concrete_untyped_method
    :mock
  end

  def complex_concrete_typed_method : Symbol
    :mock
  end

  def complex_abstract_untyped_method
    :mock
  end

  def complex_abstract_typed_method : Symbol
    :mock
  end
end

describe Mock do
  describe ".define" do
    context "with an abstract struct" do
      it "defines a sub-type" do
        ModuleMixinMock.should be < ModuleMixin
      end

      it "is instantiable" do
        ModuleMixinMock.new.should be_a(ModuleMixin)
      end

      context "with stubs defined by keyword arguments" do
        context "concrete methods" do
          context "untyped methods" do
            it "changes behavior of an untyped method" do
              mock = ModuleMixinMock.new
              mock.simple_concrete_untyped_method.should eq(:mock)
            end

            it "can redefine behavior of an untyped method" do
              mock = ModuleMixinMock.new
              define_stubs(mock, simple_concrete_untyped_method: :override)
              mock.simple_concrete_untyped_method.should eq(:override)
            end

            it "raises when the stubbed type doesn't match the original" do
              mock = ModuleMixinMock.new
              define_stubs(mock, simple_concrete_untyped_method: 42)
              expect_raises(TypeCastError, /Symbol/) { mock.simple_concrete_untyped_method }
            end

            it "compiles to the expected type" do
              mock = ModuleMixinMock.new
              typeof(mock.simple_concrete_untyped_method).should eq(Symbol)
            end
          end

          context "typed methods" do
            it "changes behavior of a typed method" do
              mock = ModuleMixinMock.new
              mock.simple_concrete_typed_method.should eq(:mock)
            end

            it "can redefine behavior of an untyped method" do
              mock = ModuleMixinMock.new
              define_stubs(mock, simple_concrete_typed_method: :override)
              mock.simple_concrete_typed_method.should eq(:override)
            end

            it "raises when the stubbed type doesn't match the original" do
              mock = ModuleMixinMock.new
              define_stubs(mock, simple_concrete_typed_method: 42)
              expect_raises(TypeCastError, /Symbol/) { mock.simple_concrete_typed_method }
            end
          end
        end

        context "abstract methods" do
          context "untyped methods" do
            it "changes behavior of an untyped method" do
              mock = ModuleMixinMock.new
              mock.simple_abstract_untyped_method.should eq(:mock)
            end

            it "can redefine behavior of an untyped method" do
              mock = ModuleMixinMock.new
              define_stubs(mock, simple_abstract_untyped_method: :override)
              mock.simple_abstract_untyped_method.should eq(:override)
            end

            it "raises when the stubbed type doesn't match the original" do
              mock = ModuleMixinMock.new
              define_stubs(mock, simple_abstract_untyped_method: 42)
              expect_raises(TypeCastError, /Symbol/) { mock.simple_abstract_untyped_method }
            end

            it "compiles to the expected type" do
              mock = ModuleMixinMock.new
              typeof(mock.simple_concrete_typed_method).should eq(Symbol)
            end
          end

          context "typed methods" do
            it "changes behavior of a typed method" do
              mock = ModuleMixinMock.new
              mock.simple_abstract_typed_method.should eq(:mock)
            end

            it "can redefine behavior of an untyped method" do
              mock = ModuleMixinMock.new
              define_stubs(mock, simple_abstract_typed_method: :override)
              mock.simple_abstract_typed_method.should eq(:override)
            end

            it "raises when the stubbed type doesn't match the original" do
              mock = ModuleMixinMock.new
              define_stubs(mock, simple_abstract_typed_method: 42)
              expect_raises(TypeCastError, /Symbol/) { mock.simple_abstract_typed_method }
            end
          end
        end
      end
    end
  end
end
