module Spectator::Mocks
  module Mock
    macro define(name, **stubs, &block)
      {% if type.is_a?(Call) && type.name == :<.id %}
        {% parent = type.args.first
           parent = parse_type(parent.id.stringify).resolve
           type = type.name
           type_keyword = if parent.class?
                            :class
                          elsif parent.struct?
                            :struct
                          elsif parent.module?
                            :module
                          else
                            raise "Unsupported mock type for #{parent.name}"
                          end %}

        {% if type_keyword == :module %}
        {{@type.name}}.mock_module {{type}}, {{**stubs}} {{block}}

        {% else %}
          {{type_keyword.id}} {{type}} < {{parent.name}}
            include ::Spectator::Mocks::Stubbable::Automatic

            private def default_stubs
              {{**stubs}}
            end

            {{block.body if block}}
          end
        {% end %}

      {% else %}
        {% raise "Syntax error in mock definition. Must be: `NewType < OriginalType`" %}
      {% end %}
        end
  end

  macro mock_module(type, **stubs, &block)
    module {{type}}
      extend {{parent}}

      def self.new : Instance
        Instance.new
      end

      class Instance
        include {{type}}
      end
    end
  end
end
