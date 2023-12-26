require "../spec_helper"

private def create_test_args(args = NamedTuple.new, splat_name = :test_splat, splat = nil, kwargs = NamedTuple.new)
  Mocks::Arguments.new(args, splat ? splat_name : nil, splat, kwargs)
end

private def capture0
  Mocks::Arguments.capture
end

private def capture1(arg1, arg2, arg3)
  Mocks::Arguments.capture
end

private def capture2(arg1, arg2, arg3, **captured_double_splat)
  Mocks::Arguments.capture
end

private def capture3(arg1, arg2, arg3, *captured_splat)
  Mocks::Arguments.capture
end

private def capture4(arg1, arg2, arg3, *captured_splat, **captured_double_splat)
  Mocks::Arguments.capture
end

private def capture5(*captured_splat)
  Mocks::Arguments.capture
end

private def capture6(*captured_splat, **captured_double_splat)
  Mocks::Arguments.capture
end

private def capture7(*captured_splat, kwarg1, kwarg2)
  Mocks::Arguments.capture
end

private def capture8(*captured_splat, kwarg1, kwarg2, **captured_double_splat)
  Mocks::Arguments.capture
end

private def capture9(*, kwarg1, kwarg2)
  Mocks::Arguments.capture
end

private def capture10(*, kwarg1, kwarg2, **captured_double_splat)
  Mocks::Arguments.capture
end

private def capture11(arg1, arg2, *, kwarg1, kwarg2)
  Mocks::Arguments.capture
end

private def capture12(arg1, arg2, *, kwarg1, kwarg2, **captured_double_splat)
  Mocks::Arguments.capture
end

private def capture13(arg1, arg2, *captured_splat, kwarg1, kwarg2)
  Mocks::Arguments.capture
end

private def capture14(arg1, arg2, *captured_splat, kwarg1, kwarg2, **captured_double_splat)
  Mocks::Arguments.capture
end

