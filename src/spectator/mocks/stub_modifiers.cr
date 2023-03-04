module Spectator::Mocks
  module StubModifiers
    def and_return(value)
      ValueStub.new(method_name, value, arguments)
    end

    def with(*args, **kwargs)
      arguments = ArgumentsPattern.new(args, kwargs)
      with_arguments(arguments)
    end

    private abstract def with_arguments(arguments : AbstractArgumentsPattern?)
  end
end
