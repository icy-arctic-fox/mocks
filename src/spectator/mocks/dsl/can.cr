require "../stub"
require "../stubbable"

module Spectator::Mocks
  module Stubbable
    # Prevent `can` from being stubbed.
    {% UNSAFE_METHODS << :can %}

    def can(stub : Stub) : Nil
      __mocks.add_stub(stub)
    end
  end
end