describe Mocks::Arguments do
  it "sets attributes" do
    args = {arg: 42}
    splat_name = :test_splat
    splat = {"foo", :xyz}
    kwargs = {extra: "value"}

    arguments = Mocks::Arguments.new(args, splat_name, splat, kwargs)
    arguments.args.should eq(args)
    arguments.splat_name.should eq(splat_name)
    arguments.splat.should eq(splat)
    arguments.kwargs.should eq(kwargs)
  end

  describe ".none" do
    it "returns arguments with empty attributes" do
      none = Mocks::Arguments.none
      none.args.empty?.should be_true
      none.splat_name.should be_nil
      none.splat.should be_nil
      none.kwargs.empty?.should be_true
    end
  end

  describe ".any" do
    it "returns a value indicating 'any arguments' to a stub" do
      any = Mocks::Arguments.any
      stub = Mocks::NilStub.new(:test, any)
      call = Mocks::Call.new(:test)
      (stub === call).should be_true
    end
  end

  describe ".capture" do
    it "captures empty arguments" do
      arguments = capture0
      arguments.args.should eq(NamedTuple.new)
      arguments.splat_name.should be_nil
      arguments.splat.should be_nil
      arguments.kwargs.should eq(NamedTuple.new)
    end

    it "captures positional arguments" do
      arguments = capture1(1, 2, 3)
      arguments.args.should eq({arg1: 1, arg2: 2, arg3: 3})
      arguments.splat_name.should be_nil
      arguments.splat.should be_nil
      arguments.kwargs.should eq(NamedTuple.new)
    end

    it "captures positional arguments and a double splat" do
      arguments = capture2(1, 2, 3, extra: 4, additional: 5)
      arguments.args.should eq({arg1: 1, arg2: 2, arg3: 3})
      arguments.splat_name.should be_nil
      arguments.splat.should be_nil
      arguments.kwargs.should eq({extra: 4, additional: 5})
    end

    it "captures positional arguments and a splat" do
      arguments = capture3(1, 2, 3, 4, 5, 6)
      arguments.args.should eq({arg1: 1, arg2: 2, arg3: 3})
      arguments.splat_name.should eq(:captured_splat)
      arguments.splat.should eq({4, 5, 6})
      arguments.kwargs.should eq(NamedTuple.new)
    end

    it "captures positional arguments, a splat, and a double splat" do
      arguments = capture4(1, 2, 3, 4, 5, 6, extra: 7, additional: 8)
      arguments.args.should eq({arg1: 1, arg2: 2, arg3: 3})
      arguments.splat_name.should eq(:captured_splat)
      arguments.splat.should eq({4, 5, 6})
      arguments.kwargs.should eq({extra: 7, additional: 8})
    end

    it "captures a splat" do
      arguments = capture5(1, 2, 3)
      arguments.args.should eq(NamedTuple.new)
      arguments.splat_name.should eq(:captured_splat)
      arguments.splat.should eq({1, 2, 3})
      arguments.kwargs.should eq(NamedTuple.new)
    end

    it "captures a splat and double splat" do
      arguments = capture6(1, 2, 3, extra: 4, another: 5)
      arguments.args.should eq(NamedTuple.new)
      arguments.splat_name.should eq(:captured_splat)
      arguments.splat.should eq({1, 2, 3})
      arguments.kwargs.should eq({extra: 4, another: 5})
    end

    it "captures a splat and keyword arguments" do
      arguments = capture7(1, 2, 3, kwarg1: 4, kwarg2: 5)
      arguments.args.should eq(NamedTuple.new)
      arguments.splat_name.should eq(:captured_splat)
      arguments.splat.should eq({1, 2, 3})
      arguments.kwargs.should eq({kwarg1: 4, kwarg2: 5})
    end

    it "captures a splat, keyword arguments, and a double splat" do
      arguments = capture8(1, 2, 3, kwarg1: 4, kwarg2: 5, additional: 6, more: 7)
      arguments.args.should eq(NamedTuple.new)
      arguments.splat_name.should eq(:captured_splat)
      arguments.splat.should eq({1, 2, 3})
      arguments.kwargs.should eq({kwarg1: 4, kwarg2: 5, additional: 6, more: 7})
    end

    it "captures keyword arguments" do
      arguments = capture9(kwarg1: 42, kwarg2: 0)
      arguments.args.should eq(NamedTuple.new)
      arguments.splat_name.should be_nil
      arguments.splat.should be_nil
      arguments.kwargs.should eq({kwarg1: 42, kwarg2: 0})
    end

    it "captures keyword arguments and a double splat" do
      arguments = capture10(kwarg1: 42, kwarg2: 0, additional: 1, more: 2)
      arguments.args.should eq(NamedTuple.new)
      arguments.splat_name.should be_nil
      arguments.splat.should be_nil
      arguments.kwargs.should eq({kwarg1: 42, kwarg2: 0, additional: 1, more: 2})
    end

    it "captures positional arguments and keyword arguments" do
      arguments = capture11(42, 0, kwarg1: 1, kwarg2: 2)
      arguments.args.should eq({arg1: 42, arg2: 0})
      arguments.splat_name.should be_nil
      arguments.splat.should be_nil
      arguments.kwargs.should eq({kwarg1: 1, kwarg2: 2})
    end

    it "captures positional arguments, keyword arguments, and a double splat" do
      arguments = capture12(42, 0, kwarg1: 1, kwarg2: 2, additional: 3, more: 4)
      arguments.args.should eq({arg1: 42, arg2: 0})
      arguments.splat_name.should be_nil
      arguments.splat.should be_nil
      arguments.kwargs.should eq({kwarg1: 1, kwarg2: 2, additional: 3, more: 4})
    end

    it "captures positional arguments, a splat, and keyword arguments" do
      arguments = capture14(1, 2, 3, 4, kwarg1: 5, kwarg2: 6)
      arguments.args.should eq({arg1: 1, arg2: 2})
      arguments.splat_name.should eq(:captured_splat)
      arguments.splat.should eq({3, 4})
      arguments.kwargs.should eq({kwarg1: 5, kwarg2: 6})
    end

    it "captures all parameter types" do
      arguments = capture14(1, 2, 3, 4, kwarg1: 5, kwarg2: 6, additional: 7, more: 8)
      arguments.args.should eq({arg1: 1, arg2: 2})
      arguments.splat_name.should eq(:captured_splat)
      arguments.splat.should eq({3, 4})
      arguments.kwargs.should eq({kwarg1: 5, kwarg2: 6, additional: 7, more: 8})
    end
  end

  describe "#positional" do
    context "with only positional arguments and no splat" do
      it "returns the positional arguments" do
        arguments = create_test_args({arg1: 1, arg2: 2, arg3: 3})
        arguments.positional.should eq({1, 2, 3})
      end
    end

    context "with positional arguments and a splat" do
      it "returns the positional and splat arguments" do
        arguments = create_test_args({arg1: 1, arg2: 2, arg3: 3}, splat: {4, 5, 6})
        arguments.positional.should eq({1, 2, 3, 4, 5, 6})
      end
    end

    context "with only a splat" do
      it "returns the splat arguments" do
        arguments = create_test_args(splat: {1, 2, 3})
        arguments.positional.should eq({1, 2, 3})
      end
    end

    context "with only keyword arguments" do
      it "returns an empty tuple" do
        arguments = create_test_args(kwargs: {extra: 42, another: 0})
        arguments.positional.should eq(Tuple.new)
      end
    end

    context "with positional arguments and keyword arguments" do
      it "returns only the positional arguments" do
        arguments = create_test_args({arg1: 42, arg2: 0}, kwargs: {extra: 1, another: 2})
        arguments.positional.should eq({42, 0})
      end
    end

    context "with all parameter types" do
      it "returns the positional and splat arguments" do
        arguments = create_test_args({arg1: 1, arg2: 2}, splat: {3, 4}, kwargs: {extra: 5, another: 6})
        arguments.positional.should eq({1, 2, 3, 4})
      end
    end
  end

  describe "#named" do
    context "with only positional arguments and no splat" do
      it "returns the positional arguments" do
        arguments = create_test_args({arg1: 1, arg2: 2, arg3: 3})
        arguments.named.should eq({arg1: 1, arg2: 2, arg3: 3})
      end
    end

    context "with positional arguments and a splat" do
      it "returns only the positional arguments" do
        arguments = create_test_args({arg1: 1, arg2: 2, arg3: 3}, splat: {4, 5, 6})
        arguments.named.should eq({arg1: 1, arg2: 2, arg3: 3})
      end
    end

    context "with only a splat" do
      it "returns an empty tuple" do
        arguments = create_test_args(splat: {1, 2, 3})
        arguments.named.should eq(NamedTuple.new)
      end
    end

    context "with only keyword arguments" do
      it "returns the keyword arguments" do
        arguments = create_test_args(kwargs: {extra: 42, another: 0})
        arguments.named.should eq({extra: 42, another: 0})
      end
    end

    context "with positional arguments and keyword arguments" do
      it "returns only the positional and keyword arguments" do
        arguments = create_test_args({arg1: 42, arg2: 0}, kwargs: {extra: 1, another: 2})
        arguments.named.should eq({arg1: 42, arg2: 0, extra: 1, another: 2})
      end
    end

    context "with all parameter types" do
      it "returns the positional and keyword arguments" do
        arguments = create_test_args({arg1: 1, arg2: 2}, splat: {3, 4}, kwargs: {extra: 5, another: 6})
        arguments.named.should eq({arg1: 1, arg2: 2, extra: 5, another: 6})
      end
    end
  end

  describe "#[]" do
    context "with only positional arguments and no splat" do
      context "with an index" do
        it "can return a positional argument" do
          arguments = create_test_args({arg1: 1, arg2: 2, arg3: 3})
          arguments[1].should eq(2)
        end

        it "raises IndexError with an out-of-bounds index" do
          arguments = create_test_args({arg1: 1})
          expect_raises(IndexError) { arguments[1] }
        end
      end

      context "with a name" do
        it "can return a positional argument" do
          arguments = create_test_args({arg1: 1, arg2: 2, arg3: 3})
          arguments[:arg2].should eq(2)
        end

        it "raises KeyError with an unknown argument name" do
          arguments = create_test_args({arg1: 1})
          expect_raises(KeyError, /foo/) { arguments[:foo] }
        end
      end
    end

    context "with positional arguments and a splat" do
      context "with an index" do
        it "can return a positional argument" do
          arguments = create_test_args({arg1: 1, arg2: 2}, splat: {3, 4})
          arguments[1].should eq(2)
        end

        it "can return a splat argument" do
          arguments = create_test_args({arg1: 1, arg2: 2}, splat: {3, 4})
          arguments[3].should eq(4)
        end

        it "raises IndexError with an out-of-bounds index" do
          arguments = create_test_args({arg1: 1, arg2: 2}, splat: {3, 4})
          expect_raises(IndexError) { arguments[4] }
        end
      end

      context "with a name" do
        it "can return a positional argument" do
          arguments = create_test_args({arg1: 1, arg2: 2}, splat: {3, 4})
          arguments[:arg2].should eq(2)
        end

        it "raises KeyError with an unknown argument name" do
          arguments = create_test_args({arg1: 1, arg2: 2}, splat: {3, 4})
          expect_raises(KeyError, /foo/) { arguments[:foo] }
        end
      end
    end

    context "with only a splat" do
      context "with an index" do
        it "can return a splat argument" do
          arguments = create_test_args(splat: {1, 2, 3})
          arguments[1].should eq(2)
        end

        it "raises IndexError with an out-of-bounds index" do
          arguments = create_test_args(splat: {1, 2, 3})
          expect_raises(IndexError) { arguments[3] }
        end
      end

      context "with a name" do
        it "raises a KeyError" do
          arguments = create_test_args(splat: {1, 2, 3})
          expect_raises(KeyError, /foo/) { arguments[:foo] }
        end
      end
    end

    context "with only keyword arguments" do
      context "with an index" do
        it "raises an IndexError" do
          arguments = create_test_args(kwargs: {extra: 1, another: 42})
          expect_raises(IndexError) { arguments[0] }
        end
      end

      context "with a name" do
        it "can return a keyword argument" do
          arguments = create_test_args(kwargs: {extra: 1, another: 42})
          arguments[:extra].should eq(1)
        end

        it "raises KeyError with an unknown argument name" do
          arguments = create_test_args(kwargs: {extra: 1, another: 42})
          expect_raises(KeyError, /foo/) { arguments[:foo] }
        end
      end
    end

    context "with positional arguments and keyword arguments" do
      context "with an index" do
        it "can return a positional argument" do
          arguments = create_test_args({arg1: 1, arg2: 2}, kwargs: {extra: 3, another: 4})
          arguments[1].should eq(2)
        end

        it "raises an IndexError for an out-of-bounds index" do
          arguments = create_test_args({arg1: 1, arg2: 2}, kwargs: {extra: 3, another: 4})
          expect_raises(IndexError) { arguments[2] }
        end
      end

      context "with a name" do
        it "can return a positional argument" do
          arguments = create_test_args({arg1: 1, arg2: 2}, kwargs: {extra: 3, another: 4})
          arguments[:arg2].should eq(2)
        end

        it "can return a keyword argument" do
          arguments = create_test_args({arg1: 1, arg2: 2}, kwargs: {extra: 3, another: 4})
          arguments[:extra].should eq(3)
        end

        it "raises KeyError with an unknown argument name" do
          arguments = create_test_args({arg1: 1, arg2: 2}, kwargs: {extra: 3, another: 4})
          expect_raises(KeyError, /foo/) { arguments[:foo] }
        end
      end
    end

    context "with all parameter types" do
      context "with an index" do
        it "can return a positional argument" do
          arguments = create_test_args({arg1: 1, arg2: 2}, splat: {3, 4}, kwargs: {extra: 5, another: 6})
          arguments[1].should eq(2)
        end

        it "can return a splat argument" do
          arguments = create_test_args({arg1: 1, arg2: 2}, splat: {3, 4}, kwargs: {extra: 5, another: 6})
          arguments[2].should eq(3)
        end

        it "raises IndexError for an out-of-bounds index" do
          arguments = create_test_args({arg1: 1, arg2: 2}, splat: {3, 4}, kwargs: {extra: 5, another: 6})
          expect_raises(IndexError) { arguments[4] }
        end
      end

      context "with a name" do
        it "can return a positional argument" do
          arguments = create_test_args({arg1: 1, arg2: 2}, splat: {3, 4}, kwargs: {extra: 5, another: 6})
          arguments[:arg2].should eq(2)
        end

        it "can return a keyword argument" do
          arguments = create_test_args({arg1: 1, arg2: 2}, splat: {3, 4}, kwargs: {extra: 5, another: 6})
          arguments[:another].should eq(6)
        end

        it "raises KeyError for an unknown argument name" do
          arguments = create_test_args({arg1: 1, arg2: 2}, splat: {3, 4}, kwargs: {extra: 5, another: 6})
          expect_raises(KeyError, /foo/) { arguments[:foo] }
        end
      end
    end
  end

  describe "#to_s" do
    it "returns '(no args)' for no arguments" do
      none = Mocks::Arguments.none
      none.to_s.should eq("(no args)")
    end

    context "with only positional arguments and no splat" do
      it "is formatted correctly" do
        arguments = create_test_args({arg1: 1, arg2: 2, arg3: 3})
        arguments.to_s.should eq("(1, 2, 3)")
      end

      it "uses the 'inspect' format" do
        arguments = create_test_args({arg: "foo"})
        arguments.to_s.should eq(%[("foo")])
      end
    end

    context "with positional arguments and a splat" do
      it "is formatted correctly" do
        arguments = create_test_args({arg1: 1, arg2: 2, arg3: 3}, splat: {4, 5, 6})
        arguments.to_s.should eq("(1, 2, 3, 4, 5, 6)")
      end

      it "uses the 'inspect' format" do
        arguments = create_test_args({arg: "foo"}, splat: {:x})
        arguments.to_s.should eq(%[("foo", :x)])
      end
    end

    context "with only a splat" do
      it "is formatted correctly" do
        arguments = create_test_args(splat: {1, 2, 3})
        arguments.to_s.should eq("(1, 2, 3)")
      end

      it "uses the 'inspect' format" do
        arguments = create_test_args(splat: {"foo"})
        arguments.to_s.should eq(%[("foo")])
      end
    end

    context "with only keyword arguments" do
      it "is formatted correctly" do
        arguments = create_test_args(kwargs: {extra: 42, another: 0})
        arguments.to_s.should eq("(extra: 42, another: 0)")
      end

      it "uses the 'inspect' format" do
        arguments = create_test_args(kwargs: {extra: "value"})
        arguments.to_s.should eq(%[(extra: "value")])
      end
    end

    context "with positional and keyword arguments" do
      it "is formatted correctly" do
        arguments = create_test_args({arg1: 42, arg2: 0}, kwargs: {extra: 1, another: 2})
        arguments.to_s.should eq("(42, 0, extra: 1, another: 2)")
      end

      it "uses the 'inspect' format" do
        arguments = create_test_args({arg1: "foo"}, kwargs: {extra: :xyz})
        arguments.to_s.should eq(%[("foo", extra: :xyz)])
      end
    end

    context "with a splat and keyword arguments" do
      it "is formatted correctly" do
        arguments = create_test_args(splat: {1, 2, 3}, kwargs: {extra: 4, another: 5})
        arguments.to_s.should eq("(1, 2, 3, extra: 4, another: 5)")
      end

      it "uses the 'inspect' format" do
        arguments = create_test_args(splat: {"foo"}, kwargs: {extra: :xyz})
        arguments.to_s.should eq(%[("foo", extra: :xyz)])
      end
    end

    context "with all parameter types" do
      it "is formatted correctly" do
        arguments = create_test_args({arg1: 1, arg2: 2}, splat: {3, 4}, kwargs: {extra: 5, another: 6})
        arguments.to_s.should eq("(1, 2, 3, 4, extra: 5, another: 6)")
      end

      it "uses the 'inspect' format" do
        arguments = create_test_args({arg1: "foo"}, splat: {:xyz}, kwargs: {extra: nil})
        arguments.to_s.should eq(%[("foo", :xyz, extra: nil)])
      end
    end
  end

  describe "#empty?" do
    it "returns true for no arguments" do
      none = Mocks::Arguments.none
      none.empty?.should be_true
    end

    it "returns false for populated arguments" do
      arguments = Mocks::Arguments.new({arg: 42}, :test_splat, {"foo", :xyz}, {extra: "value"})
      arguments.empty?.should be_false
    end
  end

  describe "#==" do
    it "returns true for equal arguments" do
      args = {arg: 42}
      splat_name = :test_splat
      splat = {"foo", :xyz}
      kwargs = {extra: "value"}

      arguments1 = Mocks::Arguments.new(args, splat_name, splat, kwargs)
      arguments2 = Mocks::Arguments.new(args, splat_name, splat, kwargs)
      arguments1.should eq(arguments2)
    end

    it "returns false for unequal arguments" do
      arguments1 = Mocks::Arguments.new({arg: 42}, :test_splat, {"foo", :xyz}, {extra: "value"})
      arguments2 = Mocks::Arguments.new({arg: 0}, :test_splat, Tuple.new, {other: "value"})
      arguments1.should_not eq(arguments2)
    end
  end
end
