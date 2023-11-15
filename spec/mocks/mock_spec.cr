require "../spec_helper"

# The following dimensions are used to test the different types of mocks.
# Base type:
# - Abstract Class
# - Concrete Class
# - Abstract Struct
# - Mixin Module (include)
# Method type:
# - Instance methods
# - Class methods
# - Abstract methods
# Return value:
# - Typed
# - Untyped
# Default stub:
# - Keyword arguments of #define
#   - Should be able to override with #__mocks ("can" syntax)
# - Block of #define
#   - Should be able to override with #__mocks ("can" syntax)
# - None - outside of #define with #__mocks
# Method that yields:
# - Does not yield
# - Typed yield
# - Untyped yield
# Generics: # TODO
# - None
# - Generic type parameter
# - Free variable

macro def_abstract_instance_methods(*, return_type = String, yield_arg_type = String, yield_return_type = String)
  abstract def abstract__typed_return__no_yield__no_args__no_default : {{return_type.id}}
  abstract def abstract__untyped_return__no_yield__no_args__no_default
  abstract def abstract__typed_return__typed_yield__no_args__no_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
  abstract def abstract__untyped_return__typed_yield__no_args__no_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}})
  abstract def abstract__typed_return__untyped_yield__no_args__no_default(& : {{yield_arg_type.id}} -> _) : {{return_type.id}}
  abstract def abstract__untyped_return__untyped_yield__no_args__no_default(& : {{yield_arg_type.id}} -> _)

  abstract def abstract__typed_return__no_yield__no_args__kwargs_default : {{return_type.id}}
  abstract def abstract__untyped_return__no_yield__no_args__kwargs_default
  abstract def abstract__typed_return__typed_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
  abstract def abstract__untyped_return__typed_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}})
  abstract def abstract__typed_return__untyped_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> _) : {{return_type.id}}
  abstract def abstract__untyped_return__untyped_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> _)

  abstract def abstract__typed_return__no_yield__no_args__block_default : {{return_type.id}}
  abstract def abstract__untyped_return__no_yield__no_args__block_default
  abstract def abstract__typed_return__typed_yield__no_args__block_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
  abstract def abstract__untyped_return__typed_yield__no_args__block_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}})
  abstract def abstract__typed_return__untyped_yield__no_args__block_default(& : {{yield_arg_type.id}} -> _) : {{return_type.id}}
  abstract def abstract__untyped_return__untyped_yield__no_args__block_default(& : {{yield_arg_type.id}} -> _)

  abstract def abstract__typed_return__no_yield__positional_args__no_default(arg1, arg2, arg3) : {{return_type.id}}
  abstract def abstract__untyped_return__no_yield__positional_args__no_default(arg1, arg2, arg3)
  abstract def abstract__typed_return__typed_yield__positional_args__no_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
  abstract def abstract__untyped_return__typed_yield__positional_args__no_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}})
  abstract def abstract__typed_return__untyped_yield__positional_args__no_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _) : {{return_type.id}}
  abstract def abstract__untyped_return__untyped_yield__positional_args__no_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _)

  abstract def abstract__typed_return__no_yield__positional_args__kwargs_default(arg1, arg2, arg3) : {{return_type.id}}
  abstract def abstract__untyped_return__no_yield__positional_args__kwargs_default(arg1, arg2, arg3)
  abstract def abstract__typed_return__typed_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
  abstract def abstract__untyped_return__typed_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}})
  abstract def abstract__typed_return__untyped_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _) : {{return_type.id}}
  abstract def abstract__untyped_return__untyped_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _)

  abstract def abstract__typed_return__no_yield__positional_args__block_default(arg1, arg2, arg3) : {{return_type.id}}
  abstract def abstract__untyped_return__no_yield__positional_args__block_default(arg1, arg2, arg3)
  abstract def abstract__typed_return__typed_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
  abstract def abstract__untyped_return__typed_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}})
  abstract def abstract__typed_return__untyped_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _) : {{return_type.id}}
  abstract def abstract__untyped_return__untyped_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _)
end

