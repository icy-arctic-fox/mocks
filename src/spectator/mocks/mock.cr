require "./stubbable"
require "./stubbed"

module Spectator::Mocks
  module Mock
    macro define(type, **stubs, &block)
      {% if type.is_a?(Call) && type.name == :<.id %}
        {% parent = type.args.first
           parent = if parent.is_a?(Path | TypeNode | Generic | Union | Metaclass)
                      parent.resolve
                    else
                      parse_type(parent.id.stringify).resolve
                    end
           type = type.receiver
           type_keyword = if parent.class?
                            :class
                          elsif parent.struct?
                            :struct
                          elsif parent.module?
                            :module
                          else
                            raise "Unsupported mock type for #{parent.name}"
                          end %}

        {% begin %}
          {% if type_keyword == :module %}
            module {{type}}
              include {{parent}}

              class Instance
                include {{type}}

                # Empty initializer to override the `.new` method from {{type}}.
                def initialize
                end
              end

              @[::Spectator::Mocks::Stubbed]
              def self.new : Instance
                Instance.new
              end
          {% else %}
            {{type_keyword.id}} {{type}} < {{parent.name}}
          {% end %}
            include ::Spectator::Mocks::Stubbable::Automatic

            {% for name, value in stubs %}
              stub_existing({{name}}) { {{value}} }
            {% end %}

            {{block.body if block}}
          end
        {% end %}

      {% else %}
        {% raise "Syntax error in mock definition. Must be: `NewType < OriginalType`" %}
      {% end %}
    end
  end
end
