require "../spec_helper"

describe Mocks::StubCollection do
  describe "#apply" do
    it "adds multiple stubs" do
      value_stubs = {method1: 42, method2: "foo"}
      collection = Mocks::StubCollection.new(value_stubs)

      obj = Box.box(42)
      scope = Mocks::Scope.new
      proxy = Mocks::Proxy.new(obj, scope)

      collection.apply(proxy)

      method1_call = Mocks::Call.new(:method1)
      method2_call = Mocks::Call.new(:method2)
      stub1 = proxy.find_stub(method1_call).should_not be_nil
      stub2 = proxy.find_stub(method2_call).should_not be_nil

      no_args = Mocks::Arguments.none
      value1 = stub1.call(no_args, Int32)
      value2 = stub2.call(no_args, String)

      value1.should eq(42)
      value2.should eq("foo")
    end
  end
end
