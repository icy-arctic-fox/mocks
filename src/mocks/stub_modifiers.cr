module Mocks
  # Modifiers used to change the behavior of a stub applied to a method.
  # This makes up part of the fluent interface for the DSL.
  module StubModifiers
    # Modifies the stub to return a value.
    def and_return(value)
      ValueStub.new(method_name, value, arguments)
    end

    # Modifies the stub to raise an exception.
    def and_raise(exception : Exception)
      ExceptionStub.new(method_name, exception, arguments)
    end

    # Modifies the stub to raise an exception.
    # Creates a new exception of the specified type and forwards additional arguments to it.
    def and_raise(exception_type : Exception.class, *args, **kwargs)
      exception = exception_type.new(*args, **kwargs)
      and_raise(exception)
    end

    # Modifies the stub to raise an exception.
    # A `RuntimeError` with the specified message will be raised when the stub is called.
    def and_raise(message : String? = nil)
      exception = RuntimeError.new(message)
      and_raise(exception)
    end

    # Modifies the stub to only respond to the specified arguments.
    def with(*args, **kwargs)
      arguments = ArgumentsPattern.new(args, kwargs)
      with_arguments(arguments)
    end

    # Modifies the stub to only response to the specified arguments and invoke a block.
    def with(*args, **kwargs, &block : -> _)
      arguments = ArgumentsPattern.new(args, kwargs)
      ProcStub.new(method_name, block, arguments)
    end

    # Returns a variation of the same stub type with a specific argument pattern.
    private abstract def with_arguments(arguments : AbstractArgumentsPattern?)
  end
end
