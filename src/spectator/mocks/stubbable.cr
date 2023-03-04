require "./call"
require "./proxy"

module Spectator::Mocks
  module Stubbable
    def __mocks
      Proxy.new(self)
    end

    macro stub(method)
      {% if method.is_a?(VisibilityModifier)
           visibility = method.visibility
           method = method.exp
         elsif method.is_a?(Def)
           visibility = method.visibility
         else
           visibility = :public
         end %}

      {% if method.is_a?(Def) %}
        # Default implementation.
        {% begin %}{{visibility.id if visibility != :public}} {{method}}{% end %}

        # Stub implementation.
        {% begin %}
          {{visibility.id if visibility != :public}} def {% if method.receiver %}{{method.receiver}}.{% end %}{{method.name}}{% unless method.args.empty? %}({% for arg, i in method.args %}
            {% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}{% if method.double_splat %}**{{method.double_splat}}, {% end %}
            {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
          ){% end %}{% if method.return_type %} : {{method.return_type}}{% end %}{% unless method.free_vars.empty? %} forall {{*method.free_vars}}{% end %}
            stubbed_method_body(:previous)
          end
        {% end %}

      {% elsif method.is_a?(TypeDeclaration) || method.is_a?(Assign) %}
        stub_any_args {{method}}

      {% else %}
        # Stub all methods matching the specified name.
        # TODO: Handle ancestors.
        {% for m in @type.methods %}
          {% if m.name == method.id %}stub {{m}}{% end %}
        {% end %}
      {% end %}
    end

    private macro stub_any_args(name)
      {% if name.is_a?(TypeDeclaration)
           type = name.type
           value = name.value
           name = name.var
         elsif name.is_a?(Assign)
           type = :none
           value = name.value
           name = name.target
         else
           raise "Unexpected stub syntax"
         end %}
      def {{name}}(*args, **kwargs){% if type != :none %} : {{type}}{% end %}
        {% if value.is_a?(Nop) %}
          stubbed_method_body(:unexpected, as: {{type}})
        {% else %}
          stubbed_method_body(as: {{type}}) { {{value}} }
        {% end %}
      end

      def {{name}}(*args, **kwargs, &){% if type != :none %} : {{type}}{% end %}
        {% if value.is_a?(Nop) %}
          stubbed_method_body(:unexpected, as: {{type}})
        {% else %}
          stubbed_method_body(as: {{type}}) { {{value}} }
        {% end %}
      end
    end

    private macro stubbed_method_body(behavior = :block, *, as type = :none, &block)
      %call = ::Spectator::Mocks::Call.capture
      if %stub = __mocks.find_stub(%call)
        %stub.call(%call.arguments) do
          stubbed_method_behavior({{behavior}}, as: {{type}}) {{block}}
        end
      else
        stubbed_method_behavior({{behavior}}, as: {{type}}) {{block}}
      end
    end

    private macro stubbed_method_behavior(behavior = :block, *, as type = :none, &block)
      {% if behavior == :block %}
        %value = begin
          {{block.body}}
        end
        {% if type != :none %}
          %value.as({{type.id}})
        {% end %}
      {% elsif behavior == :previous %}
        %value = adjusted_previous_def
        {% if type != :none %}
          %value.as({{type.id}})
        {% end %}
      {% elsif behavior == :unexpected %}
        raise ::Spectator::Mocks::UnexpectedMessage.new({{@def.name.symbolize}})
        {% if type != :none %}
          # Trick compiler into thinking this is the returned type instead of `NoReturn` (from the raise).
          # This line should not be reached.
          {{type.id}}.allocate
        {% end %}
      {% else %}
        {% raise "Unknown stubbed method body behavior: #{behavior}" %}
      {% end %}
    end

    private macro adjusted_previous_def
      previous_def # TODO
    end
  end
end

require "./stubbable/*"
