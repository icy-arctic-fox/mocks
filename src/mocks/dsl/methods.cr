require "../anything"
require "../double"
require "../lazy_double"
require "../mock"
require "../nil_stub"
require "../proc_stub"
require "../stub_collection"
require "../unexpected_message"

module Mocks::DSL
  # Common DSL methods for defining mocks, doubles, and stubs.
  # This module should be included wherever necessary to specify DSL methods.
  module Methods
    alias UnexpectedMessage = ::Mocks::UnexpectedMessage

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
    Double.def_define_double double, type: ::Mocks::Double

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
    Mock.def_define_mock mock

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

    # Creates a new lazy double.
    #
    # The double returned by this method will respond to methods with the values specified in *values*.
    # An optional name can be given to the double to help with debugging.
    #
    # ```
    # double = new_double(:test_double, test_method: 42)
    # double.test_method # => 42
    # ```
    def new_double(name = nil, **values) : LazyDouble
      LazyDouble.new(name, values)
    end

    # Returns an object that returns true when compared to anything.
    def anything
      Anything.new
    end
  end
end
