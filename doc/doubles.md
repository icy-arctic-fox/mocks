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
So far, the body has been omitted, but the `double` keyword accepts a block.
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

The two styles can be mixed.
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

## Modifying double behavior

See [stubs](stubs.md).

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