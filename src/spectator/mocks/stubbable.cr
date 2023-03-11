require "./call"
require "./proxy"
require "./stubbed"

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
          # FIXME: Reuse method signature code.
          @[::Spectator::Mocks::Stubbed]
          {{visibility.id if visibility != :public}} def {% if method.receiver %}{{method.receiver}}.{% end %}{{method.name}}{% unless method.args.empty? %}({% for arg, i in method.args %}
            {% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}{% if method.double_splat %}**{{method.double_splat}}, {% end %}
            {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
          ){% end %}{% if method.return_type %} : {{method.return_type}}{% end %}{% unless method.free_vars.empty? %} forall {{*method.free_vars}}{% end %}
            stubbed_method_body(:previous_def)
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
      @[::Spectator::Mocks::Stubbed]
      def {{name}}(*args, **kwargs){% if type != :none %} : {{type}}{% end %}
        {% if value.is_a?(Nop) %}
          stubbed_method_body(:unexpected, as: {{type}})
        {% else %}
          stubbed_method_body(as: {{type}}) { {{value}} }
        {% end %}
      end

      @[::Spectator::Mocks::Stubbed]
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
      %type = {% if type != :none %}
                {{type.id}}
              {% elsif behavior == :block %}
                typeof(begin
                  {{block.body}}
                end)
              {% elsif behavior == :previous_def || behavior == :super %}
                typeof(adjusted_previous_def({{behavior}}))
              {% else %}
                ::NoReturn # behavior == :unexpected
              {% end %}

      if %stub = __mocks.find_stub(%call)
        %stub.call(%call.arguments, %type) do
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
      {% elsif behavior == :previous_def || behavior == :super %}
        %value = adjusted_previous_def({{behavior}})
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

    # Reconstructs a `previous_def` or `super` call.
    # This macro expands the call so that all arguments and the block are passed along.
    # The compiler (currently) does not forward the block when `previous_def` and `super` are used.
    # See: https://github.com/crystal-lang/crystal/issues/10399
    # Additionally, methods with a double-splat aren't handled correctly.
    # See: https://github.com/crystal-lang/crystal/issues/13176
    private macro adjusted_previous_def(keyword = :previous_def)
      {{ if @def.accepts_block? || @def.double_splat
           # A block or double-splat is involved, manually reconstruct the call with all arguments and the block.
           call = keyword + "("

           # Iterate through all of the arguments,
           # but the logic is slightly different when a splat it used.
           if @def.splat_index
             @def.args.each_with_index do |arg, i|
               if i == @def.splat_index
                 # Encountered the splat, prefix its name (if any).
                 call += "*#{arg.internal_name}, "
                 # Insert the double-splat immediately after.
                 # Any additional explicit keyword arguments will override these values.
                 original += "**#{@def.double_splat}, " if @def.double_splat
               elsif i > @def.splat_index
                 # After the splat, arguments must be named.
                 call += "#{arg.name}: #{arg.internal_name}, "
               else
                 # Before the splat, use positional syntax.
                 call += "#{arg.internal_name}, "
               end
             end
           else
             # No splat, add each argument.
             call += @def.args.map(&.internal_name).join(", ")
             call += ", " unless @def.args.empty?
             # Add double-splat if it exists.
             call += "**#{@def.double_splat}, " if @def.double_splat
           end

           # If the block is captured (`&block` syntax), it must be passed along as an argument.
           # Otherwise, use `yield` to forward the block.
           captured = if @def.block_arg && @def.block_arg.name && @def.block_arg.name.size > 0
                        @def.block_arg.name
                      else
                        nil
                      end

           # Append the block.
           call += "&#{captured}" if captured
           call += ")"
           call += " { |*__args| yield *__args }" if !captured && @def.accepts_block?
           call
         else
           # No block involved, don't need a workaround.
           keyword
         end.id }}
    end
  end
end

require "./stubbable/*"
