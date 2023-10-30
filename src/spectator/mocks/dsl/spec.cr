# Include DSL methods and use 'can' syntax for Crystal's Spec framework.
{% skip_file unless @top_level.has_constant?(:Spec) %}

require "../scope"
require "./can_syntax"
require "./expectations"
require "./methods"

module Spec::Methods
  include Spectator::Mocks::DSL::Methods
end

module Spec::Expectations
  include Spectator::Mocks::DSL::Expectations
end

module Spectator::Mocks::Stubbable
  include DSL::CanSyntax
end

# Wrap each example with a scope.
Spec.around_each do |example|
  Spectator::Mocks::Scope.push do
    example.run
  end
end
