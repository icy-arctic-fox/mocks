require "../../spec_helper"

private def create_stub(args = nil)
  Spectator::Mocks::NilStub.new(:test_method, args)
end

private def no_args
  Spectator::Mocks::Arguments.none
end

describe Spectator::Mocks::NilStub do
  it "sets the attributes" do
    args = Spectator::Mocks::ArgumentsPattern.build(42)
    stub = Spectator::Mocks::NilStub.new(:test_method, args)

    stub.method_name.should eq(:test_method)
    stub.arguments.should be(args)
  end

  describe "#call" do
    it "returns nil" do
      stub = create_stub
      stub.call(no_args) { nil }.should be_nil
    end

    it "raises when return type can't be nil" do
      stub = create_stub
      expect_raises(TypeCastError, /nil/) do
        stub.call(no_args) { 42 }
      end
    end

    it "supports nilable types" do
      stub = create_stub
      stub.call(no_args) { 42.as(Int32?) }.should be_nil
    end
  end

  describe "#with" do
    it "sets the arguments pattern" do
      stub = create_stub.with(42)
      stub.arguments.to_s.should eq("(42)")
    end
  end
end
