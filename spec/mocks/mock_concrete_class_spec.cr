require "../spec_helper"
require "./mock_spec"

private class ConcreteClass
  def_concrete_instance_methods
  def_class_methods
end

private define_mock(ConcreteClassMock < ConcreteClass, %i[concrete], %i[concrete class])

describe Mocks::Mock do
  context "concrete class" do
    it_supports_concrete_methods(ConcreteClassMock.new)
    it_supports_class_methods(ConcreteClassMock)
  end
end
