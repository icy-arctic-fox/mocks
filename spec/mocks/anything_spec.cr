require "../spec_helper"

describe Mocks::Anything do
  describe "#==" do
    it "returns true for itself" do
      any = Mocks::Anything.new
      (any == any).should be_true
    end

    it "returns true for values" do
      any = Mocks::Anything.new
      (any == 123).should be_true
      (any == :xyz).should be_true
    end

    it "returns true for references" do
      any = Mocks::Anything.new
      (any == "foo").should be_true
      (any == [] of Symbol).should be_true
    end

    it "returns true for nil and false" do
      any = Mocks::Anything.new
      (any == nil).should be_true
      (any == false).should be_true
    end
  end

  describe "#===" do
    it "returns true for itself" do
      any = Mocks::Anything.new
      (any === any).should be_true
    end

    it "returns true for values" do
      any = Mocks::Anything.new
      (any === 123).should be_true
      (any === :xyz).should be_true
    end

    it "returns true for references" do
      any = Mocks::Anything.new
      (any === "foo").should be_true
      (any === [] of Symbol).should be_true
    end

    it "returns true for nil and false" do
      any = Mocks::Anything.new
      (any === nil).should be_true
      (any === false).should be_true
    end
  end
end
