require "../../spec_helper"

describe Mocks::DSL do
  describe "#anything" do
    it "returns a object that equals any value" do
      anything.should eq("foo")
    end

    it "can be used to match arguments" do
      double = new_double(foo: "bar")
      double.can receive(:foo).with(anything).and_return "baz"
      double.foo(42).should eq("baz")
    end
  end
end
