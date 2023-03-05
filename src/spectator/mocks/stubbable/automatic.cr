module Spectator::Mocks
  # When included, automatically redefines all methods to be stubbable.
  module Stubbable::Automatic
    include Stubbable

    # Names of methods to skip defining a stub for.
    # These are typically special methods, such as Crystal built-ins, that would be unsafe to mock.
    SKIPPED_METHOD_NAMES = %i[allocate finalize should should_not]

    macro included
      {% definitions = [] of {Def, Symbol, Symbol?}
         # Definitions are stored as an array of tuples.
         # The first element is the method definition.
         # The next two are the behavior (previous_def or super) and the method receiver (self or nil).

         # Add methods from the current type.
         # This must be done first so that the previous definition is used instead of one from an ancestor.
         definitions = @type.methods.map do |method|
           {method, :previous_def, nil}
         end

         # Add class methods from the current type.
         definitions += @type.class.methods.map do |method|
           {method, :previous_def, :self}
         end

         # Add methods from ancestors if they aren't overridden.
         @type.ancestors.each do |ancestor|
           # DRY up code by combining instance and class methods from ancestor.
           variants = [
             {ancestor, nil},
             {ancestor.class, ancestor.name(generic_args: false)},
           ]
           variants.each do |(type, receiver)|
             type.methods.each do |method|
               # Skip methods overridden by a sub-type to prevent unnecessary redefinitions.
               unless definitions.any? do |(m, _, _)|
                        # Method objects can't be directly compared.
                        # Compare each distinguishing attribute separately.
                        m.name == method.name &&
                        m.args == method.args &&
                        m.splat_index == method.splat_index &&
                        m.double_splat == method.double_splat &&
                        m.block_arg == method.block_arg
                      end
                 # Method not overridden, add it to the list.
                 definitions << {method, :super, receiver}
               end
             end
           end
         end %}

      {% for definition in definitions %}
        {% method, behavior, receiver = definition
           visibility = method.visibility %}
        {% unless ::Spectator::Mocks::Stubbable::Automatic::SKIPPED_METHOD_NAMES.includes?(method.name.symbolize) ||
                    method.name.starts_with?("__") ||
                    method.annotation(Primitive) %}
          {% begin %}
            {{visibility.id if visibility != :public}} def {{"self.".id if receiver}}{{method.name}}{% unless method.args.empty? %}({% for arg, i in method.args %}
              {% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}{% if method.double_splat %}**{{method.double_splat}}, {% end %}
              {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
            ){% end %}{% if method.return_type %} : {{method.return_type}}{% end %}{% unless method.free_vars.empty? %} forall {{*method.free_vars}}{% end %}
              stubbed_method_body({{behavior}})
            end
          {% end %}
        {% end %}
      {% end %}

      {% verbatim do %}
      # Automatically apply to all sub-types.
      macro included
        include ::Spectator::Mocks::Stubbable::Automatic
      end

        # Automatically redefine new methods with stub functionality.
    macro method_added(method)
          {% unless ::Spectator::Mocks::Stubbable::Automatic::SKIPPED_METHOD_NAMES.includes?(method.name.symbolize) ||
                      method.name.starts_with?("__") ||
                      method.annotation(Primitive) %}
            {% begin %}
              {{method.visibility.id if method.visibility != :public}} def {{"#{method.receiver}.".id if method.receiver}}{{method.name}}{% unless method.args.empty? %}({% for arg, i in method.args %}
                {% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}{% if method.double_splat %}**{{method.double_splat}}, {% end %}
                {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
              ){% end %}{% if method.return_type %} : {{method.return_type}}{% end %}{% unless method.free_vars.empty? %} forall {{*method.free_vars}}{% end %}
                stubbed_method_body(:previous_def)
              end
            {% end %}
          {% end %}
        end
      {% end %}
    end
  end
end
