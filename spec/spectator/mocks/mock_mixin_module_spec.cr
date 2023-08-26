require "../../spec_helper"
require "./mock_spec"

private module MixinModule
  def_abstract_instance_methods
  def_concrete_instance_methods
  def_class_methods
end

private define_mock(MixinModuleMock < MixinModule, [:abstract, :concrete], [:abstract, :concrete])

describe Spectator::Mocks::Mock do
  it_supports_abstract_methods(MixinModuleMock.new)
  it_supports_concrete_methods(MixinModuleMock.new)
  # Class methods on modules are not supported (yet).
  # it_supports_class_methods(MixinModuleMock)
end
