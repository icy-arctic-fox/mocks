require "./default_behavior"
require "./stubbable"

module Mocks
  # Double that can be quickly created and used within a test (function) without needing to define it in advance.
  # The *Methods* type argument must be a `NamedTuple`.
  # The entries in *Methods* the method names and their return types.
  # That is, if *Methods* is `{some_method: Int32}`,
  # then an instance of this double would return an `Int32` from `#some_method`.
  # This type of double will respond to all methods,
  # but only the methods with an entry in *Methods* can return a value.
  # Methods not defined will raise an `UnexpectedMessage` error.
  # ```
  # double = LazyDouble.new({some_method: 42, another_method: "example"})
  # double.some_method    # => 42
  # double.another_method # => "example"
  # double.unknown_method # raises `UnexpectedMessage`
  # ```
  @[DefaultBehavior(:original)]
  class LazyDouble(Methods)
    include Stubbable::Automatic

    @name : String? = nil

    # Creates a new lazy double with initial stubs.
    # The *name* can be anything or nil for an anonymous double.
    # The *values* must be a `NamedTuple`.
    def initialize(name, @values : Methods)
      {% raise "Type argument for #{LazyDouble} must be a NamedTuple" unless Methods <= NamedTuple %}

      @name = name.try &.to_s
      proxy = __mocks

      # Avoid producing a stub where each value is a union (don't use `#each`).
      # This is done by capturing the NamedTuple's type (and keys) via Methods.
      {% for key in Methods.keys %}
        proxy.add_stub(ValueStub.new({{key.symbolize}}, @values[{{key.symbolize}}]))
      {% end %}
    end

    # Creates a new lazy double with initial stubs.
    #
    # The *name* can be anything or nil for an anonymous double.
    # Specify default stubs by passing keyword arguments.
    # Each keyword is the name of a method to stub and its value is the value returned by that method.
    # ```
    # LazyDouble.new(:fake, some_method: 42, another_method: "foo")
    # ```
    def self.new(name = nil, **values)
      new(name, values)
    end

    # Constructs a string representation of the double.
    stub def to_s(io : IO) : Nil
      io << "#<Mocks::LazyDouble:0x"
      object_id.to_s(io, 16)
      if name = @name
        io << " \"#{name}\""
      else
        io << " anonymous"
      end
      io << '>'
    end

    macro method_missing(call)
      {% verbatim do %}
        {% if Methods.keys.includes?(@def.name) %}
          stubbed_method_body(as: :infer) do
            @values[{{@def.name.symbolize}}]
          end
        {% else %}
          raise UnexpectedMessage.new({{@def.name.symbolize}})
        {% end %}
      {% end %}
    end
  end
end
