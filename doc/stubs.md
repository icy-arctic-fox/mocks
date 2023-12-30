# Stubs

A stub defines replacement behavior of a method.
Stubs are commonly used to redefine behavior of methods for [mocks](mocks.md) and [doubles](doubles.md).
There are different types of stubs for various behaviors.

## Fluent language

Stubs are normally created with the fluent language (DSL) methods.
The language to create a stub typically starts with `receive`.
The `receive` method takes the name of the method to stub as a symbol.

For instance, with the "can" syntax used by Spec:

```crystal
private double TestDouble, value: 0

it "creates a stub" do
  my_double = TestDouble.new
  my_double.can receive(:value)
  #   ^      ^     ^ Starts the creation of a stub.
  #   |      + Accepts a stub and applies it to `my_double`.
  #   + Object to apply the stub to.
end
```

And similarly with the "allow" syntax used by Spectator:

<!-- framework:spectator -->
```crystal
private double TestDouble, value: 0

it "creates a stub" do
  my_double = TestDouble.new
  allow(my_double).to receive(:value)
  # ^       ^      ^     ^ Starts the creation of a stub.
  # |       |      + Accepts a stub and applies it to `my_double`.
  # |       + Thing to apply the stub to.
  # + Wraps an object to be stubbed.
end
```

When `receive` is used by itself, it will create a stub that returns nil.
Modifiers are typically added after the `receive` call to specify the stub's behavior.

### `and_return` Modifier

The `and_return` modifier is the simplest stub modifier.
It changes the return value.

```crystal
private double TestDouble, value: 0

it "modifies the return value" do
  my_double = TestDouble.new
  my_double.can receive(:value).and_return(42)
  my_double.value.should eq(42)
end
```

The type of value *must* match that of the original method.
Otherwise, `TypeCastError` is raised indicating the stub's value couldn't be returned.

<!-- no-spec -->
```crystal
private double TestDouble, value: 0 # Return type inferred to be `Int32`

it "cannot use a different type" do
  my_double = TestDouble.new
  my_double.can receive(:value).and_return("not a number") # Wrong!
  my_double.value.should eq("not a number") # Error!
end
```

In the example above, the following error is given at runtime:

    Attempted to return "not a number" (String) from stub, but method `value` expects type Int32 (TypeCastError)

### Block Modifier

The `receive` method can accept a block.
That block is executed when the stub is invoked.
The value returned by the block will be returned by the stub and the method.
This can be used to define dynamic behavior for stubs.

```crystal
private double TestDouble, add_item: nil

it "executes a block" do
  list = [] of Int32
  my_double = TestDouble.new
  my_double.can receive(:add_item) { list << list.size }
  3.times { my_double.add_item }
  list.should eq([0, 1, 2])
end
```

### `and_raise` Modifier

The `and_raise` modifier causes the stub to raise an exception when it is invoked.
This modifier accepts various arguments, all of which are used to specify the exception to raise.
The variants are:

`.and_raise(String)` - Raise a `RuntimeError` with the message specified.

```crystal
private double TestDouble, oof: nil

it "raises an error" do
  my_double = TestDouble.new
  my_double.can receive(:oof).and_raise("Something went wrong")
  expect_raises(RuntimeError, "Something went wrong") { my_double.oof }
end
```

`.and_raise(Exception)` - Specifies the exception object to raise.

<!-- continue-spec -->
```crystal
it "raises an error" do
  exception = DivisionByZeroError.new("You broke the universe")
  my_double = TestDouble.new
  my_double.can receive(:oof).and_raise(exception)
  expect_raises(DivisionByZeroError, "You broke the universe") do
    my_double.oof
  end
end
```

`.and_raise(Exception.class, *args, **kwargs)` - Creates an exception of type `Exception` by calling `new` on it and forwarding the rest of the arguments.

<!-- continue-spec -->
```crystal
it "raises an error" do
  my_double = TestDouble.new
  my_double.can receive(:oof).and_raise(NilAssertionError, "Value can't be nil")
  expect_raises(NilAssertionError, "Value can't be nil") { my_double.oof }
end
```

### `with` Modifier

**TODO**