require "../spec_helper"
require "./mock_spec"

private module MixinModule
  def_abstract_instance_methods
  def_concrete_instance_methods
end

private abstract class MixedClass
  include MixinModule
end

private abstract struct MixedStruct
  include MixinModule
end

private module MixedModule
  include MixinModule
end

private define_mock(MixedClassMock < MixedClass, %i[abstract concrete], %i[abstract concrete])
private define_mock(MixedStructMock < MixedStruct, %i[abstract concrete], %i[abstract concrete])
private define_mock(MixedModuleMock < MixedModule, %i[abstract concrete], %i[abstract concrete])

describe Mocks::Mock do
  context "class with mixin module" do
    it_supports_abstract_methods(MixedClassMock.new)
    it_supports_concrete_methods(MixedClassMock.new)
    it_allows_calling_standard_methods(MixedClassMock.new)
  end

  context "struct with mixin module" do
    it_supports_abstract_methods(MixedStructMock.new)
    it_supports_concrete_methods(MixedStructMock.new)
    it_allows_calling_standard_methods(MixedStructMock.new)
  end

  context "module with mixin module" do
    it_supports_abstract_methods(MixedModuleMock.new)
    it_supports_concrete_methods(MixedModuleMock.new)
    it_allows_calling_standard_methods(MixedModuleMock.new)
  end
end
