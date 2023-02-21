require "../../spec_helper"

def create_test_args(args = NamedTuple.new, splat_name = :test_splat, splat = nil, kwargs = NamedTuple.new)
  Spectator::Mocks::Arguments.new(args, splat ? splat_name : nil, splat, kwargs)
end

describe Spectator::Mocks::Arguments do
  it "sets attributes" do
    args = {arg: 42}
    splat_name = :test_splat
    splat = {"foo", :xyz}
    kwargs = {extra: "value"}

    arguments = Spectator::Mocks::Arguments.new(args, splat_name, splat, kwargs)
    arguments.args.should eq(args)
    arguments.splat_name.should eq(splat_name)
    arguments.splat.should eq(splat)
    arguments.kwargs.should eq(kwargs)
  end

  describe ".none" do
    it "returns arguments with empty attributes" do
      none = Spectator::Mocks::Arguments.none
      none.args.empty?.should be_true
      none.splat_name.should be_nil
      none.splat.should be_nil
      none.kwargs.empty?.should be_true
    end
  end

  describe "#to_s" do
    it "returns '(no args)' for no arguments" do
      none = Spectator::Mocks::Arguments.none
      none.to_s.should eq("(no args)")
    end

    context "with only positional arguments and no splat" do
      it "is formatted correctly" do
        arguments = create_test_args({arg1: 1, arg2: 2, arg3: 3})
        arguments.to_s.should eq("(1, 2, 3)")
      end

      it "uses the 'inspect' format" do
        arguments = create_test_args({arg: "foo"})
        arguments.to_s.should eq("(\"foo\")")
      end
    end

    context "with positional arguments and a splat" do
      it "is formatted correctly" do
        arguments = create_test_args({arg1: 1, arg2: 2, arg3: 3}, splat: {4, 5, 6})
        arguments.to_s.should eq("(1, 2, 3, 4, 5, 6)")
      end

      it "uses the 'inspect' format" do
        arguments = create_test_args({arg: "foo"}, splat: {:x})
        arguments.to_s.should eq("(\"foo\", :x)")
      end
    end

    context "with only a splat" do
      it "is formatted correctly" do
        arguments = create_test_args(splat: {1, 2, 3})
        arguments.to_s.should eq("(1, 2, 3)")
      end

      it "uses the 'inspect' format" do
        arguments = create_test_args(splat: {"foo"})
        arguments.to_s.should eq("(\"foo\")")
      end
    end

    context "with only keyword arguments" do
      it "is formatted correctly" do
        arguments = create_test_args(kwargs: {extra: 42, another: 0})
        arguments.to_s.should eq("(extra: 42, another: 0)")
      end

      it "uses the 'inspect' format" do
        arguments = create_test_args(kwargs: {extra: "value"})
        arguments.to_s.should eq("(extra: \"value\")")
      end
    end

    context "with positional and keyword arguments" do
      it "is formatted correctly" do
        arguments = create_test_args({arg1: 42, arg2: 0}, kwargs: {extra: 1, another: 2})
        arguments.to_s.should eq("(42, 0, extra: 1, another: 2)")
      end

      it "uses the 'inspect' format" do
        arguments = create_test_args({arg1: "foo"}, kwargs: {extra: :xyz})
        arguments.to_s.should eq("(\"foo\", extra: :xyz)")
      end
    end

    context "with a splat and keyword arguments" do
      it "is formatted correctly" do
        arguments = create_test_args(splat: {1, 2, 3}, kwargs: {extra: 4, another: 5})
        arguments.to_s.should eq("(1, 2, 3, extra: 4, another: 5)")
      end

      it "uses the 'inspect' format" do
        arguments = create_test_args(splat: {"foo"}, kwargs: {extra: :xyz})
        arguments.to_s.should eq("(\"foo\", extra: :xyz)")
      end
    end

    context "with all parameter types" do
      it "is formatted correctly" do
        arguments = create_test_args({arg1: 1, arg2: 2}, splat: {3, 4}, kwargs: {extra: 5, another: 6})
        arguments.to_s.should eq("(1, 2, 3, 4, extra: 5, another: 6)")
      end

      it "uses the 'inspect' format" do
        arguments = create_test_args({arg1: "foo"}, splat: {:xyz}, kwargs: {extra: nil})
        arguments.to_s.should eq("(\"foo\", :xyz, extra: nil)")
      end
    end
  end

  describe "#empty?" do
    it "returns true for no arguments" do
      none = Spectator::Mocks::Arguments.none
      none.empty?.should be_true
    end

    it "returns false for populated arguments" do
      arguments = Spectator::Mocks::Arguments.new({arg: 42}, :test_splat, {"foo", :xyz}, {extra: "value"})
      arguments.empty?.should be_false
    end
  end

  describe "#==" do
    it "returns true for equal arguments" do
      args = {arg: 42}
      splat_name = :test_splat
      splat = {"foo", :xyz}
      kwargs = {extra: "value"}

      arguments1 = Spectator::Mocks::Arguments.new(args, splat_name, splat, kwargs)
      arguments2 = Spectator::Mocks::Arguments.new(args, splat_name, splat, kwargs)
      arguments1.should eq(arguments2)
    end

    it "returns false for unequal arguments" do
      args = {arg: 42}
      splat_name = :test_splat
      splat = {"foo", :xyz}
      kwargs = {extra: "value"}

      arguments1 = Spectator::Mocks::Arguments.new({arg: 42}, :test_splat, {"foo", :xyz}, {extra: "value"})
      arguments2 = Spectator::Mocks::Arguments.new({arg: 0}, :test_splat, Tuple.new, {other: "value"})
      arguments1.should_not eq(arguments2)
    end
  end
end
