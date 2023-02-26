require "../../spec_helper"

private def create_test_args(arg1, arg2, arg3, **kwargs)
  Spectator::Mocks::Arguments.new({arg1: arg1, arg2: arg2, arg3: arg3}, nil, nil, kwargs)
end

private def create_test_args(arg1, arg2, arg3, *splat, **kwargs)
  Spectator::Mocks::Arguments.new({arg1: arg1, arg2: arg2, arg3: arg3}, :splat, splat, kwargs)
end

private def create_test_args(**kwargs)
  Spectator::Mocks::Arguments.new(NamedTuple.new, nil, nil, kwargs)
end

private def create_test_args(splat, **kwargs)
  Spectator::Mocks::Arguments.new(NamedTuple.new, :splat, splat, kwargs)
end

describe Spectator::Mocks::ArgumentsPattern do
  it "sets attributes" do
    positional = {1, 2, 3}
    named = {extra: 4, another: 5}
    pattern = Spectator::Mocks::ArgumentsPattern.new(positional, named)
    pattern.positional.should eq(positional)
    pattern.named.should eq(named)
  end

  describe ".build" do
    it "sets attributes" do
      pattern = Spectator::Mocks::ArgumentsPattern.build(1, 2, 3, extra: 4, another: 5)
      pattern.positional.should eq({1, 2, 3})
      pattern.named.should eq({extra: 4, another: 5})
    end
  end

  describe ".none" do
    it "returns a pattern with no arguments" do
      pattern = Spectator::Mocks::ArgumentsPattern.none
      pattern.positional.empty?.should be_true
      pattern.named.empty?.should be_true
    end
  end

  describe ".any" do
    it "returns nil" do
      pattern = Spectator::Mocks::ArgumentsPattern.any
      pattern.should be_nil
    end
  end

  describe "#to_s" do
    it "returns '(no args)' for no arguments" do
      none = Spectator::Mocks::ArgumentsPattern.none
      none.to_s.should eq("(no args)")
    end

    context "with only positional arguments" do
      it "is formatted correctly" do
        pattern = Spectator::Mocks::ArgumentsPattern.build(1, 2, 3)
        pattern.to_s.should eq("(1, 2, 3)")
      end

      it "uses the 'inspect' format" do
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", nil)
        pattern.to_s.should eq(%[("foo", nil)])
      end
    end

    context "with only named arguments" do
      it "is formatted correctly" do
        pattern = Spectator::Mocks::ArgumentsPattern.build(arg1: 1, arg2: 2, arg3: 3)
        pattern.to_s.should eq("(arg1: 1, arg2: 2, arg3: 3)")
      end

      it "uses the 'inspect' format" do
        pattern = Spectator::Mocks::ArgumentsPattern.build(value: "foo", nil: nil)
        pattern.to_s.should eq(%[(value: "foo", nil: nil)])
      end
    end

    context "with positional and named arguments" do
      it "is formatted correctly" do
        pattern = Spectator::Mocks::ArgumentsPattern.build(1, 2, 3, arg4: 4, arg5: 5)
        pattern.to_s.should eq("(1, 2, 3, arg4: 4, arg5: 5)")
      end

      it "uses the 'inspect' format" do
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", :xyz, 42, value: "bar", nil: nil)
        pattern.to_s.should eq(%[("foo", :xyz, 42, value: "bar", nil: nil)])
      end
    end
  end

  describe "#to_args" do
    it "populates Arguments correctly" do
      positional = {"foo", :xyz}
      named = {extra: 42}

      pattern = Spectator::Mocks::ArgumentsPattern.new(positional, named)
      arguments = pattern.to_args

      arguments.positional.should eq(positional)
      arguments.named.should eq(named)
    end

    it "generates matching arguments" do
      positional = {"foo", :xyz}
      named = {extra: 42}

      pattern = Spectator::Mocks::ArgumentsPattern.new(positional, named)
      arguments = pattern.to_args
      (pattern === arguments).should be_true
    end
  end

  describe "#==" do
    it "returns true for equal arguments" do
      positional = {"foo", :xyz}
      named = {extra: "value"}

      pattern1 = Spectator::Mocks::ArgumentsPattern.new(positional, named)
      pattern2 = Spectator::Mocks::ArgumentsPattern.new(positional, named)
      pattern1.should eq(pattern2)
    end

    it "returns false for unequal arguments" do
      pattern1 = Spectator::Mocks::ArgumentsPattern.new({"foo", :xyz}, {extra: "value"})
      pattern2 = Spectator::Mocks::ArgumentsPattern.new({42}, {other: "value"})
      pattern1.should_not eq(pattern2)
    end
  end

  describe "#===" do
    context "with no arguments" do
      it "returns true for a 'none' pattern" do
        arguments = Spectator::Mocks::Arguments.none
        pattern = Spectator::Mocks::ArgumentsPattern.none

        (pattern === arguments).should be_true
      end

      it "returns false for a pattern with positional arguments" do
        arguments = Spectator::Mocks::Arguments.none
        pattern = Spectator::Mocks::ArgumentsPattern.build(1, 2, 3)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with keyword arguments" do
        arguments = Spectator::Mocks::Arguments.none
        pattern = Spectator::Mocks::ArgumentsPattern.build(extra: 42)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with positional and keyword arguments" do
        arguments = Spectator::Mocks::Arguments.none
        pattern = Spectator::Mocks::ArgumentsPattern.build(1, 2, 3, extra: 42)

        (pattern === arguments).should be_false
      end
    end

    context "with only positional arguments" do
      it "returns true for a pattern with exact matching arguments" do
        arguments = create_test_args("foo", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, :xyz)

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with case-equality matching arguments" do
        arguments = create_test_args("foobar", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build(/foo/, (40..45), Symbol)

        (pattern === arguments).should be_true
      end

      it "returns false for a non-matching pattern" do
        arguments = create_test_args("foo", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build("bar", 5, %w[baz])

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer of them" do
        arguments = create_test_args("foo", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo")

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more of them" do
        arguments = create_test_args("foo", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, 0)

        (pattern === arguments).should be_false
      end
    end

    context "with positional and splat arguments" do
      it "returns true for a pattern with exact matching arguments" do
        arguments = create_test_args("foo", 42, :xyz, :bar, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, :xyz, :bar, %w[baz])

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with case-equality matching arguments" do
        arguments = create_test_args("foobar", 42, :xyz, :bar, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build(/foo/, Int32, :xyz, ->(x : Symbol) { x == :bar }, Array)

        (pattern === arguments).should be_true
      end

      it "returns false for a non-matching pattern" do
        arguments = create_test_args("foo", 42, :xyz, Int32)
        pattern = Spectator::Mocks::ArgumentsPattern.build("bar", 5, %w[baz], String)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer positional" do
        arguments = create_test_args("foo", 42, :xyz, :bar, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, :bar, %w[baz])

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer splat" do
        arguments = create_test_args("foo", 42, :xyz, :bar, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, :xyz, :bar)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more positional" do
        arguments = create_test_args("foo", 42, :xyz, :bar, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, :xyz, 'x', :bar, %w[baz])

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more splat" do
        arguments = create_test_args("foo", 42, :xyz, :bar, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, :xyz, :bar, %w[baz], 'x')

        (pattern === arguments).should be_false
      end
    end

    context "with some positional arguments specified by keywords" do
      it "returns true for a pattern with exact matching arguments" do
        arguments = create_test_args("foo", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", arg2: 42, arg3: :xyz)

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with case-equality matching arguments" do
        arguments = create_test_args("foobar", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build(/foo/, arg2: Int32, arg3: ->(x : Symbol) { x === :xyz })

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with rearranged matching arguments" do
        arguments = create_test_args("foo", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", arg3: :xyz, arg2: 42)

        (pattern === arguments).should be_true
      end

      it "returns false for a non-matching pattern" do
        arguments = create_test_args("foo", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build("bar", arg2: 5, arg3: :xyz)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer of them" do
        arguments = create_test_args("foo", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", arg2: 42)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more of them" do
        arguments = create_test_args("foo", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", "bar", arg2: 42, arg3: :xyz)

        (pattern === arguments).should be_false
      end
    end

    context "with some positional arguments specified by keywords and a splat" do
      it "returns true for a pattern with exact matching arguments" do
        arguments = create_test_args("foo", 42, :xyz, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", %w[baz], arg2: 42, arg3: :xyz)

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with case-matching matching arguments" do
        arguments = create_test_args("foobar", 42, :xyz, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build(/foo/, %w[baz], arg2: Int32, arg3: ->(x : Symbol) { x == :xyz })

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with rearranged matching arguments" do
        arguments = create_test_args("foo", 42, :xyz, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", %w[baz], arg3: :xyz, arg2: 42)

        (pattern === arguments).should be_true
      end

      it "returns false for a non-matching pattern" do
        arguments = create_test_args("foo", 42, :xyz, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build("bar", Array(String), arg2: 5, arg3: :xyz)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer positional" do
        arguments = create_test_args("foo", 42, :xyz, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", %w[baz], arg2: 42)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer splat" do
        arguments = create_test_args("foo", 42, :xyz, :bar, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", :bar, arg2: 42, arg3: :xyz)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more positional" do
        arguments = create_test_args("foo", 42, :xyz, :bar, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, :bar, %w[baz], arg3: :xyz, arg4: 'x')

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more splat" do
        arguments = create_test_args("foo", 42, :xyz, :bar, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", :bar, %w[baz], 'x', arg2: 42, arg3: :xyz)

        (pattern === arguments).should be_false
      end
    end

    context "with positional arguments specified only by keywords" do
      it "returns true for a pattern with exact matching arguments" do
        arguments = create_test_args("foo", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build(arg1: "foo", arg2: 42, arg3: :xyz)

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with case-equality matching arguments" do
        arguments = create_test_args("foobar", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build(arg1: /foo/, arg2: Int32, arg3: ->(x : Symbol) { x === :xyz })

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with rearranged matching arguments" do
        arguments = create_test_args("foo", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build(arg1: "foo", arg3: :xyz, arg2: 42)

        (pattern === arguments).should be_true
      end

      it "returns false for a non-matching pattern" do
        arguments = create_test_args("foo", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build(arg1: "bar", arg2: 5, arg3: :xyz)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer of them" do
        arguments = create_test_args("foo", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build(arg1: "foo", arg2: 42)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more of them" do
        arguments = create_test_args("foo", 42, :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build(arg1: "foo", arg2: 42, arg3: :xyz, arg4: %[bar])

        (pattern === arguments).should be_false
      end
    end

    context "with positional arguments specified only by keywords and a splat" do
      it "returns true for a pattern with exact matching arguments" do
        arguments = create_test_args("foo", 42, :xyz, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build(%w[baz], arg1: "foo", arg2: 42, arg3: :xyz)

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with case-matching matching arguments" do
        arguments = create_test_args("foobar", 42, :xyz, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build(%w[baz], arg1: /foo/, arg2: Int32, arg3: ->(x : Symbol) { x == :xyz })

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with rearranged matching arguments" do
        arguments = create_test_args("foo", 42, :xyz, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build(%w[baz], arg1: "foo", arg3: :xyz, arg2: 42)

        (pattern === arguments).should be_true
      end

      it "returns false for a non-matching pattern" do
        arguments = create_test_args("foo", 42, :xyz, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build(Array(String), arg1: "bar", arg2: 5, arg3: :xyz)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer positional" do
        arguments = create_test_args("foo", 42, :xyz, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build(%w[baz], arg1: "foo", arg2: 42)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer splat" do
        arguments = create_test_args("foo", 42, :xyz, :bar, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build(:bar, arg1: "foo", arg2: 42, arg3: :xyz)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more positional" do
        arguments = create_test_args("foo", 42, :xyz, :bar, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build(:bar, %w[baz], arg1: "foo", arg2: 42, arg3: :xyz, arg4: 'x')

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more splat" do
        arguments = create_test_args("foo", 42, :xyz, :bar, %w[baz])
        pattern = Spectator::Mocks::ArgumentsPattern.build(:bar, %w[baz], 'x', arg1: "foo", arg2: 42, arg3: :xyz)

        (pattern === arguments).should be_false
      end
    end

    context "with only keyword arguments" do
      it "returns true for a pattern with exact matching arguments" do
        arguments = create_test_args(a: "foo", b: 42, c: :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build(a: "foo", b: 42, c: :xyz)

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with case-equality matching arguments" do
        arguments = create_test_args(a: "foo", b: 42, c: :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build(a: /foo/, b: Int32, c: ->(x : Symbol) { x === :xyz })

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with rearranged matching arguments" do
        arguments = create_test_args(a: "foo", b: 42, c: :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build(a: "foo", c: :xyz, b: 42)

        (pattern === arguments).should be_true
      end

      it "returns false for a non-matching pattern" do
        arguments = create_test_args(a: "foo", b: 42, c: :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build(a: "bar", b: 5, c: :xyz)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer of them" do
        arguments = create_test_args(a: "foo", b: 42, c: :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build(a: "foo", b: 42)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more of them" do
        arguments = create_test_args(a: "foo", b: 42, c: :xyz)
        pattern = Spectator::Mocks::ArgumentsPattern.build(a: "foo", b: 42, c: :xyz, d: %[bar])

        (pattern === arguments).should be_false
      end
    end

    context "with a splat and keyword arguments" do
      it "returns true for a pattern with exact matching arguments" do
        arguments = create_test_args({:xyz}, a: "foo", b: 42, c: %w[bar])
        pattern = Spectator::Mocks::ArgumentsPattern.build(:xyz, a: "foo", b: 42, c: %w[bar])

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with case-matching matching arguments" do
        arguments = create_test_args({:xyz}, a: "foo", b: 42, c: %w[bar])
        pattern = Spectator::Mocks::ArgumentsPattern.build(Symbol, a: /foo/, b: Int32, c: ->(x : Array(String)) { x.includes?("bar") })

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with rearranged matching arguments" do
        arguments = create_test_args({:xyz}, a: "foo", b: 42, c: %w[bar])
        pattern = Spectator::Mocks::ArgumentsPattern.build(:xyz, a: "foo", c: %w[bar], b: 42)

        (pattern === arguments).should be_true
      end

      it "returns false for a non-matching pattern" do
        arguments = create_test_args({:xyz}, a: "foo", b: 42, c: %w[bar])
        pattern = Spectator::Mocks::ArgumentsPattern.build(:abc, a: "bar", b: 5, c: %w[bar])

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer positional" do
        arguments = create_test_args({:xyz}, a: "foo", b: 42, c: %w[bar])
        pattern = Spectator::Mocks::ArgumentsPattern.build(:xyz, a: "foo", b: 42)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer splat" do
        arguments = create_test_args({:xyz}, a: "foo", b: 42, c: %w[bar])
        pattern = Spectator::Mocks::ArgumentsPattern.build(a: "foo", b: 42, c: %w[bar])

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more positional" do
        arguments = create_test_args({:xyz}, a: "foo", b: 42, c: %w[bar])
        pattern = Spectator::Mocks::ArgumentsPattern.build(:xyz, a: "foo", b: 42, c: %w[bar], d: 'x')

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more splat" do
        arguments = create_test_args({:xyz}, a: "foo", b: 42, c: %w[bar])
        pattern = Spectator::Mocks::ArgumentsPattern.build(:xyz, 'x', a: "foo", b: 42, c: %w[bar])

        (pattern === arguments).should be_false
      end
    end

    context "with all parameter types" do
      it "returns true for a pattern with exact matching arguments" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with case-matching matching arguments" do
        arguments = create_test_args("foobar", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build(/foo/, (40..45), Symbol, ->(x : Array(String)) { x.includes?("bar") }, 'x', a: String, b: nil, c: true)

        (pattern === arguments).should be_true
      end

      it "returns false for a non-matching pattern" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("bar", 5, :abc, %w[bar], 'y', a: "bar", b: nil, c: false)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer positional" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, %w[bar], 'x', a: "baz", b: nil, c: true)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer splat" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, :xyz, %w[bar], a: "baz", b: nil, c: true)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer keyword" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more positional" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, :xyz, {0}, %w[bar], 'x', a: "baz", b: nil, c: true)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more splat" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, :xyz, %w[bar], 'x', {0}, a: "baz", b: nil, c: true)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more keyword" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true, d: {0})

        (pattern === arguments).should be_false
      end
    end

    context "with all parameter types and some positional arguments specified by keywords" do
      it "returns true for a pattern with exact matching arguments" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, %w[bar], 'x', arg3: :xyz, a: "baz", b: nil, c: true)

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with case-matching matching arguments" do
        arguments = create_test_args("foobar", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build(/foo/, (40..45), Symbol, ->(x : Array(String)) { x.includes?("bar") }, 'x', a: String, b: nil, c: true)

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with rearranged matching arguments" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", %w[bar], 'x', arg3: :xyz, arg2: 42, a: "baz", b: nil, c: true)

        (pattern === arguments).should be_true
      end

      it "returns false for a non-matching pattern" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("bar", 0, %w[baz], 'y', arg3: :abc, a: "bar", b: nil, c: false)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer positional" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", %w[bar], 'x', arg3: :xyz, a: "baz", b: nil, c: true)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer splat" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, %w[bar], arg3: :xyz, a: "baz", b: nil, c: true)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer keyword" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, %w[bar], 'x', arg3: :xyz, a: "baz", b: nil)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more positional" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, :xyz, %w[bar], 'x', arg3: :xyz, a: "baz", b: nil, c: true)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more splat" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, %w[bar], 'x', {0}, arg3: :xyz, a: "baz", b: nil, c: true)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more keyword" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build("foo", 42, %w[bar], 'x', arg3: :xyz, a: "baz", b: nil, c: true, d: {0})

        (pattern === arguments).should be_false
      end
    end

    context "with all parameter types and positional arguments specified only by keywords" do
      it "returns true for a pattern with exact matching arguments" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build(%w[bar], 'x', arg1: "foo", arg2: 42, arg3: :xyz, a: "baz", b: nil, c: true)

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with case-matching matching arguments" do
        arguments = create_test_args("foobar", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build(->(x : Array(String)) { x.includes?("bar") }, 'x', arg1: /foo/, arg2: (40..45), arg3: Symbol, a: String, b: nil, c: true)

        (pattern === arguments).should be_true
      end

      it "returns true for a pattern with rearranged matching arguments" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build(%w[bar], 'x', arg1: "foo", arg3: :xyz, arg2: 42, a: "baz", b: nil, c: true)

        (pattern === arguments).should be_true
      end

      it "returns false for a non-matching pattern" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build(%w[bar], 'y', arg1: "bar", arg2: 5, arg3: :abc, a: "bar", b: nil, c: false)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer positional" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build(%w[bar], 'x', arg1: "foo", arg2: 42, a: "baz", b: nil, c: true)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer splat" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build(%w[bar], arg1: "foo", arg2: 42, arg3: :xyz, a: "baz", b: nil, c: true)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but fewer keyword" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build(%w[bar], 'x', arg1: "foo", arg2: 42, arg3: :xyz, a: "baz", b: nil)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more positional" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build(%w[bar], 'x', arg1: "foo", arg2: 42, arg3: :xyz, arg4: {0}, a: "baz", b: nil, c: true)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more splat" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build(%w[bar], 'x', {0}, arg1: "foo", arg2: 42, arg3: :xyz, a: "baz", b: nil, c: true)

        (pattern === arguments).should be_false
      end

      it "returns false for a pattern with matching arguments, but more keyword" do
        arguments = create_test_args("foo", 42, :xyz, %w[bar], 'x', a: "baz", b: nil, c: true)
        pattern = Spectator::Mocks::ArgumentsPattern.build(%w[bar], 'x', arg1: "foo", arg2: 42, arg3: :xyz, a: "baz", b: nil, c: true, d: {0})

        (pattern === arguments).should be_false
      end
    end

    it "returns false for an incompatible Range" do
      arguments = create_test_args("foo", 42, :xyz)
      pattern = Spectator::Mocks::ArgumentsPattern.build((0..10), 42, :xyz)

      (pattern === arguments).should be_false
    end

    it "returns true when comparing identical Ranges" do
      arguments = create_test_args((0..10), 42, :xyz)
      pattern = Spectator::Mocks::ArgumentsPattern.build((0..10), 42, :xyz)

      (pattern === arguments).should be_true
    end

    it "returns false for an incompatible Proc" do
      arguments = create_test_args("foo", 42, :xyz)
      pattern = Spectator::Mocks::ArgumentsPattern.build(->(x : Int32) { x.even? }, 42, :xyz)

      (pattern === arguments).should be_false
    end

    it "returns true when comparing identical Procs" do
      proc = ->(x : Int32) { x.even? }
      arguments = create_test_args(proc, 42, :xyz)
      pattern = Spectator::Mocks::ArgumentsPattern.build(proc, 42, :xyz)

      (pattern === arguments).should be_true
    end

    it "returns false for an incompatible Proc (argument count)" do
      arguments = create_test_args("foo", 42, :xyz)
      pattern = Spectator::Mocks::ArgumentsPattern.build(->(x : Int32, y : Int32) { (x + y).even? }, 42, :xyz)

      (pattern === arguments).should be_false
    end

    it "returns true when comparing identical Procs (argument count)" do
      proc = ->(x : Int32, y : Int32) { (x + y).even? }
      arguments = create_test_args(proc, 42, :xyz)
      pattern = Spectator::Mocks::ArgumentsPattern.build(proc, 42, :xyz)

      (pattern === arguments).should be_true
    end

    it "returns false for an incompatible Regex" do
      arguments = create_test_args("foo", 42, :xyz)
      pattern = Spectator::Mocks::ArgumentsPattern.build("foo", /bar/, :xyz)

      (pattern === arguments).should be_false
    end

    it "returns true when comparing identical Regexes" do
      regex = /bar/
      arguments = create_test_args(regex, 42, :xyz)
      pattern = Spectator::Mocks::ArgumentsPattern.build(regex, 42, :xyz)

      (pattern === arguments).should be_true
    end
  end
end
