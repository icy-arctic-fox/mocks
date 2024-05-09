require "../spec_helper"

private def create_stub(values = [1, 2, 3], args = nil)
  Mocks::MultiValueStub.new(:test_method, values, args)
end

private def no_args
  Mocks::Arguments.none
end

describe Mocks::ValueStub do
  it "sets the attributes" do
    args = Mocks::ArgumentsPattern.build(42)
    stub = Mocks::MultiValueStub.new(:test_method, [:xyz], args)

    stub.method_name.should eq(:test_method)
    stub.arguments.should be(args)
  end

  describe "#handled?" do
    it "is true" do
      stub = create_stub
      stub.handled?.should be_true
    end
  end

  describe "#call" do
    it "returns consecutive values" do
      stub = create_stub
      stub.call(no_args, Int32).should eq(1)
      stub.call(no_args, Int32).should eq(2)
      stub.call(no_args, Int32).should eq(3)
    end

    it "returns the last value after the others are exhausted" do
      stub = create_stub
      3.times do
        stub.call(no_args, Int32)
      end
      stub.call(no_args, Int32).should eq(3)
    end

    it "raises when return type doesn't match" do
      stub = create_stub
      expect_raises(TypeCastError, /Int32/) do
        stub.call(no_args, Symbol)
      end
    end

    it "supports union types" do
      stub = create_stub
      stub.call(no_args, String | Int32).should eq(1)
    end

    it "supports nilable types" do
      stub = create_stub
      stub.call(no_args, Int32?).should eq(1)
    end

    it "ignores the value for Nil types" do
      stub = create_stub
      stub.call(no_args, Nil).should be_nil
    end
  end

  describe "#with" do
    it "sets the arguments pattern" do
      stub = create_stub.with(42)
      stub.arguments.to_s.should eq("(42)")
    end
  end
end
