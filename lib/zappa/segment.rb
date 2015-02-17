require 'tempfile'

module Zappa
  class Segment
    attr_reader :data, :safe_wav_path

    def initialize
      @data, @safe_wav_path = nil, nil
    end

    def from_file(path)
      @safe_wav_path = Tempfile.new('zappa').path
      out = system("ffmpeg", "-i", path, "-vn", "-y", "-f", "wav", @safe_wav_path)
      raise 'Cannot open wave file' if out == false
      raise 'ffmpeg not installed' if out.nil?
      @data = IO.binread(@safe_wav_path)
    end

    def to_file(path)
      out = system("ffmpeg", "-i", @safe_wav_path, "-y", "-f", "wav", path)
      raise ("Cannot export to" + path ) if out == false
    end
  end
end