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

  describe "#handled?" do
    it "is false" do
      stub = create_stub
      stub.handled?.should be_false
    end
  end

  describe "#call" do
    it "throws an error" do
      stub = create_stub
      expect_raises(Exception) do
        stub.call(no_args)
      end
    end
  end

  describe "#with" do
    it "sets the arguments pattern" do
      stub = create_stub.with(42)
      stub.arguments.to_s.should eq("(42)")
    end
  end
end
