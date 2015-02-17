module Zappa
  class SubChunk
    attr_accessor :chunk_id, :chunk_size, :data

    def initialize(file)
      @chunk_id = file.read(4)
      @chunk_size = file.read(4).unpack('V').first
      @data = file.read(@chunk_size)
    end

    def pack
      @chunk_id + [@chunk_size].pack('V') + @data
    end

    def ==(other)
      other.data == data && other.chunk_id = chunk_id
    end
  end
end
