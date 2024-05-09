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

  # Returns a fake value of the specified type.
  # This is used to trick the compiler into inferring a specific type.
  # This macro should only be used where strictly needed,
  # and the value should _never_ be used.
  macro fake_value(type)
    ::Pointer({{type}}).new(0).value
  end
end
