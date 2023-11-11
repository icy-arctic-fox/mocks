require "../spec_helper"

private def capture
  Mocks::Call.capture
end

private def capture(arg1, arg2, *splat, kwarg1, kwarg2, **double_splat)
  call = Mocks::Call.capture
  args = Mocks::Arguments.capture
  {call, args}
end

describe Mocks::Call do
  it "stores attributes" do
    args = Mocks::Arguments.new({arg: 42}, nil, nil, NamedTuple.new)
    call = Mocks::Call.new(:test_method, args)
    call.method_name.should eq(:test_method)
    call.arguments.should be(args)
  end

  describe ".new" do
    it "creates an instance with empty arguments" do
      call = Mocks::Call.new(:test_method)
      call.method_name.should eq(:test_method)
      call.arguments.empty?.should be_true
    end
  end

  describe ".capture" do
    it "captures the method name" do
      call = capture
      call.method_name.should eq(:capture)
    end

    it "captures the arguments" do
      call, args = capture(1, 2, 3, kwarg1: 4, kwarg2: 5, additional: 6)
      call.arguments.should eq(args)
    end
  end

  describe "#to_s" do
    it "contains the method name" do
      call = Mocks::Call.new(:test_method)
      call.to_s.should contain("test_method")
    end

    it "contains the arguments" do
      args = Mocks::Arguments.new({arg: 42}, nil, nil, NamedTuple.new)
      call = Mocks::Call.new(:test_method, args)
      call.to_s.should contain(args.to_s)
    end

    it "is formatted correctly" do
      args = Mocks::Arguments.new({arg: 42}, nil, nil, NamedTuple.new)
      call = Mocks::Call.new(:test_method, args)
      call.to_s.should match(/^#test_method\(.*\)$/)
    end
  end
end
