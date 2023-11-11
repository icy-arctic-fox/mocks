# Mocks

TODO: Write a description here

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     mocks:
       github: icy-arctic-fox/mocks
   ```

2. Run `shards install`

## Usage

```crystal
require "mocks"
```

TODO: Write usage instructions here

### Known Limitations

#### Type restrictions on mocked types must use the absolute name

The following code does not work:

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
