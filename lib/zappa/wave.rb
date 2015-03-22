require 'zappa/wave/format'
require 'zappa/wave/riff_header'
require 'zappa/wave/sub_chunk_header'
require 'zappa/wave/wave_data'

# WAV Spec: http://soundfile.sapp.org/doc/WaveFormat/

module Zappa
  class Wave
    attr_accessor :header, :format, :wave_data

    def initialize
      @header = RiffHeader.new
      @format = Format.new
      @wave_data = WaveData.new
    end

    def samples
      @wave_data.samples
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
      other.wave_data == wave_data
    end

    def pack
      pack = @header.pack + @format.pack
      pack  += @wave_data.chunk_id
      pack += [@wave_data.chunk_size].pack('V')
      pack += pack_samples(@wave_data.samples)
      pack
    end

    def unpack(source)
      file = File.open(path_to(source), 'rb')
    rescue
      raise 'Unable to open WAV file'
    else
      @header = RiffHeader.new(file)
      @format = Format.new(file)
      while sc_header = file.read(8)
        s = SubChunkHeader.new(sc_header)
        if s.chunk_id == 'data'
          unpack_samples(file)
        else
          file.read(s.chunk_size)
        end
      end
    end

    def set_samples(samples)
      samples_change = (samples.size - @wave_data.samples.size)
      size_change = samples_change * @format.channels * 2
      @header.chunk_size += size_change
      @wave_data.set_samples(samples)
    end

    def path_to(source) # Private method?
      return source if source.class == String
      return source.path if source.class == File
      fail 'cannot unpack type: ' + source.class.to_s
    end

    private

    def pack_samples(samples)
      pack_str = 's' * @format.channels
      samples.map { |f| f.pack(pack_str) }.join
    end

    def unpack_samples(file)
      samples = []
      size = @format.bits_per_sample / 8
      ch = @format.channels
      while (frame_data = file.read(size * ch))
        samples << frame_data.unpack('s' * ch)
      end
      @wave_data.set_samples(samples)
    end
  end
end
