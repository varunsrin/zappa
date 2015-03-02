module Zappa
  class SubChunkHeader
    attr_accessor :chunk_id, :chunk_size

    def initialize(data = nil)
      @chunk_id = nil
      @chunk_size = 0
      unpack(data) if data
    end

    def pack
      @chunk_id + [@chunk_size].pack('V')
    end

    def unpack(data)
      @chunk_id = data.byteslice(0, 4)
      @chunk_size = data.byteslice(4, 4).unpack('V').first
    end

    def ==(other)
      other.chunk_size == @chunk_size && other.chunk_id = @chunk_id
    end
  end
end
