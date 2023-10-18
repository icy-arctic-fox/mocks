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

private double ArgumentsDouble do
  def no_args
    0
  end

  def positional(arg1, arg2)
    0
  end

  def keywords(*, key1, key2)
    0
  end

  def splat(*args)
    0
  end

  def double_splat(**kwargs)
    0
  end

  def mixed(arg1, arg2, *args, key1, key2, **kwargs)
    0
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

private class ArgumentsClass
  def no_args
    0
  end

  def positional(arg1, arg2)
    0
  end

  def keywords(*, key1, key2)
    0
  end

  def splat(*args)
    0
  end

  def double_splat(**kwargs)
    0
  end

  def mixed(arg1, arg2, *args, key1, key2, **kwargs)
    0
  end
end

private mock ArgumentsClassMock < ArgumentsClass

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

      describe "#with (no block)" do
        context "positional arguments" do
          it "modifies the accepted arguments" do
            double = ArgumentsDouble.new
            allow(double).to receive(:positional).with(1, 2).and_return(5)
            double.positional(1, 2).should eq(5)
            double.positional(3, 4).should eq(0)
          end

          it "supports case equality" do
            double = ArgumentsDouble.new
            allow(double).to receive(:positional).with(Int32, ->(x : Int32) { x.even? }).and_return(5)
            double.positional(1, 2).should eq(5)
            double.positional("Test", 3).should eq(0)
          end
        end

        context "keyword arguments" do
          it "modifies the accepted arguments" do
            double = ArgumentsDouble.new
            allow(double).to receive(:keywords).with(key1: 1, key2: 2).and_return(5)
            double.keywords(key1: 1, key2: 2).should eq(5)
            double.keywords(key1: 3, key2: 4).should eq(0)
          end

          it "supports case equality" do
            double = ArgumentsDouble.new
            allow(double).to receive(:keywords).with(key1: Int32, key2: ->(x : Int32) { x.even? }).and_return(5)
            double.keywords(key1: 1, key2: 2).should eq(5)
            double.keywords(key1: "Test", key2: 3).should eq(0)
          end
        end

        context "splat arguments" do
          it "modifies the accepted arguments" do
            double = ArgumentsDouble.new
            allow(double).to receive(:splat).with(1, 2).and_return(5)
            double.splat(1, 2).should eq(5)
            double.splat(3, 4).should eq(0)
          end

          it "supports case equality" do
            double = ArgumentsDouble.new
            allow(double).to receive(:splat).with(Int32, ->(x : Int32) { x.even? }).and_return(5)
            double.splat(1, 2).should eq(5)
            double.splat("Test", 3).should eq(0)
          end
        end

        context "double splat arguments" do
          it "modifies the accepted arguments" do
            double = ArgumentsDouble.new
            allow(double).to receive(:double_splat).with(key1: 1, key2: 2).and_return(5)
            double.double_splat(key1: 1, key2: 2).should eq(5)
            double.double_splat(key1: 3, key2: 4).should eq(0)
          end

          it "supports case equality" do
            double = ArgumentsDouble.new
            allow(double).to receive(:double_splat).with(key1: Int32, key2: ->(x : Int32) { x.even? }).and_return(5)
            double.double_splat(key1: 1, key2: 2).should eq(5)
            double.double_splat(key1: "Test", key2: 3).should eq(0)
          end
        end

        context "mixed arguments" do
          it "modifies the accepted arguments" do
            double = ArgumentsDouble.new
            allow(double).to receive(:mixed).with(1, 2, 3, 4, key1: 5, key2: 6, key3: 7, key4: 8).and_return(5)
            double.mixed(1, 2, 3, 4, key1: 5, key2: 6, key3: 7, key4: 8).should eq(5)
            double.mixed(3, 4, 5, 6, key1: 7, key2: 8, key3: 9, key4: 0).should eq(0)
          end

          it "supports case equality" do
            double = ArgumentsDouble.new
            is_even = ->(x : Int32) { x.even? }
            allow(double).to receive(:mixed).with(Int32, is_even, String, /test/i, key1: Int, key2: is_even, key3: Object, key4: /test/i).and_return(5)
            double.mixed(1, 2, "Test", "Test", key1: 5, key2: 6, key3: "Test", key4: "Test").should eq(5)
            double.mixed("Test", "Test", 1, 2, key1: "Test", key2: "Test", key3: 3, key4: 4).should eq(0)
          end
        end
      end

      describe "#with (block)" do
        context "positional arguments" do
          it "modifies the accepted arguments" do
            double = ArgumentsDouble.new
            allow(double).to receive(:positional).with(1, 2) { 5 }
            double.positional(1, 2).should eq(5)
            double.positional(3, 4).should eq(0)
          end

          it "supports case equality" do
            double = ArgumentsDouble.new
            allow(double).to receive(:positional).with(Int32, ->(x : Int32) { x.even? }) { 5 }
            double.positional(1, 2).should eq(5)
            double.positional("Test", 3).should eq(0)
          end
        end

        context "keyword arguments" do
          it "modifies the accepted arguments" do
            double = ArgumentsDouble.new
            allow(double).to receive(:keywords).with(key1: 1, key2: 2) { 5 }
            double.keywords(key1: 1, key2: 2).should eq(5)
            double.keywords(key1: 3, key2: 4).should eq(0)
          end

          it "supports case equality" do
            double = ArgumentsDouble.new
            allow(double).to receive(:keywords).with(key1: Int32, key2: ->(x : Int32) { x.even? }) { 5 }
            double.keywords(key1: 1, key2: 2).should eq(5)
            double.keywords(key1: "Test", key2: 3).should eq(0)
          end
        end

        context "splat arguments" do
          it "modifies the accepted arguments" do
            double = ArgumentsDouble.new
            allow(double).to receive(:splat).with(1, 2) { 5 }
            double.splat(1, 2).should eq(5)
            double.splat(3, 4).should eq(0)
          end

          it "supports case equality" do
            double = ArgumentsDouble.new
            allow(double).to receive(:splat).with(Int32, ->(x : Int32) { x.even? }) { 5 }
            double.splat(1, 2).should eq(5)
            double.splat("Test", 3).should eq(0)
          end
        end

        context "double splat arguments" do
          it "modifies the accepted arguments" do
            double = ArgumentsDouble.new
            allow(double).to receive(:double_splat).with(key1: 1, key2: 2) { 5 }
            double.double_splat(key1: 1, key2: 2).should eq(5)
            double.double_splat(key1: 3, key2: 4).should eq(0)
          end

          it "supports case equality" do
            double = ArgumentsDouble.new
            allow(double).to receive(:double_splat).with(key1: Int32, key2: ->(x : Int32) { x.even? }) { 5 }
            double.double_splat(key1: 1, key2: 2).should eq(5)
            double.double_splat(key1: "Test", key2: 3).should eq(0)
          end
        end

        context "mixed arguments" do
          it "modifies the accepted arguments" do
            double = ArgumentsDouble.new
            allow(double).to receive(:mixed).with(1, 2, 3, 4, key1: 5, key2: 6, key3: 7, key4: 8) { 5 }
            double.mixed(1, 2, 3, 4, key1: 5, key2: 6, key3: 7, key4: 8).should eq(5)
            double.mixed(3, 4, 5, 6, key1: 7, key2: 8, key3: 9, key4: 0).should eq(0)
          end

          it "supports case equality" do
            double = ArgumentsDouble.new
            is_even = ->(x : Int32) { x.even? }
            allow(double).to receive(:mixed).with(Int32, is_even, String, /test/i, key1: Int, key2: is_even, key3: Object, key4: /test/i) { 5 }
            double.mixed(1, 2, "Test", "Test", key1: 5, key2: 6, key3: "Test", key4: "Test").should eq(5)
            double.mixed("Test", "Test", 1, 2, key1: "Test", key2: "Test", key3: 3, key4: 4).should eq(0)
          end
        end
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

      describe "#with (no block)" do
        context "positional arguments" do
          it "modifies the accepted arguments" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:positional).with(1, 2).and_return(5)
            mock.positional(1, 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.positional(3, 4)
            end
          end

          it "supports case equality" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:positional).with(Int32, ->(x : Int32) { x.even? }).and_return(5)
            mock.positional(1, 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.positional("Test", 3)
            end
          end
        end

        context "keyword arguments" do
          it "modifies the accepted arguments" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:keywords).with(key1: 1, key2: 2).and_return(5)
            mock.keywords(key1: 1, key2: 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.keywords(key1: 3, key2: 4)
            end
          end

          it "supports case equality" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:keywords).with(key1: Int32, key2: ->(x : Int32) { x.even? }).and_return(5)
            mock.keywords(key1: 1, key2: 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.keywords(key1: "Test", key2: 3)
            end
          end
        end

        context "splat arguments" do
          it "modifies the accepted arguments" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:splat).with(1, 2).and_return(5)
            mock.splat(1, 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.splat(3, 4)
            end
          end

          it "supports case equality" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:splat).with(Int32, ->(x : Int32) { x.even? }).and_return(5)
            mock.splat(1, 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.splat("Test", 3)
            end
          end
        end

        context "double splat arguments" do
          it "modifies the accepted arguments" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:double_splat).with(key1: 1, key2: 2).and_return(5)
            mock.double_splat(key1: 1, key2: 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.double_splat(key1: 3, key2: 4)
            end
          end

          it "supports case equality" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:double_splat).with(key1: Int32, key2: ->(x : Int32) { x.even? }).and_return(5)
            mock.double_splat(key1: 1, key2: 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.double_splat(key1: "Test", key2: 3)
            end
          end
        end

        context "mixed arguments" do
          it "modifies the accepted arguments" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:mixed).with(1, 2, 3, 4, key1: 5, key2: 6, key3: 7, key4: 8).and_return(5)
            mock.mixed(1, 2, 3, 4, key1: 5, key2: 6, key3: 7, key4: 8).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.mixed(3, 4, 5, 6, key1: 7, key2: 8, key3: 9, key4: 0)
            end
          end

          it "supports case equality" do
            mock = ArgumentsClassMock.new
            is_even = ->(x : Int32) { x.even? }
            allow(mock).to receive(:mixed).with(Int32, is_even, String, /test/i, key1: Int, key2: is_even, key3: Object, key4: /test/i).and_return(5)
            mock.mixed(1, 2, "Test", "Test", key1: 5, key2: 6, key3: "Test", key4: "Test").should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.mixed("Test", "Test", 1, 2, key1: "Test", key2: "Test", key3: 3, key4: 4)
            end
          end
        end
      end

      describe "#with (block)" do
        context "positional arguments" do
          it "modifies the accepted arguments" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:positional).with(1, 2) { 5 }
            mock.positional(1, 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.positional(3, 4)
            end
          end

          it "supports case equality" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:positional).with(Int32, ->(x : Int32) { x.even? }) { 5 }
            mock.positional(1, 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.positional("Test", 3)
            end
          end
        end

        context "keyword arguments" do
          it "modifies the accepted arguments" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:keywords).with(key1: 1, key2: 2) { 5 }
            mock.keywords(key1: 1, key2: 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.keywords(key1: 3, key2: 4)
            end
          end

          it "supports case equality" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:keywords).with(key1: Int32, key2: ->(x : Int32) { x.even? }) { 5 }
            mock.keywords(key1: 1, key2: 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.keywords(key1: "Test", key2: 3)
            end
          end
        end

        context "splat arguments" do
          it "modifies the accepted arguments" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:splat).with(1, 2) { 5 }
            mock.splat(1, 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.splat(3, 4)
            end
          end

          it "supports case equality" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:splat).with(Int32, ->(x : Int32) { x.even? }) { 5 }
            mock.splat(1, 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.splat("Test", 3)
            end
          end
        end

        context "double splat arguments" do
          it "modifies the accepted arguments" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:double_splat).with(key1: 1, key2: 2) { 5 }
            mock.double_splat(key1: 1, key2: 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.double_splat(key1: 3, key2: 4)
            end
          end

          it "supports case equality" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:double_splat).with(key1: Int32, key2: ->(x : Int32) { x.even? }) { 5 }
            mock.double_splat(key1: 1, key2: 2).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.double_splat(key1: "Test", key2: 3)
            end
          end
        end

        context "mixed arguments" do
          it "modifies the accepted arguments" do
            mock = ArgumentsClassMock.new
            allow(mock).to receive(:mixed).with(1, 2, 3, 4, key1: 5, key2: 6, key3: 7, key4: 8) { 5 }
            mock.mixed(1, 2, 3, 4, key1: 5, key2: 6, key3: 7, key4: 8).should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.mixed(3, 4, 5, 6, key1: 7, key2: 8, key3: 9, key4: 0)
            end
          end

          it "supports case equality" do
            mock = ArgumentsClassMock.new
            is_even = ->(x : Int32) { x.even? }
            allow(mock).to receive(:mixed).with(Int32, is_even, String, /test/i, key1: Int, key2: is_even, key3: Object, key4: /test/i) { 5 }
            mock.mixed(1, 2, "Test", "Test", key1: 5, key2: 6, key3: "Test", key4: "Test").should eq(5)
            expect_raises(Spectator::Mocks::UnexpectedMessage) do
              mock.mixed("Test", "Test", 1, 2, key1: "Test", key2: "Test", key3: 3, key4: 4)
            end
          end
        end
      end
    end
  end
end
