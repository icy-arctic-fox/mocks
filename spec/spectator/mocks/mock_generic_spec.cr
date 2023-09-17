require "../../spec_helper"
require "./mock_spec"

private abstract class GenericClass(T)
  def_concrete_instance_methods(return_type: T, yield_return_type: T)
  def_abstract_instance_methods(return_type: T, yield_return_type: T)
  def_class_methods
end

private define_mock(GenericClassMock(T) < GenericClass(T), %i[abstract concrete], %i[abstract concrete class], return_type: T, yield_return_type: T)
private define_mock(NonGenericClassMock < GenericClass(String), %i[abstract concrete], %i[abstract concrete class])

private abstract struct GenericStruct(T)
  def_concrete_instance_methods(return_type: T, yield_return_type: T)
  def_abstract_instance_methods(return_type: T, yield_return_type: T)
  def_class_methods
end

private define_mock(GenericStructMock(T) < GenericStruct(T), %i[abstract concrete], %i[abstract concrete class], return_type: T, yield_return_type: T)
private define_mock(NonGenericStructMock < GenericStruct(String), %i[abstract concrete], %i[abstract concrete class])

private module GenericModule(T)
  def_concrete_instance_methods(return_type: T, yield_return_type: T)
  def_abstract_instance_methods(return_type: T, yield_return_type: T)
  def_class_methods(return_type: T, yield_return_type: T)
end

private define_mock(GenericModuleMock(T) < GenericModule(T), %i[abstract concrete], %i[abstract concrete class], return_type: T, yield_return_type: T)
private define_mock(NonGenericModuleMock < GenericModule(String), %i[abstract concrete], %i[abstract concrete class])

describe Spectator::Mocks::Mock do
  context "generic class" do
    it_supports_concrete_methods(GenericClassMock(String).new)
    it_supports_abstract_methods(GenericClassMock(String).new)
    it_supports_class_methods(GenericClassMock(String))
  end

  context "generic class with explicit type" do
    it_supports_concrete_methods(NonGenericClassMock.new)
    it_supports_abstract_methods(NonGenericClassMock.new)
    it_supports_class_methods(NonGenericClassMock)
  end

  context "generic struct" do
    it_supports_concrete_methods(GenericStructMock(String).new)
    it_supports_abstract_methods(GenericStructMock(String).new)
    it_supports_class_methods(GenericStructMock(String))
  end

  context "generic struct with explicit type" do
    it_supports_concrete_methods(NonGenericStructMock.new)
    it_supports_abstract_methods(NonGenericStructMock.new)
    it_supports_class_methods(NonGenericStructMock)
  end

  context "generic module" do
    it_supports_concrete_methods(GenericModuleMock(String).new)
    it_supports_abstract_methods(GenericModuleMock(String).new)
    # Class methods on modules are not supported (yet).
    # it_supports_class_methods(GenericModuleMock(String))
  end

  context "generic module with explicit type" do
    it_supports_concrete_methods(NonGenericModuleMock.new)
    it_supports_abstract_methods(NonGenericModuleMock.new)
    # Class methods on modules are not supported (yet).
    # it_supports_class_methods(NonGenericModuleMock)
  end
end
