require "./value_stub"

module Spectator::Mocks
  # Multiple stubs that can be applied to a stubbable object.
  # *T* must be a `NamedTuple`.
  class StubCollection(T)
    # Creates a new stub collection.
    def initialize(@stubs : T)
      {% raise "Type parameter T must be a NamedTuple" unless T < NamedTuple %}
    end

    # Applies the stubs in the collection to a registry proxy.
    def apply(proxy) : Nil
      {% for name in T.keys %}
        proxy.add_stub(ValueStub.new({{name.symbolize}}, @stubs[{{name.symbolize}}]))
      {% end %}
    end
  end
end
