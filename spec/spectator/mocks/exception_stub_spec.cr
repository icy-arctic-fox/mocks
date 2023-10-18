require "../../spec_helper"

private def create_stub(exception = RuntimeError.new("Test exception"), args = nil)
  Spectator::Mocks::ExceptionStub.new(:test_method, exception, args)
end

private def no_args
  Spectator::Mocks::Arguments.none
end

describe Spectator::Mocks::ExceptionStub do
  it "sets the attributes" do
    args = Spectator::Mocks::ArgumentsPattern.build(42)
    stub = Spectator::Mocks::ExceptionStub.new(:test_method, RuntimeError.new, args)

    stub.method_name.should eq(:test_method)
    stub.arguments.should be(args)
  end

  describe "#call" do
    it "raises an exception" do
      exception = RuntimeError.new("Test exception")
      stub = create_stub(exception)
      expect_raises(RuntimeError, "Test exception") do
        stub.call(no_args) { 42 }
      end
    end

    it "compiles to the expected type" do
      stub = create_stub
      typeof(stub.call(no_args) { 42 }).should eq(Int32)
    end

    it "supports nilable types" do
      stub = create_stub
      typeof(stub.call(no_args) { 42.as(Int32?) }).should eq(Int32?)
    end
  end
end