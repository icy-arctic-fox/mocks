require "string_pool"
require "./call"
require "./stub"

module Spectator::Mocks
  # Stores and retrieves method stubs and calls for multiple objects.
  # The type parameter *T* indicates the type(s) that can be stored.
  abstract class StubRegistry(T)
    # Structure used to store stubs and calls for an object.
    private struct Entry
      # Stubs added to an object.
      getter stubs = [] of Stub

      # Method calls made to an object.
      getter calls = [] of Call
    end

    # Adds a stub for an object.
    def add_stub(object : T, stub : Stub) : Nil
      entry = fetch(object)
      entry.stubs << stub
    end

    # Finds a stub suitable stub for a method call.
    # Returns nil if no stub was found.
    def find_stub(object : T, call : Call) : Stub?
      return unless entry = fetch?(object)

      entry.stubs.find do |stub|
        stub === call
      end
    end

    # Removes all previously stubs added for an object.
    def clear_stubs(object : T) : Nil
      return unless entry = fetch?(object)

      entry.stubs.clear
    end

    # Records a method call made to an object.
    def add_call(object : T, call : Call) : Nil
      entry = fetch(object)
      entry.calls << call
    end

    # Retrieves all method calls made to an object.
    def calls(object : T) : Enumerable(Call)
      if entry = fetch?(object)
        entry.calls
      else
        [] of Call
      end
    end

    # Removes all previously recorded method calls for an object.
    def clear_calls(object : T) : Nil
      return unless entry = fetch?(object)

      entry.calls.clear
    end

    # Removes all stored stubs and calls for all objects.
    abstract def clear : Nil

    # Removes all stored stubs and calls for the specified object.
    abstract def clear(object : T) : Nil

    # Attempts to retrieve an entry for the specified object.
    # Nil is returned if the object isn't tracked or its data has been deleted.
    private abstract def fetch?(object : T) : Entry?

    # Retrieves an entry for the specified object.
    # An entry is created for the object if it doesn't exist.
    private abstract def fetch(object : T) : Entry
  end
end
