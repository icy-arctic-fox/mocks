module Spectator::Mocks
  # Modifiers used to change the behavior of a stub applied to a method.
  # This makes up part of the fluent interface for the DSL.
  module StubModifiers
    # Modifies the stub to return a value.
    def and_return(value)
      ValueStub.new(method_name, value, arguments)
    end

    # Modifies the stub to only respond to the specified arguments.
    def with(*args, **kwargs)
      arguments = ArgumentsPattern.new(args, kwargs)
      with_arguments(arguments)
    end

    # Returns a variation of the same stub type with a specific argument pattern.
    private abstract def with_arguments(arguments : AbstractArgumentsPattern?)
  end
end
