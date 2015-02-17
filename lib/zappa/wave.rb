# http://soundfile.sapp.org/doc/WaveFormat/

module Zappa
  class Wave
    attr_accessor :format, :data, :data_size, :file_path
    SUBCHUNKS = %q('fmt', 'data')
    KNOWN_FMT_SIZE = 16

    def initialize(path)
      @format = {}
      @data = {}

      begin
        @file = File.new(path, 'rb')
      rescue
        raise FileError.new('Could not find ' + path)
      else
        @file_path = @file.path
        unpack_wav
      end
    end

    def unpack_wav
      unpack_riff_header
      while @data[:data].nil?
        unpack_subchunk
      end
    end

    def unpack_riff_header
      chunk_id = @file.read(4)
      _ = @file.read(4).unpack('V').first # chunk_size
      format = @file.read(4)
      raise FileFormatError.new('Format is not WAVE') unless format == 'WAVE'
      raise FileFormatError.new('ID is not RIFF') unless chunk_id == 'RIFF'
    end

    def unpack_subchunk
      id = @file.read(4).strip
      if SUBCHUNKS.include?(id)
        send('unpack_' + id)
      else
        unpack_unknown
      end
    end

    def unpack_fmt
      size                      = @file.read(4).unpack('V').first
      @format[:audio_format]    = @file.read(2).unpack('v').first
      @format[:channels]        = @file.read(2).unpack('v').first
      @format[:sample_rate]     = @file.read(4).unpack('V').first
      @format[:byte_rate]       = @file.read(4).unpack('V').first
      @format[:block_align]     = @file.read(2).unpack('v').first
      @format[:bits_per_sample] = @file.read(2).unpack('v').first
      unread = size - KNOWN_FMT_SIZE
      @format[:unknown] = @file.read(unread) if unread > 0
    end

    def unpack_data
      @data[:size]  = @file.read(4).unpack('V').first
      @data[:data]  = @file.read(@data[:size])
    end

    def unpack_unknown
      size = @file.read(4).unpack('V').first
      @file.read(size)
    end

    def ==(other)
      other.format == format && other.data == data
    end
  end
end
