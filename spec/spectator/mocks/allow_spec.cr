require "../../spec_helper"

describe Spectator::Mocks::Allow do
  describe "#to" do
    it "can apply a stub" do
      proxy = Spectator::Mocks::Proxy.new("foobar")
      allow = Spectator::Mocks::Allow.new(proxy)
      stub = Spectator::Mocks::NilStub.new(:test_method)
      allow.to(stub)
      call = Spectator::Mocks::Call.new(:test_method)
      proxy.find_stub(call).should be(stub)
    end

    it "can apply multiple stubs" do
      proxy = Spectator::Mocks::Proxy.new("foobar")
      allow = Spectator::Mocks::Allow.new(proxy)
      collection = Spectator::Mocks::StubCollection.new({test_method1: 42, test_method2: :xyz})
      allow.to(collection)
      call1 = Spectator::Mocks::Call.new(:test_method1)
      call2 = Spectator::Mocks::Call.new(:test_method2)
      proxy.find_stub(call1).should be_a(Spectator::Mocks::ValueStub(Int32))
      proxy.find_stub(call2).should be_a(Spectator::Mocks::ValueStub(Symbol))
    end
  end
end