macro def_concrete_instance_methods(*, return_value = "original", is_mock_type = false, return_type = String, yield_arg_type = String, yield_return_type = String)
  {% unless is_mock_type %}
    def concrete__typed_return__no_yield__no_args__no_default : {{return_type.id}}
      {{return_value}}
    end
    def concrete__untyped_return__no_yield__no_args__no_default
      {{return_value}}
    end
    def concrete__typed_return__typed_yield__no_args__no_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
      yield {{return_value}}
    end
    def concrete__untyped_return__typed_yield__no_args__no_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}})
      yield {{return_value}}
    end
    def concrete__typed_return__untyped_yield__no_args__no_default(& : {{yield_arg_type.id}} -> _) : {{return_type.id}}
      yield {{return_value}}
    end
    def concrete__untyped_return__untyped_yield__no_args__no_default(& : {{yield_arg_type.id}} -> _)
      yield {{return_value}}
    end

    def concrete__typed_return__no_yield__positional_args__no_default(arg1, arg2, arg3) : {{return_type.id}}
      {{return_value}}
    end
    def concrete__untyped_return__no_yield__positional_args__no_default(arg1, arg2, arg3)
      {{return_value}}
    end
    def concrete__typed_return__typed_yield__positional_args__no_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
      yield {{return_value}}
    end
    def concrete__untyped_return__typed_yield__positional_args__no_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}})
      yield {{return_value}}
    end
    def concrete__typed_return__untyped_yield__positional_args__no_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _) : {{return_type.id}}
      yield {{return_value}}
    end
    def concrete__untyped_return__untyped_yield__positional_args__no_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _)
      yield {{return_value}}
    end
  {% end %}

  def concrete__typed_return__no_yield__no_args__kwargs_default : {{return_type.id}}
    {{return_value}}
  end
  def concrete__untyped_return__no_yield__no_args__kwargs_default
    {{return_value}}
  end
  def concrete__typed_return__typed_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
    yield {{return_value}}
  end
  def concrete__untyped_return__typed_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}})
    yield {{return_value}}
  end
  def concrete__typed_return__untyped_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> _) : {{return_type.id}}
    yield {{return_value}}
  end
  def concrete__untyped_return__untyped_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> _)
    yield {{return_value}}
  end

  def concrete__typed_return__no_yield__no_args__block_default : {{return_type.id}}
    {{return_value}}
  end
  def concrete__untyped_return__no_yield__no_args__block_default
    {{return_value}}
  end
  def concrete__typed_return__typed_yield__no_args__block_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
    yield {{return_value}}
  end
  def concrete__untyped_return__typed_yield__no_args__block_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}})
    yield {{return_value}}
  end
  def concrete__typed_return__untyped_yield__no_args__block_default(& : {{yield_arg_type.id}} -> _) : {{return_type.id}}
    yield {{return_value}}
  end
  def concrete__untyped_return__untyped_yield__no_args__block_default(& : {{yield_arg_type.id}} -> _)
    yield {{return_value}}
  end

  def concrete__typed_return__no_yield__positional_args__kwargs_default(arg1, arg2, arg3) : {{return_type.id}}
    {{return_value}}
  end
  def concrete__untyped_return__no_yield__positional_args__kwargs_default(arg1, arg2, arg3)
    {{return_value}}
  end
  def concrete__typed_return__typed_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
    yield {{return_value}}
  end
  def concrete__untyped_return__typed_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}})
    yield {{return_value}}
  end
  def concrete__typed_return__untyped_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _) : {{return_type.id}}
    yield {{return_value}}
  end
  def concrete__untyped_return__untyped_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _)
    yield {{return_value}}
  end

  def concrete__typed_return__no_yield__positional_args__block_default(arg1, arg2, arg3) : {{return_type.id}}
    {{return_value}}
  end
  def concrete__untyped_return__no_yield__positional_args__block_default(arg1, arg2, arg3)
    {{return_value}}
  end
  def concrete__typed_return__typed_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
    yield {{return_value}}
  end
  def concrete__untyped_return__typed_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}})
    yield {{return_value}}
  end
  def concrete__typed_return__untyped_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _) : {{return_type.id}}
    yield {{return_value}}
  end
  def concrete__untyped_return__untyped_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _)
    yield {{return_value}}
  end
