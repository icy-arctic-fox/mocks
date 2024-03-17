require "../spec_helper"

private def create_stub(args = nil)
  Mocks::CallOriginalStub.new(:test_method, args)
end

private def no_args
  Mocks::Arguments.none
end

describe Mocks::ProcStub do
  it "sets the attributes" do
    args = Mocks::ArgumentsPattern.build(42)
    stub = Mocks::CallOriginalStub.new(:test_method, args)

    stub.method_name.should eq(:test_method)
    stub.arguments.should be(args)
  end

  describe "#call" do
    it "returns the block's return value" do
      stub = create_stub
      stub.call(no_args) { 42 }.should eq(42)
    end

    it "supports union types" do
      stub = create_stub
      stub.call(no_args) { "foo".as(String | Int32) }.should eq("foo")
    end

    it "supports nilable types" do
      stub = create_stub
      stub.call(no_args) { 42.as(Int32?) }.should eq(42)
    end

    it "ignores the value for Nil types" do
      stub = create_stub
      stub.call(no_args) { nil }.should be_nil
    end

    it "yields even though the return value is ignored (nil)" do
      called = false
      stub = ::Mocks::CallOriginalStub.new(:test_method)
      stub.call(no_args) { called = true; nil }.should be_nil
      called.should be_true
    end
  end

  describe "#with" do
    it "sets the arguments pattern" do
      stub = create_stub.with(42)
      stub.arguments.to_s.should eq("(42)")
    end
  end
end
