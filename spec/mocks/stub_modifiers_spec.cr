require "../spec_helper"

private def create_stub
  Mocks::NilStub.new(:test_method)
end

private def no_args
  Mocks::Arguments.none
end

private def create_args(arg1)
  Mocks::Arguments.new({arg1: arg1}, nil, Tuple.new, NamedTuple.new)
end

private def invoke_stub(stub, return_type = Nil, args = no_args)
  stub.call(args, return_type)
end

describe Mocks::StubModifiers do
  describe "#and_return" do
    it "produces a stub that returns nil" do
      stub = create_stub.and_return
      invoke_stub(stub, Int32?).should eq(nil)
    end

    it "produces a stub that returns a static value" do
      stub = create_stub.and_return(42)
      invoke_stub(stub, Int32).should eq(42)
    end

    it "produces a stub that returns multiple values" do
      stub = create_stub.and_return(1, 3, 5, 7, 13)
      invoke_stub(stub, Int32).should eq(1)
      invoke_stub(stub, Int32).should eq(3)
      invoke_stub(stub, Int32).should eq(5)
      invoke_stub(stub, Int32).should eq(7)
      invoke_stub(stub, Int32).should eq(13)
      invoke_stub(stub, Int32).should eq(13)
    end
  end

  describe "#and_raise" do
    it "produces a stub that raises an exception" do
      stub = create_stub.and_raise
      expect_raises(RuntimeError) { invoke_stub(stub) }
    end

    it "uses the exception passed to it" do
      exception = ArgumentError.new("Test exception")
      stub = create_stub.and_raise(exception)
      expect_raises(ArgumentError, "Test exception") do
        invoke_stub(stub)
      end
    end

    it "creates an exception of the type specified" do
      stub = create_stub.and_raise(ArgumentError)
      expect_raises(ArgumentError) do
        invoke_stub(stub)
      end
    end

    it "passes arguments to the exception's initializer" do
      stub = create_stub.and_raise(ArgumentError, "Test exception")
      expect_raises(ArgumentError, "Test exception") do
        invoke_stub(stub)
      end
    end

    it "uses RuntimeError if no type is given" do
      stub = create_stub.and_raise("Test exception")
      expect_raises(RuntimeError, "Test exception") do
        invoke_stub(stub)
      end
    end
  end

  describe "#and_call_original" do
    it "produces a stub that calls the original method" do
      stub = create_stub.and_call_original
      stub.handled?.should be_false
    end
  end

  describe "#with (no block)" do
    it "produces a stub that matches arguments" do
      stub = create_stub.with(42)
      invoke_stub(stub).should be_nil
      stub.arguments.to_s.should eq("(42)")
    end
  end

  describe "#with (block)" do
    it "produces a stub that matches arguments and calls a block" do
      stub = create_stub.with(42) { "Test" }
      invoke_stub(stub, String).should eq("Test")
      stub.arguments.to_s.should eq("(42)")
    end
  end
end
