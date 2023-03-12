require "./double"
require "./mock"
require "./nil_stub"
require "./proc_stub"

module Spectator::Mocks
  # Methods used in tests to define mocks, doubles, and stubs.
  module DSL
    alias UnexpectedMessage = ::Spectator::Mocks::UnexpectedMessage

    # Defines a test double.
    #
    # This macro must be used outside of a method definition or block body, as it defines a new type.
    #
    # The first argument is the type name.
    # Additional arguments and a block can be provided to define methods.
    # See: `Double#define` for details.
    #
    # ```
    # double MyDouble, the_answer = 42, some_method : String
    #
    # dbl = MyDouble.new
    # dbl.the_answer.should eq(42)
    # expect_raises(UnexpectedMessage) { dbl.some_method }
    # ```
    macro double(name, *stubs, &block)
      ::Spectator::Mocks::Double.define({{name}}, {{*stubs}}) {{block}}
    end

    # Defines a test mock.
    #
    # This macro must be used outside of a method definition or block body, as it defines a new type.
    #
    # The first argument is the type name.
    # It must use the syntax: `MockType < OriginalType`,
    # where `MockType` is the new type to define
    # and `OriginalType` is an existing type to mock.
    # Additional arguments can be provided to define default values.
    # See: `Mock#define` for details.
    #
    # ```
    # class Original
    #   def the_answer
    #     42
    #   end
    #
    #   def some_method(arg)
    #     arg.to_s
    #   end
    # end
    #
    # mock MyMock < Original, the_answer: 5
    #
    # mock = MyMock.new
    # mock.the_answer.should eq(5)
    # expect_raises(UnexpectedMessage) { mock.some_method(:foo) }
    # ```
    macro mock(type, **stubs, &block)
      ::Spectator::Mocks::Mock.define({{type}}, {{**stubs}}) {{block}}
    end

    # Constructs a stub for a method.
    #
    # The *method* is the name of the method to stub.
    #
    # This is also the start of a fluent interface for defining stubs.
    # See: `StubModifiers`
    #
    # Can syntax:
    # ```
    # dbl.can receive(:some_method)
    # dbl.can receive(:the_answer).and_return(42)
    # ```
    #
    # Allow syntax:
    # ```
    # allow(dbl).to receive(:some_method)
    # allow(dbl).to receive(:the_answer).and_return(42)
    # ```
    def receive(method : Symbol)
      NilStub.new(method)
    end

    # Constructs a stub for a method.
    #
    # The *method* is the name of the method to stub.
    # The provided block is invoked when the stubbed method is called.
    #
    # Can syntax:
    # ```
    # dbl.can receive(:the_answer) { 42 }
    # ```
    #
    # Allow syntax:
    # ```
    # allow(dbl).to receive(:the_answer) { 42 }
    # ```
    def receive(method : Symbol, &block : -> _)
      ProcStub.new(method, block)
    end

    # Constructs multiple method stubs for an object.
    #
    # A collection of key-value pairs is used.
    # Each key is a method's name.
    # The value is what is returned by the corresponding method.
    #
    # Can syntax:
    # ```
    # dbl.can receive(the_answer: 42, some_method: "foobar")
    # ```
    #
    # Allow syntax:
    # ```
    # allow(dbl).to receive(the_answer: 42, some_method: "foobar")
    # ```
    def receive(**value_stubs)
      StubCollection.new(value_stubs)
    end
  end
end

# Automatically include DSL methods and use 'can' syntax for Crystal's Spec framework.
{% if @top_level.has_constant?(:Spec) %}
  require "./dsl/can"

  module Spec::Methods
    include Spectator::Mocks::DSL
  end
{% end %}
