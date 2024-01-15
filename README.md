# Mocks

A utility library providing mock functionality in [Crystal](https://crystal-lang.org).
Intended to be used for testing, but can be used anywhere.
Integrates seamlessly with Crystal's default [Spec](https://crystal-lang.org/reference/1.10/guides/testing.html) library.
Inspired by [RSpec's mocks](https://rspec.info/features/3-12/rspec-mocks/).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   development_dependencies:
     mocks:
       github: icy-arctic-fox/mocks
   ```

2. Run `shards install`

## Usage

For detailed usage instructions, check the [docs](doc/index.md).

### Mocks and Doubles

This shard provides two types implementations - *mocks* and *doubles*.

Mock types are used when an existing type needs to be substituted.
Double types are used when "something" needs to be provided in place of a real object.
In other words, mocks extend from real, existing types and doubles are generic objects defined on-the-fly to fill a gap.

**As a rule of thumb:** use a double unless a type restriction is involved, then use a mock.

If you're familiar with [RSpec's mocks](https://rspec.info/features/3-12/rspec-mocks/), doubles can be thought of as a basic [double](https://rspec.info/features/3-12/rspec-mocks/basics/test-doubles/).
And mocks can be thought of as a [verifying double](https://rspec.info/features/3-12/rspec-mocks/verifying-doubles/).
RSpec provides a variety of doubles for different functionality, for example spies and partial doubles.
This shard has distilled them down to two types and includes that functionality into a module shared by mocks and doubles.

Both mocks and doubles must be defined before they're instantiated and used.
This is typically done with the the `mock` and `double` keyword
The implementation may vary by testing framework, see below.

### Stubs

An important feature of mocking is the ability to redefine methods.
A *stub* is an object that does this.
It works on anything that is *stubbable*, which includes mocks and doubles.
In the examples above, *default stubs* were defined in the definition line.
However, stubs can be defined and used anywhere, even after initializing a mock or double.

### Spec

The following instructions work for Crystal's Spec [Spec](https://crystal-lang.org/reference/1.10/guides/testing.html) library.

Add the following to your `spec_helper.cr`:

<!-- no-spec -->
```crystal
require "mocks"
```

#### Doubles

Doubles are defined with the `double` keyword.
This must be placed *outside* of blocks such as `describe` and `it`.
This is because the `double` keyword (macro) defines a type.

Here's a simple example:

```crystal
double MyDouble, value: 42
```

This defines the double `MyDouble` that returns `42` when `value` is called.

Then to use the double in a test, simply initialize it.

<!-- continue-spec -->
```crystal
it "works" do
  double = MyDouble.new
  double.value.should eq(42)
end
```

For more information on doubles, see the [documentation on doubles](doc/doubles.md).

#### Mocks

Mocks are defined with the `mock` keyword.
Again, this must be placed *outside* of blocks such as `describe` and `it`.
The only difference from a `double` definition is that a base type must be specified.

```crystal
# Class to be mocked.
class MyClass
  def value
    # Some complex computation...
    42
  end
end

# Define a mock of MyClass.
mock MockMyClass < MyClass, value: 0
```

This defines a `MockMyClass` type that inherits from `MyClass`.
The `value` method is redefined to return 0 instead of 42.

Then, similar to doubles, to use a mock in a test, initialize it.

<!-- continue-spec -->
```crystal
it "works" do
  mock = MockMyClass.new
  mock.value.should eq(0)
end
```

For more information on mocks, see the [documentation on mocks](doc/mocks.md).

#### Stubs

The `can` method applies a stub to a stubbable object (mock or double).

```crystal
double MyDouble, value: 42

it "works" do
  double = MyDouble.new

  # Default stub is invoked here.
  double.value.should eq(42)

  # Redefine the behavior of `#value`.
  double.can receive(:value).and_return(0) 

  # New stub is invoked here.
  double.value.should eq(0)
end
```

The syntax for defining a stub is as follows:

```text
  double.can receive(:method)[.and_]
    ^     ^     ^       ^       ^ Stub behavior
    |     |     |       + Method name as a symbol
    |     |     + Start of stub definition
    |     + Modifier method (start of natural language DSL)
    + Stubbable object
```

By default, stubs return `nil` if the `and_return` portion is omitted.

**Important note:** When defining a stub, its return value *must match* the type of the original method.

For more information on stubs, see the [documentation on stubs](doc/stubs.md).

#### Expecting Behavior

Stubbable objects track their method calls.
These can be inspected later to ensure actions were taken on them.
For instance, ensuring that a service is calling the `error` method on a mock logger.

This is achieved by using the `have_received` expectation.

```crystal
double MyDouble, value: 42

it "works" do
  double = MyDouble.new
  double.value # This method call is tracked.
  double.should have_received(:value)
end
```

Additionally, the arguments of the method call can be inspected.

```crystal
double MyDouble, value: 42

it "works" do
  double = MyDouble.new
  double.value("This is a test") # This method call is tracked.
  double.should have_received(:value).with("This is a test")
end
```

The syntax for expecting behavior is as follows:

```text
  double.should have_received(:method)[.with]
    ^      ^          ^          ^       ^ Modifier
    |      |          |          + Method name as a symbol
    |      |          + Start of expectation
    |      + Assertion method (start of natural language DSL)
    + Stubbable object
```

For more information on how to expect method calls, see the [documentation on expectations](doc/expectations.md).

### Known Limitations

#### Type restrictions on mocked types must use the absolute name

The following code does not work:

<!-- no-spec -->
```crystal
module Nested
  class Sibling
  end

  abstract class AbstractClass
    abstract def sibling : Sibling
  end
end

mock NamespaceAbstractClassMock < Nested::AbstractClass
```

Produces the error:

    Error: can't resolve return type Sibling

As a workaround, use an absolute name for the type restriction.

```diff
module Nested
  class Sibling
  end

  abstract class AbstractClass
-    abstract def sibling : Sibling
+    abstract def sibling : Nested::Sibling
  end
end

mock NamespaceAbstractClassMock < Nested::AbstractClass
```

See issue [#1](https://github.com/icy-arctic-fox/mocks/issues/1) for details.

#### Concrete structs cannot be mocked

The following code does not work:

<!-- no-spec -->
```crystal
struct MyStruct
end

mock MockMyStruct < MyStruct
```

Produces the error:

    Error: can't extend non-abstract struct MyStruct

Crystal does not allow [extending concrete structs](https://crystal-lang.org/reference/1.10/syntax_and_semantics/structs.html#inheritance).
There isn't a workaround at this time.
See issue [#2](https://github.com/icy-arctic-fox/mocks/issues/2) for details.

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/icy-arctic-fox/mocks/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Michael Miller](https://github.com/icy-arctic-fox) - creator and maintainer
