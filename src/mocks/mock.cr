require "./standard_stubs"
require "./stubbable"
require "./stubbed"

module Mocks
  module Mock
    # Defines a macro to define a mock.
    # This is a workaround for the DSL methods regarding visibility modifiers.
    # A type defined by a nested macro loses its visibility modifier from the outer macro invocation.
    # This is probably a bug in the compiler, but working around for now.
    # The workaround is to reuse the macro definition code here and in the DSL.
    macro def_define_mock(name)
      macro {{name.id}}(type, **stubs, &block)
        {% verbatim do %}
          {% if type.is_a?(Call) && type.name == :<.id %}
            {% parent_name = type.args.first
               parent = if parent_name.is_a?(Path | TypeNode | Union | Metaclass)
                          parent_name.resolve
                        elsif parent_name.is_a?(Generic)
                          parent_name.resolve? || parent_name.name.resolve
                        else
                          parse_type(parent_name.id.stringify).resolve
                        end
               type = type.receiver
               type_keyword = if parent.class?
                                :class
                              elsif parent.struct?
                                :struct
                              elsif parent.module?
                                :module
                              else
                                raise "Unsupported mock type for #{parent.name}"
                              end %}

            {% begin %}
              {% if type_keyword == :module %}
                {% instance_type = (!type.is_a?(Generic) || type.type_vars.empty? ? "Instance" : "Instance(#{type.type_vars.splat})").id %}
                module {{type}}
                  include {{parent_name}}

                  class {{instance_type}}
                    include {{type}}

                    # Empty initializer to override the `.new` method from {{type}}.
                    def initialize
                    end

                    def ==(other : self) : Bool
                      \{% if @type < Reference %}
                        same?(other)
                      \{% else %}
                        this = self
                        this_ptr = pointerof(this)
                        LibC.memcmp(this_ptr, pointerof(other), sizeof(self)) == 0
                      \{% end %}
                    end

                    def ===(other : self) : Bool
                      self == other
                    end
                  end

                  @[::Mocks::Stubbed]
                  def self.new : {{instance_type}}
                    {{instance_type}}.new
                  end
              {% else %}
                {{type_keyword.id}} {{type}} < {{parent_name}}
              {% end %}
                include ::Mocks::Stubbable::Automatic
                include ::Mocks::StandardStubs

                {% for name, value in stubs %}
                  stub_existing({{name}}) { {{value}} }
                {% end %}

                {{block.body if block}}
              end
            {% end %}

          {% else %}
            {% raise "Syntax error in mock definition. Must be: `NewType < OriginalType`" %}
          {% end %}
        {% end %}
      end
    end

    # Defines a mock type.
    # The new type inherits from the type being mocked.
    # All methods are stubbable.
    #
    # A simple mock of an existing type can be defined with:
    # ```
    # class MyClass
    # end
    #
    # Mock.define MyMock < MyClass
    # mock = MyMock.new
    # ```
    # The *type* argument must be in the form `MockType < OriginalType`,
    # similar to defining a class that extends another.
    #
    # Simple stubs can be defined via *stubs*.
    # Each keyword should be an existing method and its value is its stubbed return value.
    # For instance:
    # ```
    # class MyClass
    #   def some_method1
    #     0
    #   end
    #
    #   def some_method2
    #     "Original"
    #   end
    #
    #   def some_method3
    #     :xyz
    #   end
    # end
    #
    # Mock.define MyMock < MyClass,
    #   some_method1: 42,
    #   some_method2: "Mock",
    # MyMock.new.some_method1 # => 42
    # ```
    # In the example above, 3 methods are defined.
    # The first returns 42 by default in the mock.
    # The second returns "Mock" instead of "Original".
    # And the third method will raise `UnexpectedMessage` unless it is stubbed.
    #
    # More complex methods can be defined with a block.
    # ```
    # class MyClass
    #   def label(arg)
    #     "Label: #{arg}"
    #   end
    # end
    #
    # Mock.define(MyMock < MyClass) do
    #   def label(arg)
    #     "Value: #{arg}"
    #   end
    # end
    # MyMock.new.label(42) # => "Value: 42"
    # ```
    # The contents of a method will be used as the default behavior.
    #
    # Simple and complex methods can be mixed.
    # ```
    # Mock.define(MyMock < MyClass, some_method1: 42) do
    #   def label(arg)
    #     "Value: #{arg}"
    #   end
    # end
    # ```
    #
    # The contents of the block are dumped as-is into the class body of the mock.
    # This allows for more complex behavior if needed.
    # ```
    # abstract class MyClass
    #   abstract def add(amount)
    # end
    #
    # Mock.define(MyMock < MyClass) do
    #   getter accumulator = 0
    #
    #   def add(amount)
    #     @accumulator += amount
    #   end
    # end
    # ```
    def_define_mock define
  end
end