end

macro def_class_methods(*, return_value = "original", is_mock_type = false, return_type = String, yield_arg_type = String, yield_return_type = String)
  # NOTE: The `stub` keyword (macro) is necessary here.
  # `Stubbable::Automatic` cannot redefine class methods as they're added.
  {% if is_mock_type %}
    stub def self.class__typed_return__no_yield__no_args__kwargs_default : {{return_type.id}}
      {{return_value}}
    end
    stub def self.class__untyped_return__no_yield__no_args__kwargs_default
      {{return_value}}
    end
    stub def self.class__typed_return__typed_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
      yield {{return_value}}
    end
    stub def self.class__untyped_return__typed_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}})
      yield {{return_value}}
    end
    stub def self.class__typed_return__untyped_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> _) : {{return_type.id}}
      yield {{return_value}}
    end
    stub def self.class__untyped_return__untyped_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> _)
      yield {{return_value}}
    end

    stub def self.class__typed_return__no_yield__no_args__block_default : {{return_type.id}}
      {{return_value}}
    end
    stub def self.class__untyped_return__no_yield__no_args__block_default
      {{return_value}}
    end
    stub def self.class__typed_return__typed_yield__no_args__block_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
      yield {{return_value}}
    end
    stub def self.class__untyped_return__typed_yield__no_args__block_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}})
      yield {{return_value}}
    end
    stub def self.class__typed_return__untyped_yield__no_args__block_default(& : {{yield_arg_type.id}} -> _) : {{return_type.id}}
      yield {{return_value}}
    end
    stub def self.class__untyped_return__untyped_yield__no_args__block_default(& : {{yield_arg_type.id}} -> _)
      yield {{return_value}}
    end

    # Arguments and return types omitted here due to syntax error.
    stub self.class__typed_return__no_yield__no_args__no_default
    stub self.class__untyped_return__no_yield__no_args__no_default
    stub self.class__typed_return__typed_yield__no_args__no_default
    stub self.class__untyped_return__typed_yield__no_args__no_default
    stub self.class__typed_return__untyped_yield__no_args__no_default
    stub self.class__untyped_return__untyped_yield__no_args__no_default

    stub def self.class__typed_return__no_yield__positional_args__kwargs_default(arg1, arg2, arg3) : {{return_type.id}}
      {{return_value}}
    end
    stub def self.class__untyped_return__no_yield__positional_args__kwargs_default(arg1, arg2, arg3)
      {{return_value}}
    end
    stub def self.class__typed_return__typed_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
      yield {{return_value}}
    end
    stub def self.class__untyped_return__typed_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}})
      yield {{return_value}}
    end
    stub def self.class__typed_return__untyped_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _) : {{return_type.id}}
      yield {{return_value}}
    end
    stub def self.class__untyped_return__untyped_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _)
      yield {{return_value}}
    end

    stub def self.class__typed_return__no_yield__positional_args__block_default(arg1, arg2, arg3) : {{return_type.id}}
      {{return_value}}
    end
    stub def self.class__untyped_return__no_yield__positional_args__block_default(arg1, arg2, arg3)
      {{return_value}}
    end
    stub def self.class__typed_return__typed_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
      yield {{return_value}}
    end
    stub def self.class__untyped_return__typed_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}})
      yield {{return_value}}
    end
    stub def self.class__typed_return__untyped_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _) : {{return_type.id}}
      yield {{return_value}}
    end
    stub def self.class__untyped_return__untyped_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _)
      yield {{return_value}}
    end

    # Arguments and return types omitted here due to syntax error.
    stub self.class__typed_return__no_yield__positional_args__no_default
    stub self.class__untyped_return__no_yield__positional_args__no_default
    stub self.class__typed_return__typed_yield__positional_args__no_default
    stub self.class__untyped_return__typed_yield__positional_args__no_default
    stub self.class__typed_return__untyped_yield__positional_args__no_default
    stub self.class__untyped_return__untyped_yield__positional_args__no_default
  {% else %}
    def self.class__typed_return__no_yield__no_args__no_default : {{return_type.id}}
      {{return_value}}
    end
    def self.class__untyped_return__no_yield__no_args__no_default
      {{return_value}}
    end
    def self.class__typed_return__typed_yield__no_args__no_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
      yield {{return_value}}
    end
    def self.class__untyped_return__typed_yield__no_args__no_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}})
      yield {{return_value}}
    end
    def self.class__typed_return__untyped_yield__no_args__no_default(& : {{yield_arg_type.id}} -> _) : {{return_type.id}}
      yield {{return_value}}
    end
    def self.class__untyped_return__untyped_yield__no_args__no_default(& : {{yield_arg_type.id}} -> _)
      yield {{return_value}}
    end

    def self.class__typed_return__no_yield__no_args__block_default : {{return_type.id}}
      {{return_value}}
    end
    def self.class__untyped_return__no_yield__no_args__block_default
      {{return_value}}
    end
    def self.class__typed_return__typed_yield__no_args__block_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
      yield {{return_value}}
    end
    def self.class__untyped_return__typed_yield__no_args__block_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}})
      yield {{return_value}}
    end
    def self.class__typed_return__untyped_yield__no_args__block_default(& : {{yield_arg_type.id}} -> _) : {{return_type.id}}
      yield {{return_value}}
    end
    def self.class__untyped_return__untyped_yield__no_args__block_default(& : {{yield_arg_type.id}} -> _)
      yield {{return_value}}
    end

    def self.class__typed_return__no_yield__positional_args__no_default(arg1, arg2, arg3) : {{return_type.id}}
      {{return_value}}
    end
    def self.class__untyped_return__no_yield__positional_args__no_default(arg1, arg2, arg3)
      {{return_value}}
    end
    def self.class__typed_return__typed_yield__positional_args__no_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
      yield {{return_value}}
    end
    def self.class__untyped_return__typed_yield__positional_args__no_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}})
      yield {{return_value}}
    end
    def self.class__typed_return__untyped_yield__positional_args__no_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _) : {{return_type.id}}
      yield {{return_value}}
    end
    def self.class__untyped_return__untyped_yield__positional_args__no_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _)
      yield {{return_value}}
    end

    def self.class__typed_return__no_yield__positional_args__block_default(arg1, arg2, arg3) : {{return_type.id}}
      {{return_value}}
    end
    def self.class__untyped_return__no_yield__positional_args__block_default(arg1, arg2, arg3)
      {{return_value}}
    end
    def self.class__typed_return__typed_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
      yield {{return_value}}
    end
    def self.class__untyped_return__typed_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}})
      yield {{return_value}}
    end
    def self.class__typed_return__untyped_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _) : {{return_type.id}}
      yield {{return_value}}
    end
    def self.class__untyped_return__untyped_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _)
      yield {{return_value}}
    end
  {% end %}
