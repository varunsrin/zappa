require 'zappa/wave/format'
require 'zappa/wave/riff_header'
require 'zappa/wave/sub_chunk'

# http://soundfile.sapp.org/doc/WaveFormat/
module Zappa
  class Wave
    attr_reader :header, :format, :opt_chunks

    def initialize
      @header = RiffHeader.new
      @format = Format.new
      @wave_data = SubChunk.new
      @opt_chunks = []
    end

    def data
      @wave_data.data
    end

    def data_size
      @wave_data.chunk_size
    end

    def update_data(d)
      curr_size = @wave_data.data.bytesize
      new_size = d.bytesize
      @header.chunk_size += (new_size - curr_size) 
      @wave_data.chunk_size = new_size
      @wave_data.data = d
    end

    def ==(other)
      other.data == data
    end

    def pack
      enc_file = @header.pack + @format.pack
      @opt_chunks.each do |c|
        enc_file += c.pack
      end
      enc_file + @wave_data.pack
    end

    def unpack(file)
      file = find_unpack_file(file)
      data_found = false
      @header = RiffHeader.new(file)
      @format = Format.new(file)
      while !data_found
        s = SubChunk.new(file)
        if s.chunk_id == 'data'
          @wave_data = s
          data_found = true
        else
          @opt_chunks << s
        end
      end
    end

    def find_unpack_file(file)
      return File.open(file, 'rb') if file.class == String
      file
    end
  end
end
