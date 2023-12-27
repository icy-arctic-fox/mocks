require "./default_behavior"
require "./null_object"
require "./stub"
require "./stubbable"
require "./value_stub"

module Mocks
  # Arbitrary type used as a stand-in for a real object.
  # Doubles are recommended where duck-typing is used.
  # See `#define` for details regarding how to use this type.
  @[DefaultBehavior(:original)]
  abstract class Double
    include Stubbable::Automatic

    # Defines a macro to define a double.
    # This produces the standard `double` keyword
    # that accepts default stubs from the keyword arguments and block body.
    macro def_define_double(name, *, type = nil)
      macro {{name.id}}(name, *stubs, **named_stubs, &block)
        class \{{name.id}} < {{(type || @type.name).id}}
          {% verbatim do %}
            {% for stub in stubs %}
              stub_any_args {{stub}}
            {% end %}

            {% for name, value in named_stubs %}
              stub_any_args {{name.id.symbolize}}, {{value}}
            {% end %}

            {{block.body if block}}
          {% end %}
        end
      end
    end

    # Defines a double type.
    # The new type is a sub-class of `Double`.
    # All methods are stubbable.
    #
    # The *name* argument is the new type to define.
    # A simple double with no specific methods can be defined with:
    # ```
    # Double.define MyDouble
    # dbl = MyDouble.new
    # ```
    #
    # Simple stubs can be defined via *stubs*.
    # Each element should be an assignment or type declaration.
    # For instance:
    # ```
    # Double.define MyDouble,
    #   some_method1 : Int32,
    #   some_method2 : Int32 = 42,
    #   some_method3 = 42
    # MyDouble.new.some_method2 # => 42
    # ```
    # In the example above, 3 methods are defined.
    # Each return an `Int32`, but the last two will return 42 by default.
    # The first method will raise `UnexpectedMessage` unless it is stubbed.
    # All methods will accept any arguments and an optional block.
    #
    # Additionally, these simple stubs can be defined with *named_stubs*.
    # These are keyword arguments where the keyword is the method name and its value is the default return value.
    # ```
    # Double.define MyDouble,
    #   some_method1: 1,
    #   some_method2: 2,
    #   some_method3: 3,
    # MyDouble.new.some_method2 # => 2
    # ```
    #
    # More complex methods can be defined with a block.
    # ```
    # Double.define(MyDouble) do
    #   def label(arg)
    #     "Value: #{arg}"
    #   end
    # end
    # MyDouble.new.label(42) # => "Value: 42"
    # ```
    # The contents of a method will be used as the default behavior.
    #
    # Simple and complex methods can be mixed.
    # ```
    # Double.define(MyDouble, some_method1 = 42, some_method2: 42) do
    #   def label(arg)
    #     "Value: #{arg}"
    #   end
    # end
    # ```
    #
    # The contents of the block are dumped as-is into the class body of the double.
    # This allows for more complex behavior if needed.
    # ```
    # Double.define(MyDouble) do
    #   getter accumulator = 0
    #
    #   def add(amount)
    #     @accumulator += amount
    #   end
    # end
    # ```
    def_define_double define

    @name : String?

    # Creates a new double with an optional name.
    def initialize(name = nil)
      @name = name.try &.to_s
    end

    # Creates a new double with initial stubs.
    # The *name* can be anything or nil for an anonymous double.
    # The *value_stubs* must be a `NamedTuple`.
    protected def initialize(name, value_stubs : T) forall T
      {% raise "Type argument T must be a NamedTuple" unless T < NamedTuple %}

      initialize(name)
      proxy = __mocks

      # Avoid producing a stub where each value is a union (don't use `#each`).
      # This is done by capturing the NamedTuple's type (and keys) via T.
      # A layer of indirection is necessary since the syntax `**kwargs : **T` isn't valid.
      {% for key in T.keys %}
        proxy.add_stub(ValueStub.new({{key.symbolize}}, value_stubs[{{key.symbolize}}]))
      {% end %}
    end

    # Creates a new double with initial stubs.
    #
    # The *name* can be anything or nil for an anonymous double.
    # Specify default stubs by passing keyword arguments.
    # Each keyword is the name of a method to stub and its value is the value returned by that method.
    # ```
    # MyDouble.new(:fake, some_method: 42, another_method: "foo")
    # ```
    def self.new(name = nil, **value_stubs)
      new(name, value_stubs)
    end

    # Creates a null object wrapper for the current double.
    @[Stubbed]
    def as_null_object
      raise NotImplementedError.new("Double#as_null_object")
    end

    # Constructs a string representation of the double.
    def to_s(io : IO) : Nil
      io << "#<" << self.class << ":0x"
      object_id.to_s(io, 16)
      if name = @name
        io << " \"#{name}\""
      else
        io << " anonymous"
      end
      io << '>'
    end
  end
end
