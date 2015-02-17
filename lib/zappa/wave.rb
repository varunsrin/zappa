require 'zappa/wave/format'
require 'zappa/wave/riff_header'
require 'zappa/wave/sub_chunk'

# http://soundfile.sapp.org/doc/WaveFormat/
module Zappa
  class Wave
    attr_accessor :header, :format, :data, :opt_chunks, :file_path

    def initialize(path = nil)
      @opt_chunks = []
      @data = nil
      @file_path = path
      from_file(@file_path) unless @file_path.nil?
    end

    def save
      File.write(@file_path, pack)
    end

    def from_file(path)
      begin
        @file = File.new(path, 'rb')
      rescue
        raise FileError, 'Could not find ' + path
      else
        unpack
      end
    end

    def ==(other)
      other.data.data == data.data
    end

    private

    def pack
      enc_file = @header.pack + @format.pack
      @opt_chunks.each do |c|
        enc_file += c.pack
      end
      enc_file + @data.pack
    end

    def unpack
      @header = RiffHeader.new(@file)
      @format = Format.new(@file)
      while @data.nil?
        s = SubChunk.new(@file)
        if s.chunk_id == 'data'
          @data = s
        else
          @opt_chunks << s
        end
      end
    end
  end
end
