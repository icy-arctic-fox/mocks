require "../stubbed"

module Spectator::Mocks
  # When included, automatically redefines all methods to be stubbable.
  module Stubbable::Automatic
    include Stubbable

    macro included
      # Add stub support to class methods.
      extend ::Spectator::Mocks::Stubbable

      macro finished
        stub_existing
      end

      # Automatically apply to all sub-types.
      {% if @type.module? %}
        macro included
          include ::Spectator::Mocks::Stubbable::Automatic
        end

        macro extended
          include ::Spectator::Mocks::Stubbable::Automatic
        end
      {% else %}
        macro inherited
          include ::Spectator::Mocks::Stubbable::Automatic
        end
      {% end %}

      {% verbatim do %}
        # Automatically redefine new methods with stub functionality.
        # FIXME: Reuse method signature generation code.
        macro method_added(method)
          {% unless ::Spectator::Mocks::Stubbable::UNSAFE_METHODS.includes?(method.name.symbolize) ||
                      method.name.starts_with?("__") ||
                      method.annotation(Primitive) || method.annotation(::Spectator::Mocks::Stubbed) %}
            {% begin %}
              @[::Spectator::Mocks::Stubbed]
              {{method.visibility.id if method.visibility != :public}} def {{"#{method.receiver}.".id if method.receiver}}{{method.name}}{% unless method.args.empty? %}({% for arg, i in method.args %}
                {% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}{% if method.double_splat %}**{{method.double_splat}}, {% end %}
                {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
              ){% end %}{% if method.return_type %} : {{method.return_type}}{% end %}{% unless method.free_vars.empty? %} forall {{*method.free_vars}}{% end %}
                # For abstract methods, if no return type is specified, it will be `NoReturn`.
                # It is expected that the method is overridden if something else is needed.
                # Requiring a return type is not allowed here since it could require changes outside the user's code.
                stubbed_method_body({{method.abstract? ? :unexpected : :previous_def}})
              end
            {% end %}
          {% end %}
        end
      {% end %}
    end
  end
end
