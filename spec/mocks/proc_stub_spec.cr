require "../spec_helper"

private def create_stub(value = 42, args = nil)
  Mocks::ProcStub.new(:test_method, args) { value }
end

private def no_args
  Mocks::Arguments.none
end

describe Mocks::ProcStub do
  it "sets the attributes" do
    args = Mocks::ArgumentsPattern.build(42)
    stub = Mocks::ProcStub.new(:test_method, ->{ :xyz }, args)

    stub.method_name.should eq(:test_method)
    stub.arguments.should be(args)
  end

  describe "#call" do
    it "returns the proc's return value" do
      stub = create_stub
      stub.call(no_args) { 0 }.should eq(42)
    end

    it "raises when return type can't be cast" do
      stub = create_stub
      expect_raises(TypeCastError, /Int32/) do
        stub.call(no_args) { :xyz }
      end
    end

    it "supports union types" do
      stub = create_stub
      stub.call(no_args) { "foo".as(String | Int32) }.should eq(42)
    end

    it "supports nilable types" do
      stub = create_stub
      stub.call(no_args) { 0.as(Int32?) }.should eq(42)
    end

    it "ignores the value for Nil types" do
      stub = create_stub
      stub.call(no_args) { nil }.should be_nil
    end

    it "calls the proc even though the return value is ignored (nil)" do
      called = false
      stub = Mocks::ProcStub.new(:test_method) { called = true }
      called.should be_false
      stub.call(no_args) { nil }.should be_nil
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
