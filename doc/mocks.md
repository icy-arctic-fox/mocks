# Mocks

A mock is an object that extends an existing type and is intended to be used as a lightweight replacement.
This is commonly used when a method needs an object of a specific type, but constructing a real one would be costly or reach outside the bounds of the test.

Mocks are type-safe and conform to an existing type.
If type restrictions aren't in place, consider using a [double](double.md) instead.

Before a mock can be used, it must be defined.
A mock extends an existing type, so the originating type must be included in the definition.
Typically, a mock is defined using the `mock` keyword, like so:

```crystal
# Original type to mock.
class Original
end

mock MyMock < Original
```

Then after the mock is defined, it can be initialized.

<!-- continue-spec -->
```crystal
it "works" do
  MyMock.new
end
```

A mock can be defined as private to the file it's contained in by adding the `private` visibility modifier.
This is *highly recommended* for specs since mock with the same name will collide.
See [Private top-level types](https://crystal-lang.org/reference/1.10/syntax_and_semantics/visibility.html#private-top-level-types) from the Crystal docs.

<!-- continue-spec -->
```crystal
private mock MyMock < Original
```

Often times, the original type being mocked has instance variables that must be initialized.
If that is the case, then a custom initializer with no parameter must be defined for the mock.
The initializer should set instance variables to reasonable defaults, [null objects](https://en.wikipedia.org/wiki/Null_object_pattern), or mocks of their types.

```crystal
private class OriginalWithVars
  def initialize(@value : String)
  end
end

private mock MyVarsMock < OriginalWithVars do
  def initialize
    @value = ""
  end
end

it "works with instance variables" do
  MyVarsMock.new
end
```

## Stubbing mocks

A mock type redefines all methods from its original type to support stubs.
Unlike [doubles](./doubles.md#stubbing-doubles), no methods need to be defined in advance to use them.
Mocks are strict by default.
Aside from a few standard methods, all methods in the mock will raise an `Mocks::UnexpectedMessage` error if they're called.

<!-- no-spec -->
```crystal
private class Original
  def some_method
    42
  end
end

private mock TestMock < Original

it "works" do
  mock = TestMock.new
  mock.some_method # Error!
end
```

Produces the error:

    Unexpected method `some_method` was called (Mocks::UnexpectedMessage)

Methods can be *stubbed* to define their behavior when they're called.
There are multiple ways to do this.

```crystal
private class Original
  def some_method
    42
  end
end

private mock TestMock < Original

it "works" do
  mock = TestMock.new
  mock.can receive(:some_method).and_return(0)
  mock.some_method # Works!
end
```

Stubs are used to specify the behavior of a method.
For more details on stubs, see [stubs](stubs.md).

The stub's type must match the type returned by the original method.
If it doesn't, a `TypeCast` error is raised at runtime.

<!-- no-spec -->
```crystal
it "doesn't work" do
  mock = TestMock.new
  mock.can receive(:some_method).and_return("Test")
  mock.some_method # Error!
end
```

Produces the following error:

    Attempted to return "Test" (String) from stub, but method `some_method` expects type Int32 (TypeCastError)

Remember to not add the `and_return` modifier when the original method returns a value.
Without the modifier, the stub returns nil, which may cause a `TypeCast` error.

A simple way to allow a method to be called is by creating a stub using the [`and_call_original` modifier](./stubs.md#and_call_original-modifier).

```crystal
private class Original
  def some_method
    42
  end
end

private mock TestMock < Original

it "works" do
  mock = TestMock.new
  mock.can receive(:some_method).and_call_original
  mock.some_method # Works!
end
```

## Default stubs

A mock can have default stubs assigned to it.
These are stubs that get invoked when no other stubs have replaced them.
This can be useful to quickly specify common behavior and return values.
There are a couple of ways to declare default stubs.

### Keyword arguments

The first is to pass keyword arguments in the mock's definition.
Each keyword is the method's name and the value is the method's return value.

```crystal
private class Original
  def some_method
    42
  end
end

private mock TestMock < Original, some_method: 0

it "works" do
  mock = TestMock.new
  mock.some_method.should eq(0)
end
```

When using default stubs in this way, all overloaded methods (those with the same name, but different arguments) will use the stub.

**NOTE:** Doubles define methods that accept any arguments when using [keyword argument based default stubs](doubles.md#keyword-arguments).
Mocks do not, only the methods with the same name from the original type can be called.

```crystal
private class Original
  def some_method
    42
  end

  def some_method(value)
    value + 1
  end
end

private mock TestMock < Original, some_method: 0

it "works" do
  mock = TestMock.new
  mock.some_method.should eq(0)
  mock.some_method(1).should eq(0)
  # The following won't compile because there are no overloads that accepts these arguments.
  # mock.some_method(1, 2).should eq(0) # Error!
end
```

**NOTE:** Any blocks passed to default stubs declared with keyword arguments will not be yielded to.

### Definition body

Another way to declare default stubs is in the definition body of `mock`.
This allows more complex code (than simply returning a value) to be defined.

```crystal
private class Original
  def stringify(value)
    value.to_s
  end
end

private mock TestMock < Original do
  def stringify(value)
    "Test"
  end
end

it "defines methods in a block" do
  mock = TestMock.new
  mock.stringify(42).should eq("Test")
end
```

Default stubs declared in this way only accept arguments in the method definition.
Attempting to call a stubbed method with mismatched arguments will fail to compile.

**WARNING:** Be sure the method signatures in the mock body match their original *exactly*.
If they don't, a new method may be defined that doesn't exist on the original.
See [#4](https://github.com/icy-arctic-fox/mocks/issues/4).

Different behavior for overloaded methods can be handled in a `mock` block.

```crystal
private class Original
  def stringify(value : Float)
    sprintf("%2.2f", value)
  end

  def stringify(value)
    value.to_s
  end
end

private mock TestMock < Original do
  def stringify(value : Float)
    "50.00"
  end

  def stringify(value)
    "Test"
  end
end

it "can define different behavior for overloaded methods" do
  mock = TestMock.new
  mock.stringify(42).should eq("Test")
  mock.stringify(25.75).should eq("50.00")
end
```

Blocks can be yielded to with this style.

```crystal
private class Original
  def each(& : Int32 -> _)
    yield 42
  end
end

private mock TestMock < Original do
  def each(& : Int32 -> _)
    yield 0
  end
end

it "accepts a block" do
  mock = TestMock.new
  mock.each do |value|
    value.should eq(0)
  end
end
```

The two styles of default stubs can be mixed.
Stubs declared in the block body override (take precedence) over the stubs declared with keyword arguments.

```crystal
private class Original
  def value
    42
  end

  def some_method
    42
  end

  def some_method(value)
    value + 1
  end
end

private mock TestMock < Original, value: 5, some_method: 0 do
  def some_method(value)
    value - 1
  end
end

it "allows mixing styles" do
  mock = TestMock.new
  mock.value.should eq(5)
  mock.some_method.should eq(0)
  mock.some_method(3).should eq(2)
end
```

## Abstract types and methods

Abstract types (classes and structs) can be mocked.

```crystal
private abstract class AbstractBase
  abstract def some_method : String
end

private mock AbstractMock < AbstractBase

it "stubs abstract types and methods" do
  mock = AbstractMock.new
  mock.can receive(:some_method).and_return("Test")
  mock.some_method.should eq("Test")
end
```

**WARNING:** The stubbed method copies the return type of the abstract method.
If there's no type restriction, `Nil` is used.
A type restriction must be specified in the *original type* if a stub is used that doesn't return `nil`.

<!-- no-spec -->
```crystal
private abstract class AbstractBase
  abstract def value
end

private mock AbstractMock < AbstractBase

it "requires a type restriction" do
  mock = AbstractMock.new
  mock.can receive(:value).and_return(42)
  mock.value.should eq(42) # Fails, nil is returned instead of 42.
end
```

To fix, add a type restriction to the original type.

```diff
private abstract class AbstractBase
-  abstract def value
+  abstract def value : Int32
end

private mock AbstractMock < AbstractBase

it "requires a type restriction" do
  mock = AbstractMock.new
  mock.can receive(:value).and_return(42)
  mock.value.should eq(42) # Works!
end
```

## Class mocks

A mock's class methods can be stubbed.
Default stubs for class methods cannot be defined with [keyword arguments](#keyword-arguments).
Instead, they're defined in the mock's definition block body.

```crystal
private class Original
  def self.add_one(value)
    value + 1
  end
end

private mock TestMock < Original do
  stub def self.add_one(value)
    value + 2
  end
end

it "can use the mock's class type" do
  TestMock.add_one(2).should eq(4)
end
```

**NOTE:** The `stub` keyword is required for class methods, normally it is optional.
See [#3](https://github.com/icy-arctic-fox/mocks/issues/3).

The mock's type is stubbable itself, so methods like `can` work on it.
The behavior of the method can be changed.
Stub changes persist only for the duration of the test.

<!-- continue-spec -->
```crystal
it "can change the behavior" do
  TestMock.can receive(:add_one).and_return(0)
  TestMock.add_one(2).should eq(0)
end

it "reverts stubs between tests" do
  TestMock.add_one(2).should eq(4)
end
```

The `class` method behaves as expected on a mock.

<!-- continue-spec -->
```crystal
it "can use the mock's class" do
  TestMock.can receive(:add_one).and_return(0)
  mock = TestMock.new
  mock.class.add_one(2).should eq(0)
end
```

## Module mocks

Mocks for modules are defined the same way as classes and structs.
A type is defined that includes the module to mock.
Unlike class and struct mocks, module mocks are not strict by default.
All methods from the original module can be called, except for abstract methods.
Abstract methods must be stubbed or an error will be raised.

    Attempted to call abstract method `each` (Mocks::UnexpectedMessage)

### Testing against mixin modules

One way to use a mock module is for type restrictions that utilized a module as a mixin.
To give a concrete example, say a method requires an [`Enumerable`](https://crystal-lang.org/api/latest/Enumerable.html) object.

```crystal
def build_list(elements : Enumerable) : String
  return "(empty)" if elements.empty?

  String.build do |io|
    elements.each_with_index(1) do |item, i|
      io << i << ". " << item
      io.puts
    end
  end
end
```

The mock would include [`Enumerable`](https://crystal-lang.org/api/latest/Enumerable.html)
and implement its abstract methods ([`#each`](https://crystal-lang.org/api/latest/Enumerable.html#each%28%26%3AT-%3E%29-instance-method)).

<!-- continue-spec -->
```crystal
private mock MockEnumerable < Enumerable(String) do
  def each(& : String ->) : Nil
    yield "one"
    yield "two"
    yield "three"
  end
end
```

The `build_list` method from above could be tested like so:

<!-- continue-spec -->
```crystal
it "produces a numbered list" do
  mock = MockEnumerable.new
  build_list(mock).should eq("1. one\n2. two\n3. three\n")
end

it "produces '(empty)' when there are no elements" do
  mock = MockEnumerable.new
  mock.can receive(:each) # Causes method to not yield.
  build_list(mock).should eq("(empty)")
end
```

This type of mock is similar to:

```crystal
class MockEnumerable
  include Enumerable(String)

  def each(& : String ->) : Nil
    yield "one"
    yield "two"
    yield "three"
  end
end
```

### Testing mixin modules

Another use of mock modules is for testing a module to be used as a mixin.
For instance, to test this module:

```crystal
private module MyMixin
  abstract def value : Int32
  def add_one
    value + 1
  end
end

private mock MockMixin < MyMixin

it "adds one to the value" do
  mixin = MockMixin.new
  mixin.can receive(:value).and_return(1)
  mixin.add_one.should eq(2)
end
```

## Practical example

In this example, a database connector object is mocked.
The `Service` class is being tested.

```crystal
abstract class Database
  abstract def put(key, **values)
end

class Service
  def initialize(@db : Database)
  end

  def update_record(id, value)
    @db.put(id, value: value)
  end
end
```

The `update_record` method could be tested like so:

<!-- continue-spec -->
```crystal
private mock MockDatabase < Database

describe Service do
  describe "#update_record" do
    it "updates the database" do
      mock_db = MockDatabase.new
      mock_db.can receive(:put)

      service = Service.new(mock_db)
      service.update_record(42, "Test")
      
      mock_db.should have_received(:put).with(42, value: "Test")
    end
  end
end
```

## Injecting mocks

Mock functionality can be added to existing types.
This is intended for types outside of the control of the application,
such as other shards and the standard library.

**NOTE:** Use this feature only when necessary.
  Types will be modified and differ fundamentally (on a binary level) from non-test code.

The `mock!` keyword is typically used for this feature.
It takes the type to modify as an argument.

```crystal
class ExistingClass
  def value
    0
  end
end

mock! ExistingClass

it "allows stubbing existing types" do
  obj = ExistingClass.new
  obj.can receive(:value).and_return(42)
  obj.value.should eq(42)
end
```

Default stubs can be defined in the same way as [`mock`](#default-stubs).

```crystal
class AnotherClass
  def value
    0
  end

  def another_value
    :xyz
  end
end

mock!(AnotherClass, value: 42) do
  def another_value
    :abc
  end
end

it "can define default stubs" do
  obj = AnotherClass.new
  obj.value.should eq(42)
  obj.another_value.should eq(:abc)
end
```

### Example of Injection

Say part of the application launches a sub-process.
For testing, that sub-process should be mocked.
The `mock!` feature can be used on the [standard library's `Process`](https://crystal-lang.org/api/latest/Process.html).

```crystal
mock! Process

it "mocks launching a sub-process" do
  Process.can receive(:run).and_return(Process::Status.new(0xff00))
  outcome = Process.run("echo")
  outcome.system_exit_status.should eq(0xff00)
end
```
