require "./mocks/*"

# A utility library providing mock functionality.
# Intended for testing, but can be used anywhere.
module Mocks
  VERSION = {{ `shards version "#{__DIR__}"`.stringify.chomp }}
end
