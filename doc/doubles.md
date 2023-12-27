# Doubles

A double is an object that stands in for something else.
This is commonly used when a method needs an object, but constructing a real one would be costly or reach outside the bounds of the test.

If there's a type restriction, use a [mock](mocks.md) instead.

Before a double can be used, it must be defined.
Typically, a double is defined using the `double` keyword, like so:

```crystal
double MyDouble
```

Then after the double is defined, it can be initialized.

<!-- continue-spec -->
```crystal
it "works" do
  MyDouble.new
end
```

A double can be defined as private to the file it's contained in by adding the `private` visibility modifier.
This is *highly recommended* for specs since doubles with the same name will collide.
See [Private top-level types](https://crystal-lang.org/reference/1.10/syntax_and_semantics/visibility.html#private-top-level-types) from the Crystal docs.

```crystal
private double MyDouble
```

Additionally, doubles can be given a name.
This may be useful for tracking what they represent.
The first argument to the double's initializer is its name.

<!-- no-spec -->
```crystal
it "can have a name" do
  MyDouble.new("Example")
end
```

The name argument can be anything, even a type literal, such as `Array`.

## Stubbing doubles

A double must have the methods that will called on it defined.
That is, a double doesn't implement a method without being told to.
The following does not work:

<!-- no-spec -->
```crystal
private double TestDouble

it "doesn't have a method" do
  double = TestDouble.new
  double.some_method # Error!
end
```

This results in the error:

    Error: undefined method 'some_method' for TestDouble

To define a stubbable method, provide a block to the double's definition. In the block's body, define an abstract method with the `stub` modifier keyword.

```crystal
private double TestDouble do
  stub abstract def some_method
end
```

This is a plain method definition and can have arguments and type restrictions.

Now `TestDouble` can have `some_method` called on it.

<!-- no-spec -->
```crystal
it "does have a method" do
  double = TestDouble.new
  double.some_method # Compiles!
end
```

However, running this code results in a runtime error.

    Attempted to call abstract method `some_method` (Mocks::UnexpectedMessage)

This is because no behavior was defined for the method.
Doubles are strict by default.
They *do not* respond to methods unless they are explicitly told to do so.
A `Mocks::UnexpectedMessage` error is raised whenever a double has a method called and no behavior was specified.

**NOTE:** Sending and receiving messages is an alternate way to think of calling methods on objects.
This nomenclature was copied from RSpec and is where `UnexpectedMessage` comes from.

A stub is used to specify the behavior of the method.

<!-- continue-spec -->
```crystal
it "does have a method" do
  double = TestDouble.new
  double.can receive(:some_method)
  double.some_method # Works!
end
```

For more details on stubs, see [stubs](stubs.md).

The standard methods that are defined on all objects, such as `to_s` and `==`, *do* respond by default.
These methods have reasonable default behaviors and can be changed if needed.

```crystal
private double TestDouble

it "responds to standard methods" do
  double = TestDouble.new
  double.to_s.should contain("Double")
end
```

So far, this is a fairly verbose way to define stubs.
There are easier ways, which are explained shortly.

## Default stubs

A double can have default stubs assigned to it.
These are stubs that get invoked when no other stubs have replaced them.
This can be useful to quickly specify common behavior and return values.
There are a couple of ways to declare default stubs.

### Keyword arguments

The first is to pass keyword arguments in the double's definition.
Each keyword is the method's name and the value is the method's return value.

```crystal
private double TestDouble, a: 1, b: 2, c: 3

it "works" do
  double = TestDouble.new
  double.a.should eq(1)
  double.b.should eq(2)
  double.c.should eq(3)
end
```

When using default stubs in this way, the underlying methods are defined to accept any arguments, even blocks.

<!-- continue-spec -->
```crystal
it "accepts arguments" do
  double = TestDouble.new

  double.a("Test").should eq(1)

  # Keyword arguments are supported.
  double.b(42, keyword: "test").should eq(2)

  # Blocks are supported as well.
  double.c(:test) do
    # Do something...
  end.should eq(3)
end
```

**NOTE:** Any blocks passed to default stubs declared in this way will not be yielded to.

The return type of the methods representing these stubs will be inferred.
If the type should be a union, use syntax like this:

```crystal
private double TestDouble, union: "Test".as(String?)

it "infers the type" do
  double = TestDouble.new
  typeof(double.union).should eq(String?)
end
```

### Definition body

Another way to declare default stubs is in the definition body of `double`.
This allows for finer control of arguments and types.
Additionally, the code run by the stub can be specified.

```crystal
private double TestDouble do
  def stringify(value)
    value.to_s
  end
end

it "defines methods in a block" do
  double = TestDouble.new
  double.stringify(42).should eq("42")
end
```

NOTE: The `stub` keyword in the block body is optional for instance methods.

Default stubs declared in this way only accept arguments in the method definition.
Attempting to call a stubbed method with mismatched arguments will fail to compile.

<!-- no-spec -->
```crystal
private double TestDouble do
  def stringify(value)
    value.to_s
  end
end

it "doesn't compile" do
  double = TestDouble.new
  double.stringify(1, 2, 3).should eq("1, 2, 3") # Error!
end
```

Methods can be overloaded this way.

```crystal
private double TestDouble do
  def stringify(value)
    value.to_s
  end

  def stringify(a, b, c)
    "#{a}, #{b}, #{c}"
  end
end

it "allows method overloads" do
  double = TestDouble.new
  double.stringify(1, 2, 3).should eq("1, 2, 3") # Works!
end
```

Blocks can be yielded to with this style.

```crystal
private double TestDouble do
  def each(& : Int32 -> _)
    yield 42
  end
end

it "accepts a block" do
  double = TestDouble.new
  double.each do |value|
    value.should eq(42)
  end
end
```

The two styles of default stubs can be mixed.
Stubs declared in the block body override (take precedence) over the stubs declared with keyword arguments.
This can be useful for fallback behavior and changing the return type.

```crystal
private double TestDouble, value: 0, stringify: "Test" do
  def stringify(value)
    value.to_s
  end

  def another_method
    "Another Test"
  end
end

it "allows mixing styles" do
  double = TestDouble.new
  double.value.should eq(0)
  double.stringify.should eq("Test")   # Uses stub from the keyword arguments.
  double.stringify(42).should eq("42") # Uses stub from the block body.
  double.another_method.should eq("Another Test")
end
```

## Initializer stubs

Stubs can be passed to the double when it is initialized.
This can be useful to change the stub's behavior and still use a default for other instances.

```crystal
private double TestDouble, value: 0

it "accepts stubs in the initializer" do
  double = TestDouble.new(value: 42)
  double.value.should eq(42)
end

it "uses the default stub" do
  double = TestDouble.new
  double.value.should eq(0)
end
```

An important thing to note, the value of the stub passed to the initializer must be the same type used in the double's definition.
If it doesn't, an error will be raised when attempting to call the stub.

<!-- no-spec -->
```crystal
private double TestDouble, value: 0

it "must be the same type" do
  double = TestDouble.new(value: "Not a number")
  double.value.should eq("Not a number") # Error!
end
```

The error in this case is:

    Attempted to return "Not a number" (String) from stub, but method `value` expects type Int32 (TypeCastError)

## Class doubles

Not only can instance doubles be stubbed, the class itself can be stubbed as well.
Class methods for a double cannot be defined with [keyword arguments](#keyword-arguments).
Instead, they're defined in the double's definition block body.

```crystal
private double TestDouble do
  stub def self.add_one(value)
    value + 1
  end
end

it "can use the double's class type" do
  TestDouble.add_one(2).should eq(3)
end
```

**NOTE:** The `stub` keyword is required for class methods.
See [#3](https://github.com/icy-arctic-fox/mocks/issues/3).

The behavior of the method can be changed as well.
Stub changes persist only for the duration of the test.

<!-- continue-spec -->
```crystal
it "can change the behavior" do
  TestDouble.can receive(:add_one).and_return(0)
  TestDouble.add_one(2).should eq(0)
end

it "reverts stubs between tests" do
  TestDouble.add_one(2).should eq(3)
end
```

The `class` method behaves as expected on a double.

<!-- continue-spec -->
```crystal
it "can use the double's class" do
  TestDouble.can receive(:add_one).and_return(0)
  double = TestDouble.new
  double.class.add_one(2).should eq(0)
end
```

## Null objects

A *null object* is a variant of a double that responds to all method calls.
Methods that already exist on the double behave the same on the null object.
However, non-existent methods will return the null object.

To create a null object, call `#as_null_object` on an existing double.

```crystal
private double TestDouble

it "creates a null object" do
  double = TestDouble.new.as_null_object
end
```

This has two practical uses:

1. Stubbing method chains
2. Responding to unknown method calls

For method chains, it can reduce the amount of stubs needed for testing.
For instance:

```crystal
private double TestChainDouble, value: 42

it "supports method chains" do
  double = TestChainDouble.new.as_null_object
  double.one.two.three.value.should eq(42)
end
```

These doubles are also useful when an unknown method will be called and the return value is insignificant.
In this example, `Wrapper#do_something` is being tested.
However, it calls methods on another object, which are irrelevant to the test.
The object and methods called on it are irrelevant, the only important thing is the result of `Wrapper#do_something`.

```crystal
private double TestDouble

private class Wrapper(T)
  def initialize(@object : T)
  end

  def do_something
    @object.do_something_else("Test")
    42
  end
end

it "can be used as a stand-in for arbitrary methods" do
  double = TestDouble.new.as_null_object
  wrapper = Wrapper.new(double)
  wrapper.do_something.should eq(42)
end
```

Stubs can be defined on the null object as normal.

```crystal
private double TestChainDouble, value: 42

it "can stub existing methods" do
  double = TestChainDouble.new.as_null_object
  double.can receive(:value).and_return(0)
  double.one.two.three.value.should eq(0)
end
```

The non-existent methods in the chain can also be stubbed.
However, their return type must be the same as the null object.

```crystal
private double TestChainDouble, value: 42

it "can stub existing methods" do
  double = TestChainDouble.new(value: 0).as_null_object
  branch = TestChainDouble.new(value: 5).as_null_object
  double.can receive(:three).and_return(branch)
  double.one.two.three.value.should eq(5)
end
```

## Practical example

Given this class:

```crystal
class Evaluator
  def initialize(@value : String)
  end

  def evaluate(node)
    node.evaluate(@value)
  end
end
```

The `evaluate` method could be tested like so:

<!-- continue-spec -->
```crystal
private double TestNode, evaluate: 0

describe Evaluator do
  describe "#evaluate" do
    it "returns the result of evaluating the node" do
      node = TestNode.new
      evaluator = Evaluator.new("Test")
      evaluator.evaluate(node).should eq(0)
    end
  end
end
```