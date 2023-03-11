require "../../spec_helper"

private def create_stub(value = 42, args = nil)
  Spectator::Mocks::ValueStub.new(:test_method, value, args)
end

private def no_args
  Spectator::Mocks::Arguments.none
end

describe Spectator::Mocks::ValueStub do
  it "sets the attributes" do
    args = Spectator::Mocks::ArgumentsPattern.build(42)
    stub = Spectator::Mocks::ValueStub.new(:test_method, :xyz, args)

    stub.method_name.should eq(:test_method)
    stub.arguments.should be(args)
  end

  describe "#call" do
    it "returns the value" do
      stub = create_stub
      stub.call(no_args, Int32) { 0 }.should eq(42)
    end

    it "raises when return type doesn't match" do
      stub = create_stub
      expect_raises(TypeCastError, /Int32/) do
        stub.call(no_args, Symbol) { :xyz }
      end
    end

    it "supports union types" do
      stub = create_stub
      stub.call(no_args, String | Int32) { "foo".as(String | Int32) }.should eq(42)
    end

    it "supports nilable types" do
      stub = create_stub
      stub.call(no_args, Int32?) { 0.as(Int32?) }.should eq(42)
    end
  end
end
