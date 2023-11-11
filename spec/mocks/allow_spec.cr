require "../spec_helper"

describe Mocks::Allow do
  describe "#to" do
    it "can apply a stub" do
      proxy = Mocks::Proxy.new("foobar")
      allow = Mocks::Allow.new(proxy)
      stub = Mocks::NilStub.new(:test_method)
      allow.to(stub)
      call = Mocks::Call.new(:test_method)
      proxy.find_stub(call).should be(stub)
    end

    it "can apply multiple stubs" do
      proxy = Mocks::Proxy.new("foobar")
      allow = Mocks::Allow.new(proxy)
      collection = Mocks::StubCollection.new({test_method1: 42, test_method2: :xyz})
      allow.to(collection)
      call1 = Mocks::Call.new(:test_method1)
      call2 = Mocks::Call.new(:test_method2)
      proxy.find_stub(call1).should be_a(Mocks::ValueStub(Int32))
      proxy.find_stub(call2).should be_a(Mocks::ValueStub(Symbol))
    end
  end
end