end

macro define_mock(definition, kwargs_groups, block_groups, *, return_value = "mocked", return_type = String, yield_arg_type = String, yield_return_type = String)
  {% begin %}
    ::Mocks::Mock.define({{definition}},
      {% for group in kwargs_groups %}
        {% if group.id == :abstract.id %}
          abstract__typed_return__no_yield__no_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          abstract__untyped_return__no_yield__no_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          abstract__typed_return__typed_yield__no_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          abstract__untyped_return__typed_yield__no_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          abstract__typed_return__untyped_yield__no_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          abstract__untyped_return__untyped_yield__no_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),

          abstract__typed_return__no_yield__no_args__block_default: ({{return_value}}).as({{return_type.id}}),
          abstract__untyped_return__no_yield__no_args__block_default: ({{return_value}}).as({{return_type.id}}),
          abstract__typed_return__typed_yield__no_args__block_default: ({{return_value}}).as({{return_type.id}}),
          abstract__untyped_return__typed_yield__no_args__block_default: ({{return_value}}).as({{return_type.id}}),
          abstract__typed_return__untyped_yield__no_args__block_default: ({{return_value}}).as({{return_type.id}}),
          abstract__untyped_return__untyped_yield__no_args__block_default: ({{return_value}}).as({{return_type.id}}),

          abstract__typed_return__no_yield__positional_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          abstract__untyped_return__no_yield__positional_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          abstract__typed_return__typed_yield__positional_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          abstract__untyped_return__typed_yield__positional_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          abstract__typed_return__untyped_yield__positional_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          abstract__untyped_return__untyped_yield__positional_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),

          abstract__typed_return__no_yield__positional_args__block_default: ({{return_value}}).as({{return_type.id}}),
          abstract__untyped_return__no_yield__positional_args__block_default: ({{return_value}}).as({{return_type.id}}),
          abstract__typed_return__typed_yield__positional_args__block_default: ({{return_value}}).as({{return_type.id}}),
          abstract__untyped_return__typed_yield__positional_args__block_default: ({{return_value}}).as({{return_type.id}}),
          abstract__typed_return__untyped_yield__positional_args__block_default: ({{return_value}}).as({{return_type.id}}),
          abstract__untyped_return__untyped_yield__positional_args__block_default: ({{return_value}}).as({{return_type.id}}),
        {% elsif group.id == :concrete.id %}
          concrete__typed_return__no_yield__no_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          concrete__untyped_return__no_yield__no_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          concrete__typed_return__typed_yield__no_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          concrete__untyped_return__typed_yield__no_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          concrete__typed_return__untyped_yield__no_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          concrete__untyped_return__untyped_yield__no_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),

          concrete__typed_return__no_yield__no_args__block_default: ({{return_value}}).as({{return_type.id}}),
          concrete__untyped_return__no_yield__no_args__block_default: ({{return_value}}).as({{return_type.id}}),
          concrete__typed_return__typed_yield__no_args__block_default: ({{return_value}}).as({{return_type.id}}),
          concrete__untyped_return__typed_yield__no_args__block_default: ({{return_value}}).as({{return_type.id}}),
          concrete__typed_return__untyped_yield__no_args__block_default: ({{return_value}}).as({{return_type.id}}),
          concrete__untyped_return__untyped_yield__no_args__block_default: ({{return_value}}).as({{return_type.id}}),

          concrete__typed_return__no_yield__positional_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          concrete__untyped_return__no_yield__positional_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          concrete__typed_return__typed_yield__positional_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          concrete__untyped_return__typed_yield__positional_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          concrete__typed_return__untyped_yield__positional_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),
          concrete__untyped_return__untyped_yield__positional_args__kwargs_default: ({{return_value}}).as({{return_type.id}}),

          concrete__typed_return__no_yield__positional_args__block_default: ({{return_value}}).as({{return_type.id}}),
          concrete__untyped_return__no_yield__positional_args__block_default: ({{return_value}}).as({{return_type.id}}),
          concrete__typed_return__typed_yield__positional_args__block_default: ({{return_value}}).as({{return_type.id}}),
          concrete__untyped_return__typed_yield__positional_args__block_default: ({{return_value}}).as({{return_type.id}}),
          concrete__typed_return__untyped_yield__positional_args__block_default: ({{return_value}}).as({{return_type.id}}),
          concrete__untyped_return__untyped_yield__positional_args__block_default: ({{return_value}}).as({{return_type.id}}),
        {% else %}
          # Class method mocks can't be defined with keyword arguments.
          {% raise "Unrecognized mock function group: #{group}" %}
        {% end %}
      {% end %}
    ) do
      {% for group in block_groups %}
        {% if group.id == :abstract.id %}
          def abstract__typed_return__no_yield__no_args__kwargs_default : {{return_type.id}}
            {{return_value}}
          end
          def abstract__untyped_return__no_yield__no_args__kwargs_default
            {{return_value}}
          end
          def abstract__typed_return__typed_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
            yield {{return_value}}
          end
          def abstract__untyped_return__typed_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}})
            yield {{return_value}}
          end
          def abstract__typed_return__untyped_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> _) : {{return_type.id}}
            yield {{return_value}}
          end
          def abstract__untyped_return__untyped_yield__no_args__kwargs_default(& : {{yield_arg_type.id}} -> _)
            yield {{return_value}}
          end

          def abstract__typed_return__no_yield__no_args__block_default : {{return_type.id}}
            {{return_value}}
          end
          def abstract__untyped_return__no_yield__no_args__block_default
            {{return_value}}
          end
          def abstract__typed_return__typed_yield__no_args__block_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
            yield {{return_value}}
          end
          def abstract__untyped_return__typed_yield__no_args__block_default(& : {{yield_arg_type.id}} -> {{yield_return_type.id}})
            yield {{return_value}}
          end
          def abstract__typed_return__untyped_yield__no_args__block_default(& : {{yield_arg_type.id}} -> _) : {{return_type.id}}
            yield {{return_value}}
          end
          def abstract__untyped_return__untyped_yield__no_args__block_default(& : {{yield_arg_type.id}} -> _)
            yield {{return_value}}
          end

          def abstract__typed_return__no_yield__positional_args__kwargs_default(arg1, arg2, arg3) : {{return_type.id}}
            {{return_value}}
          end
          def abstract__untyped_return__no_yield__positional_args__kwargs_default(arg1, arg2, arg3)
            {{return_value}}
          end
          def abstract__typed_return__typed_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
            yield {{return_value}}
          end
          def abstract__untyped_return__typed_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}})
            yield {{return_value}}
          end
          def abstract__typed_return__untyped_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _) : {{return_type.id}}
            yield {{return_value}}
          end
          def abstract__untyped_return__untyped_yield__positional_args__kwargs_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _)
            yield {{return_value}}
          end

          def abstract__typed_return__no_yield__positional_args__block_default(arg1, arg2, arg3) : {{return_type.id}}
            {{return_value}}
          end
          def abstract__untyped_return__no_yield__positional_args__block_default(arg1, arg2, arg3)
            {{return_value}}
          end
          def abstract__typed_return__typed_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}}) : {{return_type.id}}
            yield {{return_value}}
          end
          def abstract__untyped_return__typed_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> {{yield_return_type.id}})
            yield {{return_value}}
          end
          def abstract__typed_return__untyped_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _) : {{return_type.id}}
            yield {{return_value}}
          end
          def abstract__untyped_return__untyped_yield__positional_args__block_default(arg1, arg2, arg3, & : {{yield_arg_type.id}} -> _)
            yield {{return_value}}
          end
        {% elsif group.id == :concrete.id %}
          def_concrete_instance_methods(return_value: {{return_value}}, is_mock_type: true, return_type: {{return_type}}, yield_arg_type: {{yield_arg_type}}, yield_return_type: {{yield_return_type}})
        {% elsif group.id == :class.id %}
          def_class_methods(return_value: {{return_value}}, is_mock_type: true, return_type: {{return_type}}, yield_arg_type: {{yield_arg_type}}, yield_return_type: {{yield_return_type}})
        {% else %}
          {% raise "Unrecognized mock function group: #{group}" %}
        {% end %}
      {% end %}
    end
  {% end %}
