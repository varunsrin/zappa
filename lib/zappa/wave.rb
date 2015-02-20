require 'zappa/wave/format'
require 'zappa/wave/riff_header'
require 'zappa/wave/sub_chunk'

# WAV Spec: http://soundfile.sapp.org/doc/WaveFormat/

module Zappa
  class Wave
    attr_accessor :header, :format

    def initialize
      @header = RiffHeader.new
      @format = Format.new
      @wave_data = SubChunk.new
    end

    def data
      @wave_data.data
    end

    def data_size
      @wave_data.chunk_size
    end

    def frame_size
      @format.bits_per_sample * @format.channels / 8
    end

    def sample_count
      data_size / frame_size
    end

    def ==(other)
      other.data == data
    end

    def update_data(new_data)
      @wave_data.chunk_id = 'data'
      new_size = new_data.bytesize
      @header.chunk_size += (new_size - @wave_data.chunk_size) 
      @wave_data.chunk_size = new_size
      @wave_data.data = new_data
    end

    def pack
      pack = @header.pack + @format.pack + @wave_data.pack
    end

    def unpack(source)
      begin
        file = File.open(path_to(source), 'rb')
      rescue
        fail 'Unable to open WAV file'
      else
        data_found = false
        @header = RiffHeader.new(file)
        @format = Format.new(file)
        while !data_found
          s = SubChunk.new(file)
          if s.chunk_id == 'data'
            @wave_data = s
            data_found = true
          end
        end
      end
    end

    def path_to(source)
      return source if source.class == String
      return source.path if source.class == File
      fail 'cannot unpack type: ' + source.class.to_s
    end
  end
end
