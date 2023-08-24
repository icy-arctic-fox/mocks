require "../../spec_helper"
require "./mock_spec"

private abstract class AbstractClass
  def_abstract_instance_methods
  def_concrete_instance_methods
  def_class_methods
end

private define_mock(AbstractClassMock < AbstractClass, [:abstract, :concrete], [:abstract, :concrete, :class])

describe Spectator::Mocks::Mock do
  it_supports_abstract_methods(AbstractClassMock.new)
  it_supports_concrete_methods(AbstractClassMock.new)
  it_supports_class_methods(AbstractClassMock)
end
