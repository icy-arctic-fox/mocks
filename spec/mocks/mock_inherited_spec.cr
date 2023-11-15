require "../spec_helper"
require "./mock_spec"

private abstract class BaseClass
  def_abstract_instance_methods
  def_concrete_instance_methods
  def_class_methods
end

private abstract struct BaseStruct
  def_abstract_instance_methods
  def_concrete_instance_methods
  def_class_methods
end

private abstract class ChildClass < BaseClass; end

private abstract struct ChildStruct < BaseStruct; end

private define_mock(ChildClassMock < ChildClass, %i[abstract concrete], %i[abstract concrete class])
private define_mock(ChildStructMock < ChildStruct, %i[abstract concrete], %i[abstract concrete class])

describe Mocks::Mock do
  context "subtype of class" do
    it_supports_abstract_methods(ChildClassMock.new)
    it_supports_concrete_methods(ChildClassMock.new)
    it_supports_class_methods(ChildClassMock)
    it_allows_calling_standard_methods(ChildClassMock.new)
  end

  context "subtype of struct" do
    it_supports_abstract_methods(ChildStructMock.new)
    it_supports_concrete_methods(ChildStructMock.new)
    it_supports_class_methods(ChildStructMock)
    it_allows_calling_standard_methods(ChildStructMock.new)
  end
end
