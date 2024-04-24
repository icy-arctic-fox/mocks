require "./mocks/*"

# A utility library providing mock functionality.
# Intended for testing, but can be used anywhere.
module Mocks
  VERSION = {{ `shards version "#{__DIR__}"`.stringify.chomp }}

  # Indicates whether mock functionality is enabled.
  class_getter? enabled : Bool = false

  # Enables mock functionality.
  # This should be called by the test framework once it is ready.
  def self.enable
    @@enabled = true
  end

  # Disables mock functionality.
  # This can be used to disable mock functionality temporarily.
  def self.disable
    @@enabled = false
  end
end
