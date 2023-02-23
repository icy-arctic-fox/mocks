require "../../spec_helper"

describe Spectator::Mocks::NilStub do
  it "sets the attributes" do
    args = Spectator::Mocks::ArgumentsPattern.build(42)
    stub = Spectator::Mocks::NilStub.new(:test_method, args)

    stub.method_name.should eq(:test_method)
    stub.arguments.should be(args)
  end
end
