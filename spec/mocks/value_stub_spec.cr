require "../spec_helper"

private def create_stub(value = 42, args = nil)
  Mocks::ValueStub.new(:test_method, value, args)
end

private def no_args
  Mocks::Arguments.none
end

describe Mocks::ValueStub do
  it "sets the attributes" do
    args = Mocks::ArgumentsPattern.build(42)
    stub = Mocks::ValueStub.new(:test_method, :xyz, args)

    stub.method_name.should eq(:test_method)
    stub.arguments.should be(args)
  end

  describe "#call" do
    it "returns the value" do
      stub = create_stub
      stub.call(no_args, Int32).should eq(42)
    end

    it "raises when return type doesn't match" do
      stub = create_stub
      expect_raises(TypeCastError, /Int32/) do
        stub.call(no_args, Symbol)
      end
    end

    it "supports union types" do
      stub = create_stub
      stub.call(no_args, String | Int32).should eq(42)
    end

    it "supports nilable types" do
      stub = create_stub
      stub.call(no_args, Int32?).should eq(42)
    end

    it "ignores the value for Nil types" do
      stub = create_stub
      stub.call(no_args, Nil).should be_nil
    end
  end

  describe "#with" do
    it "sets the arguments pattern" do
      stub = create_stub.with(42)
      stub.arguments.to_s.should eq("(42)")
    end
  end
end
