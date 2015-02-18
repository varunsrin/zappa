module Zappa
  class Format
    attr_accessor :name, :audio_format, :bits_per_sample, :block_align,
                  :byte_rate, :channels, :sample_rate, :chunk_size, :unknown

    FMT_SIZE = 16

    def initialize(file = nil)
      if file.nil?
        @chunk_id        = 'fmt '
        @chunk_size      = FMT_SIZE
        @audio_format    = 1
        @channels        = 2
        @sample_rate     = 44100
        @byte_rate       = 176_400
        @block_align     = 4
        @bits_per_sample = 16
      else
        @chunk_id = file.read(4)
        @chunk_size = file.read(4).unpack('V').first
        unpack(file.read(@chunk_size))
      end
    end

    def pack
      fmt = @chunk_id
      fmt += [@chunk_size].pack('V')
      fmt += [@audio_format].pack('v')
      fmt += [@channels].pack('v')
      fmt += [@sample_rate].pack('V')
      fmt += [@byte_rate].pack('V')
      fmt += [@block_align].pack('v')
      fmt + [@bits_per_sample].pack('v')
    end

    def unpack(data)
      @audio_format    = data.byteslice(0,2).unpack('v').first
      @channels        = data.byteslice(2,4).unpack('v').first
      @sample_rate     = data.byteslice(4,8).unpack('V').first
      @byte_rate       = data.byteslice(8,12).unpack('V').first
      @block_align     = data.byteslice(12,14).unpack('v').first
      @bits_per_sample = data.byteslice(14,16).unpack('v').first
      unknown_size     = @chunk_size - FMT_SIZE
      @unknown      = data.byteslice(16, 16 + unknown_size) if unknown_size > 0
    end
  end
end