require 'tempfile'

module Zappa
  class Segment
    attr_reader :source

    def initialize(path = nil)
      if path
        from_file(path)
      else
        @source = nil
      end
    end

    def from_file(path)
      @source = Wave.new(safe_copy(path))
    end

    def to_file(path, format = 'wav')
      raise FileError.new('No data in Segment') if @source.nil?
      out = system('ffmpeg', '-i', @source.file_path, '-y', '-f', format, path)
      raise ('Cannot export to' + path ) if out == false
      raise FileError.new('ffmpeg not installed') if out.nil?
    end

    def ==(other)
      source == other.source
    end

    private

    def safe_copy(path)
      tmp = Tempfile.new('zappa')
      out = system('ffmpeg', '-i', path, '-vn', '-y', '-f', 'wav', tmp.path)
      raise 'Cannot open file' if out == false
      raise 'ffmpeg not installed' if out.nil?
      tmp.path
    end
  end
end
