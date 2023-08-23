require "../../spec_helper"

private alias Mock = Spectator::Mocks::Mock

private class ConcreteClass
  def simple_untyped_method
    :original
  end

  def simple_typed_method : Symbol
    :original
  end

  def complex_untyped_method
    :original
  end

  def complex_typed_method : Symbol
    :original
  end
end

private Mock.define(ConcreteClassMock < ConcreteClass,
  simple_untyped_method: :mock,
  simple_typed_method: :mock) do
  def complex_typed_method
    :mock
  end

  def complex_typed_method : Symbol
    :mock
  end
end

describe Mock do
  describe ".define" do
    context "with a concrete class" do
      it "defines a sub-type" do
        ConcreteClassMock.should be < ConcreteClass
      end

      it "is instantiable" do
        ConcreteClassMock.new.should be_a(ConcreteClass)
      end

      context "with stubs defined by keyword arguments" do
        it "changes behavior of an untyped method" do
          mock = ConcreteClassMock.new
          mock.simple_untyped_method.should eq(:mock)
        end

        it "can redefine behavior of an untyped method" do
          mock = ConcreteClassMock.new
          define_stubs(mock, simple_untyped_method: :override)
          mock.simple_untyped_method.should eq(:override)
        end

        it "raises when the stubbed type doesn't match the original" do
          mock = ConcreteClassMock.new
          define_stubs(mock, simple_untyped_method: 42)
          expect_raises(TypeCastError, /Symbol/) { mock.simple_untyped_method }
        end

        it "changes behavior of a typed method" do
          mock = ConcreteClassMock.new
          mock.simple_typed_method.should eq(:mock)
        end

        it "can redefine behavior of an untyped method" do
          mock = ConcreteClassMock.new
          define_stubs(mock, simple_typed_method: :override)
          mock.simple_typed_method.should eq(:override)
        end

        it "raises when the stubbed type doesn't match the original" do
          mock = ConcreteClassMock.new
          define_stubs(mock, simple_typed_method: 42)
          expect_raises(TypeCastError, /Symbol/) { mock.simple_typed_method }
        end
      end
    end
  end
end
