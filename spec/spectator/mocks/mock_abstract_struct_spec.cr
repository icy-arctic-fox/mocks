require "../../spec_helper"
require "./mock_spec"

private abstract struct AbstractStruct
  def_abstract_instance_methods
  def_concrete_instance_methods
  def_class_methods
end

private define_mock(AbstractStructMock < AbstractStruct, %i[abstract concrete], %i[abstract concrete class])

describe Spectator::Mocks::Mock do
  context "abstract struct" do
    it_supports_abstract_methods(AbstractStructMock.new)
    it_supports_concrete_methods(AbstractStructMock.new)
    it_supports_class_methods(AbstractStructMock)
  end
end
