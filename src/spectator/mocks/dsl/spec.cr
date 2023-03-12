# Include DSL methods and use 'can' syntax for Crystal's Spec framework.
{% skip_file unless @top_level.has_constant?(:Spec) %}

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
