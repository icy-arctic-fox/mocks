require "../spec_helper"

private double TestDouble, value: 0

def new_stub(method_name = :value, value = 1)
  Mocks::ValueStub.new(method_name, value)
end

describe Mocks::Scope do
  context "does not leak stubs between examples" do
    dbl : TestDouble? = nil # This instance is shared across examples.

    before_each { dbl ||= TestDouble.new }

    it "(setup)" do
      d = dbl.not_nil!
      d.__mocks.add_stub(new_stub)
      d.value.should eq(1)
    end

    it "(test)" do
      d = dbl.not_nil!
      d.value.should eq(0)
    end
  end

  context "does not leak calls between examples" do
    dbl : TestDouble? = nil

    before_each { dbl ||= TestDouble.new }

    it "(setup)" do
      d = dbl.not_nil!
      d.value
      calls = d.__mocks.calls.select { |call| call.method_name == :value }
      calls.should_not be_empty
    end

    it "(test)" do
      d = dbl.not_nil!
      calls = d.__mocks.calls.select { |call| call.method_name == :value }
      calls.should be_empty
    end
  end

  context "doubles cannot be used outside of an example" do
    exception : Exception? = nil

    begin
      d = dbl = TestDouble.new
      d.__mocks.add_stub(new_stub)
    rescue e
      exception = e
    end

    it "(test)" do
      e = exception.should_not be_nil
      e.message.should match(/scope/)
    end
  end

  context "doubles cannot be used in a before_all hook" do
    exception : Exception? = nil
    dbl : TestDouble? = nil

    before_all do
      d = dbl = TestDouble.new
      d.__mocks.add_stub(new_stub)
    rescue e
      exception = e
    end

    it "(test)" do
      e = exception.should_not be_nil
      e.message.should match(/scope/)
    end
  end

  context "doubles can be used in a before_each hook" do
    exception : Exception? = nil
    dbl : TestDouble? = nil

    before_each do
      d = dbl = TestDouble.new
      d.__mocks.add_stub(new_stub)
    rescue e
      exception = e
    end

    it "(test)" do
      exception.should be_nil
      dbl.should_not be_nil
    end
  end

  context "doubles cannot be used in an after_all hook" do
    dbl : TestDouble? = nil

    after_all do
      expect_raises(Exception, /scope/) do
        d = dbl.not_nil!
        d.value.should eq(1)
      end
    end

    it "(setup)" do
      d = dbl = TestDouble.new
      d.__mocks.add_stub(new_stub)
    end
  end

  context "doubles can be used in an after_each hook" do
    dbl : TestDouble? = nil

    after_each do
      d = dbl.not_nil!
      d.value.should eq(1)
    end

    it "(setup)" do
      d = dbl = TestDouble.new
      d.__mocks.add_stub(new_stub)
    end
  end

  context "doubles can be used in an around_each hook" do
    dbl : TestDouble? = nil

    around_each do |example|
      d = dbl = TestDouble.new
      d.__mocks.add_stub(new_stub)
      example.run
      d.__mocks.calls.should_not be_empty
    end

    it "(setup)" do
      d = dbl.not_nil!
      d.value.should eq(1)
    end
  end
end