end

# ----- Shared examples ----- #

macro it_supports_abstract_methods(mock, *, original_value = "original", default_mock_value = "mocked", override_value = "overridden")
  context "[abstract methods]" do
    context_typed_return({{mock}}, :abstract, original_value: {{original_value}}, default_mock_value: {{default_mock_value}}, override_value: {{override_value}})
    context_untyped_return({{mock}}, :abstract, original_value: {{original_value}}, default_mock_value: {{default_mock_value}}, override_value: {{override_value}})
  end
end

macro it_supports_concrete_methods(mock, *, original_value = "original", default_mock_value = "mocked", override_value = "overridden")
  context "[concrete methods]" do
    context_typed_return({{mock}}, :concrete, original_value: {{original_value}}, default_mock_value: {{default_mock_value}}, override_value: {{override_value}})
    context_untyped_return({{mock}}, :concrete, original_value: {{original_value}}, default_mock_value: {{default_mock_value}}, override_value: {{override_value}})
  end
end

macro it_supports_class_methods(mock, *, original_value = "original", default_mock_value = "mocked", override_value = "overridden")
  context "[class methods]" do
    context_typed_return({{mock}}, :class, original_value: {{original_value}}, default_mock_value: {{default_mock_value}}, override_value: {{override_value}})
    context_untyped_return({{mock}}, :class, original_value: {{original_value}}, default_mock_value: {{default_mock_value}}, override_value: {{override_value}})
  end
