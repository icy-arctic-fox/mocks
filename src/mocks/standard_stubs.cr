module Mocks
  # Set of methods for stubbable objects.
  # These methods have default implementations to prevent `UnexpectedMessage` errors in common use cases.
  # Their behavior can be redefined with a new stub.
  # NOTE: These methods are sensitive to changes in the core library.
  #   For instance, if the type restrictions don't align, these stubs won't apply.
  module StandardStubs
    macro included
      {% if @type < Reference %}
        stub def same?(other : Reference) : Bool
          object_id == other.object_id
        end

        stub def same?(other : Nil) : Bool
          false
        end

        stub def to_s(io : IO) : Nil
          io << "#<" << self.class.name << ":0x"
          object_id.to_s(io, 16)
          io << '>'
        end

        stub def inspect(io : IO) : Nil
          to_s(io)
        end

        stub def ==(other : self) : Bool
          same?(other)
        end

        stub def ===(other : self) : Bool
          same?(other)
        end
      {% elsif @type < Value %}
        stub def to_s(io : IO) : Nil
          this = self
          ptr = pointerof(this).as(UInt8*)
          size = sizeof(self)
          bytes = Bytes.new(ptr, size, read_only: true)

          io << "#<" << self.class.name 
          bytes.each_with_index do |byte, i|
            if i >= 8
              io << " ... "
              break
            end
    
            io << ' '
            byte.to_s(io, 16)
          end
          io << '>'
        end

        stub def inspect(io : IO) : Nil
          this = self
          ptr = pointerof(this).as(UInt8*)
          size = sizeof(self)
          bytes = Bytes.new(ptr, size, read_only: true)
 
          io << "#<" << self.class.name 
          bytes.each_with_index do |byte, i|
            io << ' '
            byte.to_s(io, 16)
          end
          io << '>'
        end

        stub def ==(other : Value) : Bool
          return false if typeof(self) != typeof(other)

          this = self
          this_ptr = pointerof(this)
          LibC.memcmp(this_ptr, pointerof(other), sizeof(self)) == 0
        end

        stub def ===(other : Value) : Bool
          self == other
        end
      {% end %}

      stub def to_s : String
        String.build do |io|
          to_s(io)
        end
      end

      stub def inspect : String
        String.build do |io|
          inspect(io)
        end
      end

      stub def ==(other) : Bool
        false
      end

      stub def ==(other : Nil) : Bool
        false
      end

      stub def ===(other) : Bool
        false
      end

      stub def ===(other : Nil) : Bool
        false
      end
    end
  end
end
