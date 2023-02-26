require "../../spec_helper"

private def create_registry
  Spectator::Mocks::Registry.new
end

private def create_example_stub(args = nil)
  Spectator::Mocks::NilStub.new(:example, args)
end

private def create_example_call(args = Spectator::Mocks::Arguments.none)
  Spectator::Mocks::Call.new(:example, args)
end

private def sample_args
  Spectator::Mocks::Arguments.new({arg: 42}, nil, nil, NamedTuple.new)
end

record ExampleRecord1, value : Int32

record ExampleRecord2, value : Int32

describe Spectator::Mocks::Registry do
  context "with reference types" do
    it "stores a stub for an object" do
      registry = create_registry
      object = %w[foo bar]

      stub = create_example_stub
      call = create_example_call

      registry.add_stub(object, stub)
      registry.find_stub(object, call).should be(stub)
    end

    describe "#find_stub" do
      it "returns nil when there are no stubs" do
        registry = create_registry
        object = %w[foo bar]
        call = create_example_call

        registry.find_stub(object, call).should be_nil
      end

      it "returns when no stubs match" do
        registry = create_registry
        object = %w[foo bar]

        stub = Spectator::Mocks::NilStub.new(:foo)
        call = Spectator::Mocks::Call.new(:bar)

        registry.add_stub(object, stub)
        registry.find_stub(object, call).should be_nil
      end

      it "returns a stub matching the method name" do
        registry = create_registry
        object = %w[foo bar]

        stub1 = Spectator::Mocks::NilStub.new(:foo)
        stub2 = Spectator::Mocks::NilStub.new(:bar)
        call = Spectator::Mocks::Call.new(:foo)

        registry.add_stub(object, stub1)
        registry.add_stub(object, stub2)
        registry.find_stub(object, call).should be(stub1)
      end

      it "returns a stub matching arguments" do
        registry = create_registry
        object = %w[foo bar]

        stub1 = Spectator::Mocks::NilStub.new(:foo, Spectator::Mocks::ArgumentsPattern.build(40..45))
        stub2 = Spectator::Mocks::NilStub.new(:foo, Spectator::Mocks::ArgumentsPattern.build(String))
        call = Spectator::Mocks::Call.new(:foo, sample_args)

        registry.add_stub(object, stub1)
        registry.add_stub(object, stub2)
        registry.find_stub(object, call).should be(stub1)
      end

      it "doesn't match stubs for other objects" do
        registry = create_registry
        object1 = %w[foo bar]
        object2 = "foobar"

        stub1 = create_example_stub
        stub2 = create_example_stub
        call = create_example_call

        registry.add_stub(object1, stub1)
        registry.add_stub(object2, stub2)
        registry.find_stub(object1, call).should be(stub1)
      end

      it "returns a newer stub when multiple match" do
        registry = create_registry
        object = %w[foo bar]

        stub1 = create_example_stub
        stub2 = create_example_stub
        call = create_example_call

        registry.add_stub(object, stub1)
        registry.add_stub(object, stub2)
        registry.find_stub(object, call).should be(stub2)
      end
    end

    describe "#clear_stubs" do
      it "removes a previously added stub" do
        registry = create_registry
        object = %w[foo bar]

        stub = create_example_stub
        call = create_example_call

        registry.add_stub(object, stub)
        registry.clear_stubs(object)
        registry.find_stub(object, call).should be_nil
      end

      it "doesn't modify other object stubs" do
        registry = create_registry
        object1 = %w[foo bar]
        object2 = "foobar"

        stub1 = create_example_stub
        stub2 = create_example_stub
        call = create_example_call

        registry.add_stub(object1, stub1)
        registry.add_stub(object2, stub2)
        registry.clear_stubs(object1)
        registry.find_stub(object2, call).should be(stub2)
      end
    end

    it "stores a call for an object" do
      registry = create_registry
      object = %w[foo bar]
      call = create_example_call

      registry.add_call(object, call)
      registry.calls(object).should contain(call)
    end

    describe "#calls" do
      it "returns an empty list for an unknown object" do
        registry = create_registry
        object = %w[foo bar]

        registry.calls(object).empty?.should be_true
      end

      it "returns calls only for an object" do
        registry = create_registry
        object1 = %w[foo bar]
        object2 = "foobar"

        call1 = create_example_call
        call2 = create_example_call

        registry.add_call(object1, call1)
        registry.add_call(object2, call2)
        registry.calls(object1).should_not contain(call2)
      end
    end

    describe "#clear_calls" do
      it "removes a previously added call" do
        registry = create_registry
        object = %w[foo bar]
        call = create_example_call

        registry.add_call(object, call)
        registry.clear_calls(object)
        registry.calls(object).empty?.should be_true
      end

      it "doesn't modify other object calls" do
        registry = create_registry
        object1 = %w[foo bar]
        object2 = "foobar"

        call1 = create_example_call
        call2 = create_example_call

        registry.add_call(object1, call1)
        registry.add_call(object2, call2)
        registry.clear_calls(object1)
        registry.calls(object2).should contain(call2)
      end
    end

    describe "#clear" do
      it "removes a previously added stub" do
        registry = create_registry
        object = %w[foo bar]

        stub = create_example_stub
        call = create_example_call

        registry.add_stub(object, stub)
        registry.clear
        registry.find_stub(object, call).should be_nil
      end

      it "removes a previously added call" do
        registry = create_registry
        object = %w[foo bar]
        call = create_example_call

        registry.add_call(object, call)
        registry.clear
        registry.calls(object).empty?.should be_true
      end

      context "with an object" do
        it "removes a previously added stub" do
          registry = create_registry
          object = %w[foo bar]

          stub = create_example_stub
          call = create_example_call

          registry.add_stub(object, stub)
          registry.clear(object)
          registry.find_stub(object, call).should be_nil
        end

        it "removes a previously added call" do
          registry = create_registry
          object = %w[foo bar]
          call = create_example_call

          registry.add_call(object, call)
          registry.clear(object)
          registry.calls(object).empty?.should be_true
        end

        it "doesn't modify other object stubs" do
          registry = create_registry
          object1 = %w[foo bar]
          object2 = "foobar"

          stub1 = create_example_stub
          stub2 = create_example_stub
          call = create_example_call

          registry.add_stub(object1, stub1)
          registry.add_stub(object2, stub2)
          registry.clear(object1)
          registry.find_stub(object2, call).should be(stub2)
        end

        it "doesn't modify other object calls" do
          registry = create_registry
          object1 = %w[foo bar]
          object2 = "foobar"

          call1 = create_example_call
          call2 = create_example_call

          registry.add_call(object1, call1)
          registry.add_call(object2, call2)
          registry.clear(object1)
          registry.calls(object2).should contain(call2)
        end
      end
    end
  end

  context "with value types" do
    it "stores a stub for an object" do
      registry = create_registry
      object = 42

      stub = create_example_stub
      call = create_example_call

      registry.add_stub(object, stub)
      registry.find_stub(object, call).should be(stub)
    end

    describe "#find_stub" do
      it "returns nil when there are no stubs" do
        registry = create_registry
        object = 42
        call = create_example_call

        registry.find_stub(object, call).should be_nil
      end

      it "returns when no stubs match" do
        registry = create_registry
        object = 42

        stub = Spectator::Mocks::NilStub.new(:foo)
        call = Spectator::Mocks::Call.new(:bar)

        registry.add_stub(object, stub)
        registry.find_stub(object, call).should be_nil
      end

      it "returns a stub matching the method name" do
        registry = create_registry
        object = 42

        stub1 = Spectator::Mocks::NilStub.new(:foo)
        stub2 = Spectator::Mocks::NilStub.new(:bar)
        call = Spectator::Mocks::Call.new(:foo)

        registry.add_stub(object, stub1)
        registry.add_stub(object, stub2)
        registry.find_stub(object, call).should be(stub1)
      end

      it "returns a stub matching arguments" do
        registry = create_registry
        object = 42

        stub1 = Spectator::Mocks::NilStub.new(:foo, Spectator::Mocks::ArgumentsPattern.build(40..45))
        stub2 = Spectator::Mocks::NilStub.new(:foo, Spectator::Mocks::ArgumentsPattern.build(String))
        call = Spectator::Mocks::Call.new(:foo, sample_args)

        registry.add_stub(object, stub1)
        registry.add_stub(object, stub2)
        registry.find_stub(object, call).should be(stub1)
      end

      it "doesn't confuse two objects with differing types and the same bytes" do
        registry = create_registry
        object1 = ExampleRecord1.new(42)
        object2 = ExampleRecord2.new(42)

        stub1 = create_example_stub
        stub2 = create_example_stub
        call = create_example_call

        registry.add_stub(object1, stub1)
        registry.add_stub(object2, stub2)
        registry.find_stub(object1, call).should be(stub1)
      end

      it "returns a newer stub when multiple match" do
        registry = create_registry
        object = ExampleRecord1.new(42)

        stub1 = create_example_stub
        stub2 = create_example_stub
        call = create_example_call

        registry.add_stub(object, stub1)
        registry.add_stub(object, stub2)
        registry.find_stub(object, call).should be(stub2)
      end
    end

    describe "#clear_stubs" do
      it "removes a previously added stub" do
        registry = create_registry
        object = 42

        stub = create_example_stub
        call = create_example_call

        registry.add_stub(object, stub)
        registry.clear_stubs(object)
        registry.find_stub(object, call).should be_nil
      end

      it "doesn't modify other object stubs" do
        registry = create_registry
        object1 = 42
        object2 = :xyz

        stub1 = create_example_stub
        stub2 = create_example_stub
        call = create_example_call

        registry.add_stub(object1, stub1)
        registry.add_stub(object2, stub2)
        registry.clear_stubs(object1)
        registry.find_stub(object2, call).should be(stub2)
      end

      it "doesn't confuse two objects with differing types and the same bytes" do
        registry = create_registry
        object1 = ExampleRecord1.new(42)
        object2 = ExampleRecord2.new(42)

        stub1 = create_example_stub
        stub2 = create_example_stub
        call = create_example_call

        registry.add_stub(object1, stub1)
        registry.add_stub(object2, stub2)
        registry.clear_stubs(object1)
        registry.find_stub(object1, call).should be_nil
        registry.find_stub(object2, call).should be(stub2)
      end
    end

    it "stores a call for an object" do
      registry = create_registry
      object = 42
      call = create_example_call

      registry.add_call(object, call)
      registry.calls(object).should contain(call)
    end

    describe "#calls" do
      it "returns an empty list for an unknown object" do
        registry = create_registry
        object = 42

        registry.calls(object).empty?.should be_true
      end

      it "returns calls only for an object" do
        registry = create_registry
        object1 = 42
        object2 = :xyz

        call1 = create_example_call
        call2 = create_example_call

        registry.add_call(object1, call1)
        registry.add_call(object2, call2)
        registry.calls(object1).should_not contain(call2)
      end

      it "doesn't confuse two objects with differing types and the same bytes" do
        registry = create_registry
        object1 = ExampleRecord1.new(42)
        object2 = ExampleRecord2.new(42)

        call1 = create_example_call
        call2 = create_example_call

        registry.add_call(object1, call1)
        registry.add_call(object2, call2)
        registry.calls(object1).should contain(call1)
        registry.calls(object1).should_not contain(call2)
      end
    end

    describe "#clear_calls" do
      it "removes a previously added call" do
        registry = create_registry
        object = 42
        call = create_example_call

        registry.add_call(object, call)
        registry.clear_calls(object)
        registry.calls(object).empty?.should be_true
      end

      it "doesn't modify other object calls" do
        registry = create_registry
        object1 = 42
        object2 = :xyz

        call1 = create_example_call
        call2 = create_example_call

        registry.add_call(object1, call1)
        registry.add_call(object2, call2)
        registry.clear_calls(object1)
        registry.calls(object2).should contain(call2)
      end

      it "doesn't confuse two objects with differing types and the same bytes" do
        registry = create_registry
        object1 = ExampleRecord1.new(42)
        object2 = ExampleRecord2.new(42)

        call1 = create_example_call
        call2 = create_example_call

        registry.add_call(object1, call1)
        registry.add_call(object2, call2)
        registry.clear_calls(object1)
        registry.calls(object1).empty?.should be_true
        registry.calls(object2).should contain(call2)
      end
    end

    describe "#clear" do
      it "removes a previously added stub" do
        registry = create_registry
        object = 42

        stub = create_example_stub
        call = create_example_call

        registry.add_stub(object, stub)
        registry.clear
        registry.find_stub(object, call).should be_nil
      end

      it "removes a previously added call" do
        registry = create_registry
        object = 42
        call = create_example_call

        registry.add_call(object, call)
        registry.clear
        registry.calls(object).empty?.should be_true
      end

      context "with an object" do
        it "removes a previously added stub" do
          registry = create_registry
          object = 42

          stub = create_example_stub
          call = create_example_call

          registry.add_stub(object, stub)
          registry.clear(object)
          registry.find_stub(object, call).should be_nil
        end

        it "removes a previously added call" do
          registry = create_registry
          object = 42
          call = create_example_call

          registry.add_call(object, call)
          registry.clear(object)
          registry.calls(object).empty?.should be_true
        end

        it "doesn't modify other object stubs" do
          registry = create_registry
          object1 = 42
          object2 = :xyz

          stub1 = create_example_stub
          stub2 = create_example_stub
          call = create_example_call

          registry.add_stub(object1, stub1)
          registry.add_stub(object2, stub2)
          registry.clear(object1)
          registry.find_stub(object2, call).should be(stub2)
        end

        it "doesn't modify other object calls" do
          registry = create_registry
          object1 = 42
          object2 = :xyz

          call1 = create_example_call
          call2 = create_example_call

          registry.add_call(object1, call1)
          registry.add_call(object2, call2)
          registry.clear(object1)
          registry.calls(object2).should contain(call2)
        end

        it "doesn't confuse two objects with differing types and the same bytes" do
          registry = create_registry
          object1 = ExampleRecord1.new(42)
          object2 = ExampleRecord2.new(42)

          stub1 = create_example_stub
          stub2 = create_example_stub
          call1 = create_example_call
          call2 = create_example_call

          registry.add_stub(object1, stub1)
          registry.add_stub(object2, stub2)
          registry.add_call(object1, call1)
          registry.add_call(object2, call2)

          registry.clear(object1)
          registry.find_stub(object1, call1).should be_nil
          registry.find_stub(object2, call2).should be(stub2)
          registry.calls(object1).empty?.should be_true
          registry.calls(object2).should contain(call2)
        end
      end
    end
  end
end
