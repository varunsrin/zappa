module Zappa
  class RiffHeader
    def initialize(file)
      unpack(file)
      fail 'ID is not RIFF' unless @chunk_id == 'RIFF'
      fail 'Format is not WAVE' unless @format == 'WAVE'
    end

    def pack
      @chunk_id + [@chunk_size].pack('V') + @format
    end

    def unpack(file)
      @chunk_id = file.read(4)
      @chunk_size = file.read(4).unpack('V').first
      @format = file.read(4)
    end
  end
end
