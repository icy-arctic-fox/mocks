require "../../spec_helper"

describe Spectator::Mocks::StubCollection do
  describe "#apply" do
    it "adds multiple stubs" do
      value_stubs = {method1: 42, method2: "foo"}
      collection = Spectator::Mocks::StubCollection.new(value_stubs)

      obj = Box.box(42)
      scope = Spectator::Mocks::Scope.new
      proxy = Spectator::Mocks::Proxy.new(obj, scope)

      collection.apply(proxy)

      method1_call = Spectator::Mocks::Call.new(:method1)
      method2_call = Spectator::Mocks::Call.new(:method2)
      stub1 = proxy.find_stub(method1_call).should_not be_nil
      stub2 = proxy.find_stub(method2_call).should_not be_nil

      no_args = Spectator::Mocks::Arguments.none
      value1 = stub1.call(no_args) { 0 }
      value2 = stub2.call(no_args) { "bar" }

      value1.should eq(42)
      value2.should eq("foo")
    end
  end
end
