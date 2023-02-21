require "../../spec_helper"

describe Spectator::Mocks::Call do
  it "stores attributes" do
    args = Spectator::Mocks::Arguments.new({arg: 42}, nil, nil, NamedTuple.new)
    call = Spectator::Mocks::Call.new(:test_method, args)
    call.method_name.should eq(:test_method)
    call.arguments.should be(args)
  end

  describe "#to_s" do
    it "contains the method name" do
      call = Spectator::Mocks::Call.new(:test_method)
      call.to_s.should contain("test_method")
    end

    it "contains the arguments" do
      args = Spectator::Mocks::Arguments.new({arg: 42}, nil, nil, NamedTuple.new)
      call = Spectator::Mocks::Call.new(:test_method, args)
      call.to_s.should contain(args.to_s)
    end

    it "is formatted correctly" do
      args = Spectator::Mocks::Arguments.new({arg: 42}, nil, nil, NamedTuple.new)
      call = Spectator::Mocks::Call.new(:test_method, args)
      call.to_s.should match(/^#test_method\(.*\)$/)
    end
  end
end
