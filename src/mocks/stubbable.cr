require "./call"
require "./proxy"
require "./stubbed"
require "./unexpected_message"

module Mocks
  # Adds support for method stubs to a type.
  #
  # This module is intended to be used as a mix-in.
  # Include it to allow instance methods to be stubbed.
  # Extend it to allow class methods to be stubbed.
  #
  # Example usage:
  # ```
  # class MyClass
  #   include Mocks::Stubbable
  #
  #   stub the_answer = 42
  #
  #   stub def stringify(arg) : String
  #     arg.to_s
  #   end
  # end
  # ```
  #
  # When defining stubbable methods, a behavior and type are needed.
  # The behavior is a symbol that specifies how the method behaves without a user-defined stub.
  # The behavior can be one of:
  # - `:block` - Yield to the block provided and return its value.
  # - `:previous_def` - Call the previous definition of the method.
  # - `:super` - Call the parent's implementation of the method.
  # - `:unexpected` - Throw an `UnexpectedMessage` error.
  # - `:abstract` - Throw an `UnexpectedMessage` error indicating an attempt to call the original method, which is abstract.
  #
  # The type is needed so that values returned by stubs can be type checked and cast if necessary.
  # It is also used to inform the compiler the method's type to avoid bloated unions.
  # The type can be one of:
  # - *Type name* - Any type name, the return value will be explicitly cast to this type.
  # - `:infer` - Have the compiler infer the type from a based on the behavior.
  module Stubbable
    # Names of methods to skip defining a stub for.
    # These are typically special methods, such as Crystal built-ins, that would be unsafe to mock.
    UNSAFE_METHODS = %i[allocate finalize initialize]

    # Avoid modifying 'should' and 'should_not' methods from Spec framework.
    {% if @top_level.has_constant?(:Spec) %}
      {% UNSAFE_METHODS << :should
         UNSAFE_METHODS << :should_not %}
    {% end %}

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
    #
    # Abstract methods will be given an implementation that raises `UnexpectedMessage`.
    # Provide a stub to define alternate behavior.
    # ```
    # stub abstract def do_something
    # # ...
    # obj.do_something # Raises `UnexpectedMessage`
    # obj.can receive(:do_something)
    # obj.do_something # OK
    # ```
    # NOTE: Omitting the return type restriction for an abstract method will cause it to return nil.
    # Specify a non-nil return type with a default stub, such as passing a block to this method,
    # or by adding a return type restriction to the method.
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
        {% unless method.abstract? %}{{visibility.id if visibility != :public}} {{method}}{% end %}

        # Stub implementation.
        # FIXME: Reuse method signature generation code.
        {% begin %}
          @[::Mocks::Stubbed]
          {{visibility.id if visibility != :public}} def {% if method.receiver %}{{method.receiver}}.{% end %}{{method.name}}({% for arg, i in method.args %}
            {% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}{% if method.double_splat %}**{{method.double_splat}}, {% end %}
            {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
          ){% if method.return_type %} : {{method.return_type}}{% end %}{% unless method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}
            stubbed_method_body({{method.abstract? ? :abstract : :previous_def}}, as: {{method.return_type || :infer}})
          end
        {% end %}

      {% elsif method.is_a?(TypeDeclaration) || method.is_a?(Assign) %}
        stub_any_args {{method}}

      {% else %}
        # Stub all methods matching the specified name.
        stub_existing {{method}}, {{(anno = @type.annotation(::Mocks::DefaultBehavior)) && anno[0] == :original}}
      {% end %}
    end

    # Redefines all methods in the current type to support stubs.
    #
    # All methods in the current type and its ancestors are redefined.
    # Only methods with a specific name can be redefined by providing a *name*.
    #
    # If *original* is true, then the method's original implementation is called when there are no stubs defined.
    # This is false By default, which raises `UnexpectedMessage` instead.
    #
    # A block can be provided, which gives the default implementation.
    private macro stub_existing(name = nil, original = false, &block)
      {% definitions = [] of {method: Def, behavior: Symbol, type: Symbol, receiver: Symbol?}
         # Find all methods to redefine.
         # Definitions are stored as an array of tuples.
         # The values are as follows:
         # method - Original method definition.
         # behavior - Default behavior of the method without a stub.
         # type - Type to return by the stub.
         # receiver - Type name for class methods, nil otherwise.

         # Add methods from the current type.
         # This must be done first so that the previous definition is used instead of one from an ancestor.
         definitions = @type.methods.map do |method|
           behavior = if block
                        :block
                      elsif method.abstract?
                        :abstract
                      elsif original
                        :previous_def
                      else
                        :unexpected
                      end

           {
             method:   method,
             behavior: behavior,
             type:     (method.abstract? ? :infer : :previous_def),
             receiver: nil,
             original: :previous_def,
           }
         end

         # Add class methods from the current type.
         definitions += @type.class.methods.map do |method|
           behavior = if block
                        :block
                      elsif original
                        :previous_def
                      else
                        :unexpected
                      end

           {
             method:   method,
             behavior: behavior,
             type:     :previous_def,
             receiver: :self,
             original: :previous_def,
           }
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
               unless definitions.any? do |d|
                        r = !!d[:receiver]
                        m = d[:method]
                        # Ensure instance and class methods with the same signature don't collide.
                        r == !!receiver &&
                        # Method objects can't be directly compared.
                        # Compare each distinguishing attribute separately.
                        m.name == method.name &&
                        m.args == method.args &&
                        m.splat_index == method.splat_index &&
                        !!m.double_splat == !!method.double_splat &&
                        !!m.block_arg == !!method.block_arg
                      end
                 # Method not overridden, add it to the list.
                 behavior = if block
                              :block
                            elsif method.abstract?
                              :abstract
                            elsif original
                              :super
                            else
                              :unexpected
                            end
                 definitions << {
                   method:   method,
                   behavior: behavior,
                   type:     (method.abstract? ? :infer : :super),
                   receiver: receiver,
                   original: :super,
                 }
               end
             end
           end
         end

         # Filter out methods that should be skipped, are incompatible, or unsafe to stub.
         definitions = definitions.reject do |d|
           method = d[:method]
           ::Mocks::Stubbable::UNSAFE_METHODS.includes?(method.name.symbolize) ||
             method.name.starts_with?("__") ||
             method.annotation(Primitive) || method.annotation(::Mocks::Stubbed)
         end

         if name
           # Only redefine methods with the specified name.
           definitions = if name.is_a?(Call) && name.receiver
                           definitions.select do |d|
                             d[:method].name == name.name && d[:receiver]
                           end
                         else
                           definitions.select do |d|
                             d[:method].name == name.id
                           end
                         end
         end %}

      # Redefine virtually all methods to support stubs.
      # FIXME: Reuse method signature generation code.
      {% for definition in definitions %}
        {% method, behavior, type, receiver, original = definition.values
           visibility = method.visibility %}
        {% begin %}
          @[::Mocks::Stubbed]
          {{visibility.id if visibility != :public}} def {{"self.".id if receiver}}{{method.name}}({% for arg, i in method.args %}
            {% if i == method.splat_index %}*{% end %}{{arg}}, {% end %}{% if method.double_splat %}**{{method.double_splat}}, {% end %}
            {% if method.block_arg %}&{{method.block_arg}}{% elsif method.accepts_block? %}&{% end %}
          ){% if method.return_type %} : {{method.return_type}}{% end %}{% unless method.free_vars.empty? %} forall {{method.free_vars.splat}}{% end %}
            stubbed_method_body({{behavior}}, as: {{method.return_type || type}},
              {% if !method.abstract? %}original: {{original}},{% end %}
              {% if method.block_arg && method.block_arg.name && method.block_arg.name.size > 0 %}captured_block_name: {{method.block_arg.name}}{% end %}
            ) {{block}}
          end
        {% end %}
      {% end %}
    end

    # Defines stubbable methods that can accept any arguments (and block).
    #
    # Four syntaxes are supported:
    # ```
    # stub_any_args some_method1 : Int32
    # stub_any_args some_method2 : Int32 = 42
    # stub_any_args some_method3 = 42
    # stub_any_args some_method4, 42
    # ```
    # The type returned by the method must be known at compile-time,
    # either from the type restriction or by inferring from the assigned value.
    private macro stub_any_args(name, value = nil)
      {% if name.is_a?(TypeDeclaration)
           type = name.type
           value = name.value
           name = name.var
         elsif name.is_a?(Assign)
           type = :infer
           value = name.value
           name = name.target
         elsif name.is_a?(SymbolLiteral) || name.is_a?(StringLiteral)
           type = :infer
           name = name.id
         else
           raise "Unexpected stub syntax"
         end %}
      @[::Mocks::Stubbed]
      def {{name}}(*args, **kwargs){% if type != :infer %} : {{type}}{% end %}
        {% if value.is_a?(Nop) %}
          stubbed_method_body(:unexpected, as: {{type}})
        {% else %}
          stubbed_method_body(as: {{type}}) { {{value}} }
        {% end %}
      end

      @[::Mocks::Stubbed]
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
    # Captures a method call, looks for a stub, and calls it if one was found.
    # The block passed to this macro is used as the default/fallback implementation.
    #
    # The *behavior* and *type* arguments are passed along to the `#stubbed_method_behavior` macro.
    # See `#stubbed_method_behavior` for details on those parameters.
    #
    # The *original* argument indicates how the original method can be invoked.
    # It should be one of: `:previous_def`, `:super`, or `nil`.
    # Omitting this argument (or passing `nil`) indicates that the original method cannot be invoked.
    # In this case, *behavior* is used instead and must be one of: `:block`, `:unexpected`, or `:abstract`.
    #
    # The *captured_block_name* argument is used to retain the name of the captured block.
    # Without it, the compiler eagerly discards the captured block name.
    # This changes the usage of `@def` so that the block argument name is preserved.
    private macro stubbed_method_body(behavior = :block, *, as type = :infer, original = nil, captured_block_name = nil, &block)
      # Record call.
      %call = ::Mocks::Call.capture
      __mocks.add_call(%call)

      %type = {% if type == :previous_def || type == :super %}
                typeof(adjusted_previous_def({{type}}))
              {% elsif type != :infer %}
                {{type.id}}
              {% elsif behavior == :block %} # From here on, type == :infer
                typeof({{yield}})
              {% elsif behavior == :previous_def || behavior == :super %}
                typeof(adjusted_previous_def({{behavior}}))
              {% else %}
                ::Nil # behavior == :unexpected || :abstract
              {% end %}

      if %stub = __mocks.find_stub(%call)
        # Stub found for invocation.
        %stub.call(%call.arguments, %type) do
          # Stub yielded to default behavior.
          stubbed_method_behavior({{original || behavior}}, as: {{type}}) {{block}}
        end
      else
        # No stub found, use default behavior.
        stubbed_method_behavior({{behavior}}, as: {{type}}) {{block}}
      end
    end

    # Defines the behavior of a stubbed method.
    # This macro is intended to be used inside a stubbable method.
    #
    # The *behavior* argument can be `:block`, `:previous_def`, `:super`, `:unexpected`, or `:abstract`.
    # When the *behavior* is `:block`, a block must be provided.
    # The block's content is used as the method's behavior.
    # For `:previous_def` and `:super`, the original method's implementation is invoked.
    # Lastly, `:unexpected` and `:abstract, raise an `UnexpectedMessage` error.
    # The `:abstract` behavior indicates in the error message that there was an attempt to call an abstract method.
    #
    # A *type* can be specified with the *as* keyword argument.
    # This should be provided when the method is expected to return a specific type.
    # It can be `:infer`, which indicates no casting is performed and the compiler should infer the return type.
    # Additionally, `:previous_def` and `:super` can be used to copy the type from those methods.
    # This is typically used with *behavior* set to `:unexpected`.
    private macro stubbed_method_behavior(behavior = :block, *, as type = :infer)
      {% if behavior == :block %}
        {{yield}}
      {% elsif behavior == :previous_def || behavior == :super %}
        adjusted_previous_def({{behavior}})
      {% elsif behavior == :unexpected || behavior == :abstract %}
        {% if type == :previous_def || type == :super %}
          %type = typeof(adjusted_previous_def({{type}}))
        {% elsif type != :infer %}
          %type = {{type.id}}
        {% else %}
          %type = ::NoReturn
        {% end %}
        ::Mocks::Stubbable.unexpected_method_call({{@def.name.symbolize}}, {{behavior == :abstract}}, %type)
      {% else %}
        {% raise "Unknown stubbed method body behavior: #{behavior}" %}
      {% end %}
    end

    # Raises an error that indicates an method was called unexpectedly.
    #
    # The return type of this method matches the *type* passed in.
    # Set *abstract_call* to true to change the error message to indicate an abstract method was "called".
    @[Stubbed]
    def self.unexpected_method_call(method_name : Symbol, abstract_call : Bool, type : T.class) : T forall T
      unexpected_method_call(method_name, abstract_call, NoReturn)
      {% unless T <= NoReturn %}
        # Trick compiler into thinking this is the returned type instead of `NoReturn` (from the previous line).
        ::Pointer(T).new(0).value # This line should not be reached.
      {% end %}
    end

    # Raises an error that indicates an method was called unexpectedly.
    #
    # Set *abstract_call* to true to change the error message to indicate an abstract method was "called".
    @[Stubbed]
    def self.unexpected_method_call(method_name : Symbol, abstract_call : Bool, type : NoReturn.class) : NoReturn
      if abstract_call
        raise UnexpectedMessage.new(method_name, "Attempted to call abstract method `#{method_name}`")
      else
        raise UnexpectedMessage.new(method_name)
      end
    end

    # Reconstructs a `previous_def` or `super` call.
    #
    # This macro expands the call so that all arguments and the block are passed along.
    # The compiler (currently) does not forward the block when `previous_def` and `super` are used.
    # See: https://github.com/crystal-lang/crystal/issues/10399
    # Additionally, methods with keyword arguments aren't handled correctly.
    # See: https://github.com/crystal-lang/crystal/issues/13176
    private macro adjusted_previous_def(keyword = :previous_def)
      {% if @def.accepts_block? || @def.splat_index || @def.double_splat %}
        delegate_current_call({{keyword}})
      {% else %}
        {{keyword.id}}
      {% end %}
    end

    # Constructs a method call that forwards the arguments passed to the surrounding method to another method.
    # The *target* indicates the destination method.
    # This could be `super`, `previous_def`, a method name, or a method name of another object such as `other.something`.
    private macro delegate_current_call(target)
      {%
        call = target + "("

        # Iterate through all of the arguments,
        # but the logic is slightly different when a splat it used.
        if @def.splat_index
          @def.args.each_with_index do |arg, i|
            if i == @def.splat_index && arg.internal_name && !arg.internal_name.empty?
              # Encountered the splat, prefix its name (if any).
              call += "*#{arg.internal_name}, "
              # Insert the double-splat immediately after.
              # Any additional explicit keyword arguments will override these values.
              call += "**#{@def.double_splat}, " if @def.double_splat
            elsif i > @def.splat_index
              # After the splat, arguments must be named.
              call += "#{arg.name}: #{arg.internal_name}, "
            elsif arg.internal_name && !arg.internal_name.empty?
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
        call += " { |*__yield_args| yield *__yield_args }" if !captured && @def.accepts_block?
      %}
      {{call.id}}
    end
  end
end

require "./stubbable/*"
