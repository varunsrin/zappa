module Zappa
  class SubChunk
    attr_reader :chunk_id
    attr_accessor :chunk_size, :data

    def initialize(file = nil)
      if file.nil?
        @chunk_size = 0
        @data = nil
      else
        @chunk_id = file.read(4)
        @chunk_size = file.read(4).unpack('V').first
        @data = file.read(@chunk_size)
      end
    end

    def update(data)
      @chunk_size = data.bytesize
      @data = data
    end

    def pack
      @chunk_id + [@chunk_size].pack('V') + @data
    end

    def ==(other)
      other.data == data && other.chunk_id = chunk_id
    end
  end
end
