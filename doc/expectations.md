# Expectations

Expectations provide a means to inspect the calls made to a stubbable object ([mock](mocks.md) or [double](double.md)).
The syntax varies by testing framework, but has a similar structure for each.

## Fluent language

Expectations are normally created with the fluent language (DSL) methods.
The language to create an expectation typically starts with `have_received`.
The `have_received` method takes the name of the method as a symbol.

For instance, with the "should" syntax used by [Spec](spec.md):

```crystal
private double TestDouble, value: 0

it "expects a call" do
  my_double = TestDouble.new
  my_double.value
  my_double.should have_received(:value)
  #   ^       ^           ^ Starts the creation of an expectation.
  #   |       + Accepts an expectation and verifies it against `my_double`.
  #   + Object to inspect.
end
```

And similarly with the "expect" syntax used by [Spectator](spectator.md):

<!-- framework:spectator -->
```crystal
private double TestDouble, value: 0

it "creates a stub" do
  my_double = TestDouble.new
  my_double.value
  expect(my_double).to have_received(:value)
  # ^       ^       ^         ^ Starts the creation of an expectation.
  # |       |       + Accepts an expectation and verifies it.
  # |       + Object to inspect.
  # + Wraps an object to be inspected.
end
```

**NOTE:** The `have_received` operation must be performed after the expected call.
The following will not work since the stub hasn't been called yet.

<!-- no-spec -->
```crystal
private double TestDouble, value: 0

it "creates a stub" do
  my_double = TestDouble.new
  expect(my_double).to have_received(:value) # Error!
  my_double.value
end
```

When `have_received` is used by itself, it will create an expectation that matches any arguments.
Modifiers are typically added after the `have_received` call to specify the expected arguments.

Expectations also work with negated matchers, e.g. `should_not`.

```crystal
private double TestDouble, value: 0

it "expects a call" do
  my_double = TestDouble.new
  # my_double.value
  my_double.should_not have_received(:value)
end
```

### `with` Modifier

The `with` modifier changes the arguments that must be matched for the expectation to pass.

```crystal
private double TestDouble, do_something: 0

it "can change the expected arguments" do
  my_double = TestDouble.new
  my_double.do_something(1)
  my_double.should have_received(:do_something).with(1)
end
```

All arguments are compared with the case-equality operator (`===`).

```crystal
private double TestDouble, do_something: 0

it "can pattern match arguments" do
  my_double = TestDouble.new
  my_double.do_something("foobar")
  my_double.should have_received(:do_something).with(/foo/)
end
```

The `with` modifier accepts multiple arguments.
They will be matched against the positional arguments in order.

```crystal
private double TestDouble, do_something: 0

it "can match multiple arguments" do
  my_double = TestDouble.new
  my_double.do_something(1, "foobar")
  my_double.should have_received(:do_something).with(1, /foo/)

  # First argument doesn't match.
  my_double.should_not have_received(:do_something).with(0, /foo/)

  # Second argument doesn't match.
  my_double.should_not have_received(:do_something).with(1, Symbol)
end
```

Keyword arguments can also be matched by using key-value pairs as arguments in `with`.

```crystal
private double TestDouble, do_something: 0

it "can match keyword arguments" do
  my_double = TestDouble.new
  my_double.do_something(arg: "foobar")
  my_double.should have_received(:do_something).with(arg: /foo/)

  # Value doesn't match.
  my_double.should_not have_received(:do_something).with(arg: Symbol)

  # Key doesn't match.
  my_double.should_not have_received(:do_something).with(foo: /foo/)
end
```

Positional arguments and keyword arguments can be mixed.

```crystal
private double TestDouble, do_something: 0

it "can match positional and keyword arguments" do
  my_double = TestDouble.new
  my_double.do_something(1, arg: "foobar")
  my_double.should have_received(:do_something).with(1, arg: /foo/)

  # Positional argument doesn't match.
  my_double.should_not have_received(:do_something).with(0, arg: "foobar")

  # Keyword argument doesn't match.
  my_double.should_not have_received(:do_something).with(1, arg: "baz")
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
  my_double.log(:warn, "oof")
  my_double.should have_received(:log).with(level: :warn, message: anything)
end
```

### Count Modifiers

The number of times a stub was called can be checked.
There are multiple fluent language methods to check for call counts.

- `once` - The method was called exactly once.
- `twice` - The method was called exactly twice.
- `exactly(n).times` - The method was called exactly *n* times.
- `at_least(n).times` - The method was called at least *n* times.
- `at_most(n).times` - The method was called at most *n* times.

The `at_least` and `at_most` modifiers are *inclusive*.

```crystal
private double TestDouble, one: 1, two: 2, three: 3, more: 4

it "can expect call counts" do
  my_double = TestDouble.new

  1.times { my_double.one }
  my_double.should have_received(:one).once

  2.times { my_double.two }
  my_double.should have_received(:two).twice

  3.times { my_double.three }
  my_double.should have_received(:three).exactly(3).times
end

it "can expect ranges of call counts" do
  my_double = TestDouble.new

  5.times { my_double.more }
  my_double.should have_received(:more).at_least(3).times
  my_double.should have_received(:more).at_most(5).times
end
```

There are variations of those methods that use `:once` and `:twice` as keywords:

- `exactly(:once)` and `exactly(:twice)`
- `at_least(:once)` and `at_least(:twice)`
- `at_most(:once)` and `at_most(:twice)`

The method used is a matter of preference.

```crystal
private double TestDouble, one: 1, two: 2, three: 3

it "can expect call counts" do
  my_double = TestDouble.new

  1.times { my_double.one }
  my_double.should have_received(:one).once

  2.times { my_double.two }
  my_double.should have_received(:two).exactly(:twice)

  3.times { my_double.three }
  my_double.should have_received(:three).at_least(:twice)
end
```

Call counts can also be mixed with argument matching using the `with` modifier.

```crystal
private double TestDouble, do_something: 0

it "can mix `with` and call counts" do
  my_double = TestDouble.new

  3.times { |i| my_double.do_something(i) }
  my_double.should have_received(:do_something).with(1).once
  my_double.should have_received(:do_something).with(Int).at_least(:twice)
end
```