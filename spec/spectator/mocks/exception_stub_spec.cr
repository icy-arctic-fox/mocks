require "../../spec_helper"

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
      stub = Spectator::Mocks::ExceptionStub.new(:test_method, exception)
      expect_raises(RuntimeError, "Test exception") do
        stub.call(no_args) { 42 }
      end
    end
  end
end