end

# ----- Return type restriction ----- #

macro context_typed_return(mock, method_part, **values)
  {% method = "#{method_part.id}__typed_return" %}
  context "[return: typed]" do
    context_typed_yield({{mock}}, {{method}}, {{values.double_splat}})
    context_untyped_yield({{mock}}, {{method}}, {{values.double_splat}})
    context_no_yield({{mock}}, {{method}}, {{values.double_splat}})
  end
end

macro context_untyped_return(mock, method_part, **values)
  {% method = "#{method_part.id}__untyped_return" %}
  context "[return: untyped]" do
    context_typed_yield({{mock}}, {{method}}, {{values.double_splat}})
    context_untyped_yield({{mock}}, {{method}}, {{values.double_splat}})
    context_no_yield({{mock}}, {{method}}, {{values.double_splat}})
  end
end

# ----- Yield ----- #

macro context_typed_yield(mock, method_part, **values)
  {% method = "#{method_part.id}__typed_yield" %}
  context "[yield: typed]" do
    context_no_args({{mock}}, {{method}}, {{values.double_splat}})
  end
end

macro context_untyped_yield(mock, method_part, **values)
  {% method = "#{method_part.id}__untyped_yield" %}
  context "[yield: untyped]" do
    context_no_args({{mock}}, {{method}}, {{values.double_splat}})
  end
