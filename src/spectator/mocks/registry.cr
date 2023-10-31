require "string_pool"
require "./call"
require "./stub"

module Spectator::Mocks
  # Stores and retrieves method stubs and calls for multiple objects.
  #
  # Reference-based objects are tracked by their `#object_id` (memory address).
  # Value-based objects are tracked by their byte-wise representation.
  #
  # NOTE: This approach does not work for mutable values, and their use is generally discouraged.
  #   This also implies that two separate values with the same content will be tracked as the same object.
  #
  # See: https://crystal-lang.org/reference/1.7/syntax_and_semantics/structs.html
  class Registry
    # Entry keys consist of two elements - the type ID and it's location in memory.
    # For value-types, it's byte-representation is is stored in a pool and that location is used.
    #
    # WARNING: The `Class#crystal_type_id` method, which is undocumented, is used to retrieve the first part of the key.
    #
    # NOTE: Ideally, the type would be used as the first element of the tuple.
    #   `Object.class` cannot be used due to https://github.com/crystal-lang/crystal/issues/9667
    alias Key = {Int32, UInt64}

    # Structure used to store stubs and calls for an object.
    private struct Entry
      # Stubs added to an object.
      getter stubs = [] of Stub

      # Method calls made to an object.
      getter calls = [] of AbstractCall
    end

    # Entries are stored and lazily created with a hash.
    @entries = Hash(Key, Entry).new do |hash, key|
      hash[key] = Entry.new
    end

    # String pool used to de-duplicate and track values.
    @pool = StringPool.new

    # Adds a stub for an object.
    def add_stub(object, stub : Stub) : Nil
      key = generate_key(object)
      @entries[key].stubs << stub
    end

    # Finds a stub suitable stub for a method call.
    # Returns nil if no stub was found.
    # Stubs are searched in *reverse* order so that newly define stubs take precedence.
    def find_stub(object, call : Call) : Stub?
      key = generate_key(object)
      return unless entry = @entries[key]?

      # Reverse search to ensure later-defined stubs take precedence.
      entry.stubs.reverse_each do |stub|
        return stub if stub === call
      end
    end

    # Removes all previously stubs added for an object.
    def clear_stubs(object) : Nil
      key = generate_key(object)
      @entries[key]?.try &.stubs.clear
    end

    # Records a method call made to an object.
    def add_call(object, call : Call) : Nil
      key = generate_key(object)
      @entries[key].calls << call
    end

    # Retrieves all method calls made to an object.
    def calls(object) : Enumerable
      key = generate_key(object)
      if entry = @entries[key]?
        entry.calls
      else
        [] of AbstractCall
      end
    end

    # Removes all previously recorded method calls for an object.
    def clear_calls(object) : Nil
      key = generate_key(object)
      @entries[key]?.try &.calls.clear
    end

    # Removes all stored stubs and calls for all objects.
    def clear : Nil
      @entries.clear
      # NOTE: There's no method for clearing a `StringPool`.
      #   Recreate it to allow GC to cleanup.
      @pool = StringPool.new
    end

    # Removes all stored stubs and calls for the specified object.
    def clear(object) : Nil
      key = generate_key(object)
      @entries.delete(key)
      # NOTE: There's no method for deleting an item from a `StringPool`.
    end

    # Generates the hash key used for the specified object.
    # This uses the object's type name and its ID.
    private def generate_key(object : Reference) : Key
      {object.class.crystal_type_id, object.object_id}
    end

    # Generates the hash key used for the specified object.
    # This computes the compound key consisting of the type's name and the value's byte representation.
    #
    # The object's value is copied from the stack (this method's scope) to the heap.
    # A string pool is utilized to de-duplicate values and reduce memory consumption.
    # It also acts as the mechanism to copy the value to the heap and get a suitable object ID (memory address).
    private def generate_key(object : Value) : Key
      # Get a slice referring to the contents of the object.
      # This is only valid for the duration of this method's scope.
      ptr = pointerof(object).as(UInt8*)
      size = sizeof(typeof(object))
      bytes = Bytes.new(ptr, size, read_only: true)

      # De-duplicate the value.
      # This may allocate memory, but the value's bytes will be safely stored in the string pool.
      string = @pool.get(bytes)

      {object.class.crystal_type_id, string.object_id}
    end
  end
end
