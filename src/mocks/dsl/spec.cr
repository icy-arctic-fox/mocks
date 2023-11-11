# Include DSL methods and use 'can' syntax for Crystal's Spec framework.
{% skip_file unless @top_level.has_constant?(:Spec) %}

require "../scope"
require "./can_syntax"
require "./expectations"
require "./methods"

module Spec::Methods
  include Mocks::DSL::Methods
end

module Spec::Expectations
  include Mocks::DSL::Expectations
end

module Mocks::Stubbable
  include DSL::CanSyntax
end

# Wrap each example with a scope.
Spec.around_each do |example|
  Mocks::Scope.push do
    example.run
  end
end