end

macro context_no_yield(mock, method_part, **values)
  {% method = "#{method_part.id}__no_yield" %}
  context "[yield: none]" do
    context_no_args({{mock}}, {{method}}, {{values.double_splat}})
  end
end

# ----- Arguments ----- #

macro context_no_args(mock, method_part, **values)
  {% method = "#{method_part.id}__no_args" %}
  context "[args: none]" do
    context_kwargs_default_stub({{mock}}, {{method}}, {{values.double_splat}})
    context_block_default_stub({{mock}}, {{method}}, {{values.double_splat}})
    context_no_default_stub({{mock}}, {{method}}, {{values.double_splat}})
  end
end

macro context_no_args(mock, method_part, **values)
  {% method = "#{method_part.id}__positional_args" %}
  context "[args: positional]" do
    context_kwargs_default_stub({{mock}}, {{method}}, {{values.double_splat}})
    context_block_default_stub({{mock}}, {{method}}, {{values.double_splat}})
    context_no_default_stub({{mock}}, {{method}}, {{values.double_splat}})
  end
end

# ----- Default stub ----- #

macro context_kwargs_default_stub(mock, method_part, *, original_value, default_mock_value, override_value)
  {% method = "#{method_part.id}__kwargs_default" %}
  context "[default stub: keyword arguments]" do
    {% unless method.includes?("class") %}
      it_returns_the_default_mock_value({{mock}}, {{method}}, {{default_mock_value}})
    {% end %}
    it_can_have_a_stub_applied({{mock}}, {{method}}, {{override_value}})
    it_compiles_to_the_expected_type({{mock}}, {{method}})
  end
end

macro context_block_default_stub(mock, method_part, *, original_value, default_mock_value, override_value)
  {% method = "#{method_part.id}__block_default" %}
  context "[default stub: block]" do
    it_returns_the_default_mock_value({{mock}}, {{method}}, {{default_mock_value}})
    it_can_have_a_stub_applied({{mock}}, {{method}}, {{override_value}})
    it_compiles_to_the_expected_type({{mock}}, {{method}})
  end
end

macro context_no_default_stub(mock, method_part, *, original_value, default_mock_value, override_value)
  {% method = "#{method_part.id}__no_default" %}
  context "[default stub: none]" do
    {% if method.starts_with?("abstract__") && method.includes?("untyped_return") %}
      it_uses_nil_stub_value({{mock}}, {{method}}, {{override_value}})
    {% else %}
      it_can_have_a_stub_applied({{mock}}, {{method}}, {{override_value}})
      it_compiles_to_the_expected_type({{mock}}, {{method}})
    {% end %}
    it_raises_unexpected_message({{mock}}, {{method}})
  end
