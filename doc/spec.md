# Spec

This page contains documentation specific to using the [Spec](https://crystal-lang.org/reference/1.10/guides/testing.html) library with this shard.

## Enabling Mocks

To enable mocks, require the shard from inside `spec_helper.cr`.
It should be required after Spec so that the Mocks shard can detect it.

<!-- no-spec -->
```crystal
require "spec"
require "mocks"
```

Inside of your spec files, the "can" and "should" syntaxes are used.

## Defining Mocks

[Mocks](mocks.md) are defined by using the `mock` keyword outside of test code.
The `mock` keyword cannot be used inside a `describe`, `context`, `it` or similar blocks, such as hooks.
The syntax for `mock` is:

<!-- no-spec -->
```crystal
mock NewType < ExistingType
```

Where `NewType` is the name of the type to create and `ExistingType` is the type to mock (stub and replace) the behavior of.
For instance:

```crystal
class ExistingType
  # ...
end

mock NewType < ExistingType
```

Default stubs can be defined quickly by adding them as keyword arguments.

<!-- continue-spec -->
```crystal
mock NewType < ExistingType, method1: 1, method2: 2
```

More complex methods can be defined inside a block.

<!-- continue-spec -->
```crystal
mock NewType < ExistingType do
  def complex_method
    # ...
  end
end
```

One style of defining mocks is to place them at the top of the spec file they're used in.
The `private` visibility modifier should be used to avoid name collisions when multiple spec files are ran together.

<!-- continue-spec -->
```crystal
private mock TestMock < ExistingType

describe "MyService" do
  it "works" do
    # ...
  end
end
```

An alternative is to create a `mocks` (or similarly named) directory containing all of the mock definitions.
This can then be included from `spec_helper.cr`, like so:

<!-- no-spec -->
```crystal
require "mocks"
require "./mocks/**"
```

Mocks can be instantiated in example blocks and hooks.
Simply call `new` on the mock's type.

<!-- continue-spec -->
```crystal
private mock TestMock < ExistingType

describe "MyService" do
  it "works" do
    my_mock = TestMock.new
    # ...
  end
end
```

Mocks cannot be used outside of a test scope (e.g. an `it` block).
Specifically, they cannot be used in `before_all`, `after_all`, and `around_all` hooks.

## Defining Doubles

Defining a [double](doubles.md) is similar to [defining a mock](#defining-mocks).
Doubles are defined by using the `double` keyword outside of test code.
The `double` keyword cannot be used inside a `describe`, `context`, `it` or similar blocks, such as hooks.
The syntax for `double` is:

```crystal
double NewDouble
```

Where `NewDouble` is the name of the type to create.

**NOTE:** It is *highly* recommended that doubles in spec files are defined with the `private` visibility modifier.
This avoids collisions with the same name in multiple files.

Default stubs can be defined quickly by adding them as keyword arguments.

<!-- continue-spec -->
```crystal
private double NewDouble, method1: 1, method2: 2
```

More complex methods can be defined inside a block.

<!-- continue-spec -->
```crystal
private double NewDouble do
  def complex_method
    # ...
  end
end
```

Doubles can be instantiated in example blocks and hooks.
Simply call `new` on the doubles's type.

```crystal
private double TestDouble

describe "MyService" do
  it "works" do
    my_double = TestDouble.new
    # ...
  end
end
```

A [lazy double](doubles.md#lazy-doubles) can be created with the `new_double` method.
This creates a double without the need to define it ahead of time.

```crystal
describe "MyService" do
  it "works" do
    my_double = new_double(value: 42)
    my_double.value.should eq(42)
  end
end
```

Doubles cannot be used outside of a test scope (e.g. an `it` block).
Specifically, they cannot be used in `before_all`, `after_all`, and `around_all` hooks.

## "Can" Syntax

Stubs are defined and applied to stubbable objects with the `can` method.
The `can` method expects a stub as an argument.
Typically this is written similarly to the `object.should` syntax with a space after `can` and no parenthesis.
The fluent language syntax is used to construct a stub that is passed to `can`.
Use `receive` to start the [fluent syntax](stubs.md#fluent-language).

```crystal
private double TestDouble, value: 0

it "works" do
  my_double = TestDouble.new
  my_double.can receive(:value).and_return(42)
end
```

The `can` method is *only* available on stubbable objects ([mocks](#defining-mocks) and [doubles](#defining-doubles)).
A compiler error will occur when attempting to use `can` on an object that isn't stubbable.

<!-- no-spec -->
```crystal
it "can't stub non-stubbable objects" do
  string = "foobar"
  string.can receive(:size).and_return(42) # Error!
  string.size.should eq(42)
end
```

Results in:

    Error: undefined method 'can' for String

## "Should" Syntax

Expectations are created using Spec's `should` and `should_not` methods.
Use the `have_received` method to start the [fluent language syntax](expectations.md#fluent-language) to describe the call.

```crystal
private double TestDouble, value: 0

it "works" do
  my_double = TestDouble.new
  my_double.value
  my_double.should have_received(:value)
end
```