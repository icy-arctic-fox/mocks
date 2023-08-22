require "spec"
require "../src/spectator-mocks"

def define_stubs(mock, **value_stubs : **T) forall T
  proxy = mock.__mocks
  # Avoid NamedTuple#each since it produces a union of types for each value.
  # This may throw-off the types used by stubs.
  {% for key in T %}
    stub = Spectator::Mocks::ValueStub.new({{key.symbolize}}, value_stubs[{{key.symbolize}}])
    proxy.add_stub(stub)
  {% end %}
end
