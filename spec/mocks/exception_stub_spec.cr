require "../spec_helper"

private def create_stub(exception = RuntimeError.new("Test exception"), args = nil)
  Mocks::ExceptionStub.new(:test_method, exception, args)
end

private def no_args
  Mocks::Arguments.none
end

describe Mocks::ExceptionStub do
  it "sets the attributes" do
    args = Mocks::ArgumentsPattern.build(42)
    stub = Mocks::ExceptionStub.new(:test_method, RuntimeError.new, args)

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

  describe "#with" do
    it "sets the arguments pattern" do
      stub = create_stub.with(42)
      stub.arguments.to_s.should eq("(42)")
    end
  end
end
