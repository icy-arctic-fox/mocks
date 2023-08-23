require "../../spec_helper"

private alias Mock = Spectator::Mocks::Mock

private abstract struct AbstractStruct
end

private Mock.define AbstractStructMock < AbstractStruct

private module ModuleMixin
end

private Mock.define ModuleMixinMock < ModuleMixin

describe Mock do
  describe ".define" do
    context "with an abstract struct" do
      it "defines a sub-type" do
        AbstractStructMock.should be < AbstractStruct
      end

      it "is instantiable" do
        AbstractStructMock.new.should be_a(AbstractStruct)
      end
    end

    context "with a module mixin" do
      it "defines a sub-type" do
        ModuleMixinMock.should be < ModuleMixin
      end

      it "is instantiable" do
        ModuleMixinMock.new.should be_a(ModuleMixin)
      end
    end
  end
end
