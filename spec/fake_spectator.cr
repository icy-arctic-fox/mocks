require "../src/mocks/dsl/allow_syntax"

# Methods and objects that mimic the appearance of Spectator's DSL.
# These adapt Spectator's syntax to Spec.
module FakeSpectator
  include Mocks::DSL::AllowSyntax

  struct Expect(T)
    def initialize(@thing : T)
    end

    def to(expectation)
      @thing.should(expectation)
    end
  end

  private def expect(thing)
    Expect.new(thing)
  end
end
