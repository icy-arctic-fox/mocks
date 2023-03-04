module Spectator::Mocks
  # When included, automatically redefines all methods to be stubbable.
  module Stubbable::Automatic
    include Stubbable

    # Names of methods to skip defining a stub for.
    # These are typically special methods, such as Crystal built-ins, that would be unsafe to mock.
    SKIPPED_METHOD_NAMES = %i[finalize should should_not]

    macro included
      # TODO: Apply to ancestors and mix-ins.
      {% for method in @type.methods %}
        {% unless ::Spectator::Mocks::Stubbable::Automatic::SKIPPED_METHOD_NAMES.includes?(method.name.symbolize) ||
                    method.name.starts_with?("__") ||
                    method.annotation(Primitive) %}
          stub {{method}}
        {% end %}
      {% end %}

      # Automatically apply to all sub-types.
      macro included
        include ::Spectator::Mocks::Stubbable::Automatic
      end
    end

    macro method_added(method)
      stub {{method}}
    end
  end
end
