require "../default_behavior"
require "../stubbed"

module Mocks
  # When included, automatically redefines all methods to be stubbable.
  # Any newly defined *instance* methods will have stub functionality added to them.
  #
  # NOTE: Class methods defined after this module is included *will not* have stub functionality added.
  #   As a workaround, use the `stub` keyword before the class method definition.
  module Stubbable::Automatic
    include Stubbable

    macro included
      # Add stub support to class methods.
      extend ::Mocks::Stubbable

      macro finished
        {% if (anno = @type.annotation(::Mocks::DefaultBehavior)) && anno[0] == :original %}
          stub_existing nil, true
        {% else %}
          stub_existing
        {% end %}
      end

      # Automatically apply to all sub-types.
      {% if @type.module? %}
        macro included
          include ::Mocks::Stubbable::Automatic
        end

        macro extended
          include ::Mocks::Stubbable::Automatic
        end
      {% else %}
        macro inherited
          include ::Mocks::Stubbable::Automatic
        end
      {% end %}

      {% verbatim do %}
        # Automatically redefine new methods with stub functionality.
        #
        # NOTE: The `method_added` macro is not triggered for class methods.
        #   This prevents them from being redefined with stub functionality.
        #
        # FIXME: Reuse method signature generation code.
        macro method_added(method)
          {% unless ::Mocks::Stubbable::UNSAFE_METHODS.includes?(method.name.symbolize) ||
                      method.name.starts_with?("__") ||
                      method.annotation(Primitive) || method.annotation(::Mocks::Stubbed) %}
            {% begin %}
              @[::Mocks::Stubbed]
              {{method.visibility.id if method.visibility != :public}} def {{"#{method.receiver}.".id if method.receiver}}{{method.name}}({% for arg, i in method.args %}
                {% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}{% if method.double_splat %}**{{method.double_splat}}, {% end %}
                {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
              ){% if method.return_type %} : {{method.return_type}}{% end %}{% unless method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}
                # For abstract methods, if no return type is specified, it will be `NoReturn`.
                # It is expected that the method is overridden if something else is needed.
                # Requiring a return type is not allowed here since it could require changes outside the user's code.
                stubbed_method_body({{method.abstract? ? :abstract : :previous_def}},
                  as: {{method.return_type || :infer}},
                  {% if method.block_arg && method.block_arg.name && method.block_arg.name.size > 0 %}captured_block_name: {{method.block_arg.name}}{% end %}
                )
              end
            {% end %}
          {% end %}

          # Add `new` class method if `initialize` was defined.
          {% if method.name == :initialize.id %}
            @[::Mocks::Stubbed]
            {{method.visibility.id if method.visibility != :public}} def self.new({% for arg, i in method.args %}
              {% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}{% if method.double_splat %}**{{method.double_splat}}, {% end %}
              {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
            ){% if method.return_type %} : {{method.return_type}}{% end %}{% unless method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}
              stubbed_method_body(:previous_def,
                as: {{method.return_type || :infer}},
                {% if method.block_arg && method.block_arg.name && method.block_arg.name.size > 0 %}captured_block_name: {{method.block_arg.name}}{% end %}
              )
            end
          {% end %}
        end
      {% end %}
    end
  end
end
