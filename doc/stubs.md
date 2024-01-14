# Stubs

A stub defines replacement behavior of a method.
Stubs are commonly used to redefine behavior of methods for [mocks](mocks.md) and [doubles](doubles.md).
There are different types of stubs for various behaviors.

## Fluent language

Stubs are normally created with the fluent language (DSL) methods.
The language to create a stub typically starts with `receive`.
The `receive` method takes the name of the method to stub as a symbol.

For instance, with the "can" syntax used by [Spec](spec.md):

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

And similarly with the "allow" syntax used by [Spectator](spectator.md):

<!-- framework:spectator -->
```crystal
private double TestDouble, value: 0

it "creates a stub" do
  my_double = TestDouble.new
  allow(my_double).to receive(:value)
  # ^       ^      ^     ^ Starts the creation of a stub.
  # |       |      + Accepts a stub and applies it to `my_double`.
  # |       + Object to apply the stub to.
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

The `and_return` modifier can accept a list of arguments.
Each call to the stub returns the next argument.

```crystal
private double TestDouble, value: 0

it "returns multiple values" do
  my_double = TestDouble.new
  my_double.can receive(:value).and_return(1, 2, 3)
  my_double.value.should eq(1)
  my_double.value.should eq(2)
  my_double.value.should eq(3)
end
```

After all of the arguments are exhausted, the last one is returned for additional calls.

```crystal
private double TestDouble, value: 0

it "returns multiple values" do
  my_double = TestDouble.new
  my_double.can receive(:value).and_return(1, 2, 3)
  my_double.value.should eq(1)
  my_double.value.should eq(2)
  my_double.value.should eq(3)

  my_double.value.should eq(3)
  my_double.value.should eq(3)
end
```

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

The `with` modifier changes the arguments that must be matched to trigger the stub.
The default stub is used if none of the other argument patterns match.

```crystal
private double TestDouble, do_something: 0

it "can change the expected arguments" do
  my_double = TestDouble.new
  my_double.can receive(:do_something).with(1).and_return(42)
  my_double.do_something(1).should eq(42) # Matches the stub above.
  my_double.do_something(2).should eq(0)  # Uses the default stub.
end
```

All arguments are compared with the case-equality operator (`===`).

```crystal
private double TestDouble, do_something: 0

it "can pattern match arguments" do
  my_double = TestDouble.new
  my_double.can receive(:do_something).with(/foo/).and_return(42)
  my_double.do_something("foobar").should eq(42)
  my_double.do_something("baz").should eq(0)
end
```

The `with` modifier accepts multiple arguments.
They will be matched against the positional arguments in order.

```crystal
private double TestDouble, do_something: 0

it "can match multiple arguments" do
  my_double = TestDouble.new
  my_double.can receive(:do_something).with(1, /foo/).and_return(42)
  my_double.do_something(1, "foobar").should eq(42)
  my_double.do_something(0, "foobar").should eq(0) # First argument doesn't match.
  my_double.do_something(1, "baz").should eq(0)    # Second argument doesn't match.
end
```

Keyword arguments can also be matched by using key-value pairs as arguments in `with`.

```crystal
private double TestDouble, do_something: 0

it "can match keyword arguments" do
  my_double = TestDouble.new
  my_double.can receive(:do_something).with(arg: /foo/).and_return(42)
  my_double.do_something(arg: "foobar").should eq(42)
  my_double.do_something(arg: "baz").should eq(0)    # Value doesn't match.
  my_double.do_something(foo: "foobar").should eq(0) # Key argument doesn't match.
end
```

Positional arguments and keyword arguments can be mixed.

```crystal
private double TestDouble, do_something: 0

it "can match positional and keyword arguments" do
  my_double = TestDouble.new
  my_double.can receive(:do_something).with(1, arg: /foo/).and_return(42)
  my_double.do_something(1, arg: "foobar").should eq(42)
  my_double.do_something(0, arg: "foobar").should eq(0) # Positional argument doesn't match.
  my_double.do_something(1, arg: "baz").should eq(0)    # Keyword argument doesn't match.
end
```

Positional arguments can be matched with keyword arguments.
This is more explicit.
It may be useful to use the `anything` keyword to match the other arguments.

```crystal
private double LoggerDouble do
  def log(level, message)
    false
  end
end

it "can match positional arguments with keyword arguments" do
  my_double = LoggerDouble.new
  my_double.can receive(:log).with(level: :warn, message: anything).and_return(true)
  my_double.log(:warn, "oof").should be_true
  my_double.log(:info, "foo").should be_false
end
```

The `with` modifier can take a block, which is used for the return value.

```crystal
private double TestDouble, do_something: 0

it "accepts a block" do
  my_double = TestDouble.new
  my_double.can receive(:do_something).with(1) { 42 }
  my_double.do_something(1).should eq(42)
end
```