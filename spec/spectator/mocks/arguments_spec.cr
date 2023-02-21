require "../../spec_helper"

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
