require "./call"
require "./proxy"
require "./stubbed"

module Spectator::Mocks
  # Adds support for method stubs to a type.
  #
  # This module is intended to be used as a mix-in.
  # Include it to allow instance methods to be stubbed.
  # Extend it to allow class methods to be stubbed.
  #
  # Example usage:
  # ```
  # class MyClass
  #   include Spectator::Mocks::Stubbable
  #
  #   stub the_answer = 42
  #
  #   stub def stringify(arg) : String
  #     arg.to_s
  #   end
  # end
  # ```
  module Stubbable
    # :nodoc:
    def __mocks
      Proxy.new(self)
    end

    # Defines a new stubbable method or redefines an existing method to support stubbing.
    #
    # Multiple syntaxes are supported.
    # The following define new methods that accept any arguments.
    # ```
    # stub some_method1 : Int32
    # stub some_method2 : Int32 = 42
    # stub some_method3 = 42
    # ```
    # When a stub isn't applied and a value is assigned, it is used as the return value.
    # Otherwise, an `UnexpectedMessage` error is raised when the stubbed method is called.
    #
    # A method (an its overrides) can be redefined by specifying the method name.
    # ```
    # stub to_s
    # ```
    # The argument list must be omitted.
    # All methods matching the specified name will be redefined to support stubbing.
    # When a stub isn't applied, the default behavior will be to call the original implementation.
    #
    # Lastly, a method definition can be provided.
    # ```
    # stub def do_something(arg) : String
    #   arg.to_s
    # end
    # ```
    # This will define (or redefine) a method that supports stubbing.
    # The method will only accept calls with a matching signature.
    # When a stub isn't applied, the default behavior will be the contents of the method's body.
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
        # FIXME: Reuse method signature generation code.
        {% begin %}
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
        stub_existing_methods {{method}}
      {% end %}
    end

    # Redefines all methods in the current type to support stubs.
    # All methods in the current type and its ancestors are redefined.
    # Only methods with a specific name can be redefined by providing a *name*.
    private macro stub_existing_methods(name = nil)
      {% definitions = [] of {Def, Symbol, Symbol?}
         # Find all methods to redefine.
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
         end

         # Filter out methods that should be skipped, are incompatible, or unsafe to stub.
         definitions = definitions.reject do |(method, _, _)|
           ::Spectator::Mocks::Stubbable::Automatic::SKIPPED_METHOD_NAMES.includes?(method.name.symbolize) ||
             method.name.starts_with?("__") ||
             method.annotation(Primitive) || method.annotation(::Spectator::Mocks::Stubbed)
         end

         if name
           # Only redefine methods with the specified name.
           name = name.id
           definitions = definitions.select do |(method, _, _)|
             method.name == name
           end
         end %}

      # Redefine virtually all methods to support stubs.
      # FIXME: Reuse method signature generation code.
      {% for definition in definitions %}
        {% method, behavior, receiver = definition
           visibility = method.visibility %}
        {% begin %}
          @[::Spectator::Mocks::Stubbed]
          {{visibility.id if visibility != :public}} def {{"self.".id if receiver}}{{method.name}}{% unless method.args.empty? %}({% for arg, i in method.args %}
            {% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}{% if method.double_splat %}**{{method.double_splat}}, {% end %}
            {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
          ){% end %}{% if method.return_type %} : {{method.return_type}}{% end %}{% unless method.free_vars.empty? %} forall {{*method.free_vars}}{% end %}
            # For abstract methods, if no return type is specified, it will be `NoReturn`.
            # It is expected that the method is overridden if another type is needed.
            # Requiring a return type is not allowed here since it could require changes outside the user's code.
            stubbed_method_body({{behavior}})
          end
        {% end %}
      {% end %}
    end

    # Defines stubbable methods that can accept any arguments (and block).
    #
    # Three syntaxes are supported:
    # ```
    # stub_any_args some_method1 : Int32
    # stub_any_args some_method2 : Int32 = 42
    # stub_any_args some_method3 = 42
    # ```
    # The type returned by the method must be known at compile-time,
    # either from the type restriction or by inferring from the assignment.
    private macro stub_any_args(name)
      {% if name.is_a?(TypeDeclaration)
           type = name.type
           value = name.value
           name = name.var
         elsif name.is_a?(Assign)
           type = :infer
           value = name.value
           name = name.target
         else
           raise "Unexpected stub syntax"
         end %}
      @[::Spectator::Mocks::Stubbed]
      def {{name}}(*args, **kwargs){% if type != :infer %} : {{type}}{% end %}
        {% if value.is_a?(Nop) %}
          stubbed_method_body(:unexpected, as: {{type}})
        {% else %}
          stubbed_method_body(as: {{type}}) { {{value}} }
        {% end %}
      end

      @[::Spectator::Mocks::Stubbed]
      def {{name}}(*args, **kwargs, &){% if type != :infer %} : {{type}}{% end %}
        {% if value.is_a?(Nop) %}
          stubbed_method_body(:unexpected, as: {{type}})
        {% else %}
          stubbed_method_body(as: {{type}}) { {{value}} }
        {% end %}
      end
    end

    # Constructs the contents of a stubbed method's body.
    # This macro is intended to be used inside a stubbable method.
    #
    # The *behavior* argument is passed along to the `#stubbed_method_behavior` macro.
    # It is used by this macro to infer the method's return type if the *as* *type* argument isn't provided.
    #
    # A *type* can be specified with the *as* keyword argument.
    # This should be provided when the method is expected to return a specific type.
    # It can be `:infer`, which indicates no casting is performed and the compiler should infer the return type.
    private macro stubbed_method_body(behavior = :block, *, as type = :infer, &block)
      %call = ::Spectator::Mocks::Call.capture
      %type = {% if type != :infer %}
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
        # Stub found for invocation.
        %stub.call(%call.arguments, %type) do
          stubbed_method_behavior({{behavior}}, as: {{type}}) {{block}}
        end
      else
        stubbed_method_behavior({{behavior}}, as: {{type}}) {{block}}
      end
    end

    # Defines the behavior of a stubbed method.
    # This macro is intended to be used inside a stubbable method.
    #
    # The *behavior* argument can be `:block`, `:previous_def`, `:super`, or `:unexpected`.
    # When the *behavior* is `:block`, a block must be provided.
    # The block's content is used as the method's behavior.
    # For `:previous_def` and `:super`, the original method's implementation is invoked.
    # Lastly, for `:unexpected`, an `UnexpectedMessage` error is raised.
    #
    # A *type* can be specified with the *as* keyword argument.
    # This should be provided when the method is expected to return a specific type.
    # It can be `:infer`, which indicates no casting is performed and the compiler should infer the return type.
    private macro stubbed_method_behavior(behavior = :block, *, as type = :infer, &block)
      {% if behavior == :block %}
        %value = begin
          {{block.body}}
        end
        {% if type != :infer %}
          %value.as({{type.id}})
        {% end %}
      {% elsif behavior == :previous_def || behavior == :super %}
        %value = adjusted_previous_def({{behavior}})
        {% if type != :infer %}
          %value.as({{type.id}})
        {% end %}
      {% elsif behavior == :unexpected %}
        raise ::Spectator::Mocks::UnexpectedMessage.new({{@def.name.symbolize}})
        {% if type != :infer %}
          # Trick compiler into thinking this is the returned type instead of `NoReturn` (from the raise).
          # This line should not be reached.
          {{type.id}}.allocate
        {% end %}
      {% else %}
        {% raise "Unknown stubbed method body behavior: #{behavior}" %}
      {% end %}
    end

    # Reconstructs a `previous_def` or `super` call.
    #
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