end

# ----- Tests ----- #

macro invoke_mock_method(mock, method, &block)
  {% if method.includes?("__positional_args") %}
    {% if method.includes?("__no_yield") %}
      {{mock}}.{{method.id}}("arg1", "arg2", "arg3")
    {% elsif block %}
      {{mock}}.{{method.id}}("arg1", "arg2", "arg3") {{block}}
    {% else %}
      {{mock}}.{{method.id}}("arg1", "arg2", "arg3", &.itself)
    {% end %}
  {% else %}
    {% if method.includes?("__no_yield") %}
      {{mock}}.{{method.id}}
    {% elsif block %}
      {{mock}}.{{method.id}} {{block}}
    {% else %}
      {{mock}}.{{method.id}}(&.itself)
    {% end %}
  {% end %}
end

macro it_returns_the_default_mock_value(mock, method, expected_value)
  it "returns the default mock value" do
    mock = {{mock}}
    begin
      invoke_mock_method(mock, {{method}}).should eq({{expected_value}})
    ensure
      mock.__mocks.reset
    end
  end
end

macro it_can_have_a_stub_applied(mock, method, override_value)
  it "can have a stub applied" do
    mock = {{mock}}
    begin
      stub = ::Mocks::ValueStub.new({{method.id.symbolize}}, {{override_value}})
      mock.__mocks.add_stub(stub)
      invoke_mock_method(mock, {{method}}).should eq({{override_value}})
    ensure
      mock.__mocks.reset
    end
  end
end

macro it_uses_nil_stub_value(mock, method, override_value)
  it "invokes the stub and ignores the return value" do
    called = false
    mock = {{mock}}
    begin
      stub = ::Mocks::ProcStub.new({{method.id.symbolize}}) do
        called = true
        {{override_value}}
      end
      mock.__mocks.add_stub(stub)
      invoke_mock_method(mock, {{method}}).should be_nil
      called.should be_true
    ensure
      mock.__mocks.reset
    end
  end
end

macro it_raises_unexpected_message(mock, method)
  it "raises an UnexpectedMessage error when called without a stub" do
    mock = {{mock}}
    begin
      expect_raises(::Mocks::UnexpectedMessage, {{"/#{method.id}/".id}}) do
        invoke_mock_method(mock, {{method}})
      end
    ensure
      mock.__mocks.reset
    end
  end
end

macro it_compiles_to_the_expected_type(mock, method, type = String)
  it "compiles to the expected type" do
    typeof(invoke_mock_method({{mock}}, {{method}})).should eq({{type.id}})
  end
end

macro it_allows_calling_standard_methods(mock)
  it "allows calling standard methods" do
    mock = {{mock}}

    (mock == mock).should eq(true), "`mock == mock` was not true"
    (mock == nil).should eq(false), "`mock == nil` was not false"
    (mock == "foo").should eq(false), "`mock == \"foo\"` was not false"

    unless mock.is_a?(Class)
      (mock === mock).should eq(true), "`mock === mock` was not true"
      (mock === nil).should eq(false), "`mock === nil` was not false"
      (mock === "foo").should eq(false), "`mock === \"foo\" was not false"
    end

    mock.to_s.should contain(mock.class.name), "`mock.to_s` should contain its type name"
    mock.inspect.should contain(mock.class.name), "`mock.inspect` should contain its type name"

    buffer = IO::Memory.new
    mock.to_s(buffer)
    buffer.to_s.should contain(mock.class.name), "`mock.to_s(io)` should contain its type name"
    buffer = IO::Memory.new
    mock.inspect(buffer)
    buffer.to_s.should contain(mock.class.name), "`mock.inspect(io)` should contain its type name"

    if mock.is_a?(Reference)
      mock.same?(mock).should eq(true), "`mock.same?(mock)` was not true"
      mock.same?(nil).should eq(false), "`mock.same?(nil)` was not false"
      mock.same?("foo").should eq(false), "`mock.same?(\"foo\")` was not false"
    end
  end
end
