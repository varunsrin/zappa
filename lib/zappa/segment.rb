require 'tempfile'
require 'open3'
require 'pry'

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

    def to_file(path)
      raise FileError.new('No data in Segment') if @source.nil?
      cmd = 'ffmpeg -i ' + @source.file_path + ' -y -f wav ' + path
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        raise ('Cannot export to' + path ) unless wait_thr.value.success?
      end
    end

    def ==(other)
      source == other.source
    end

    private

    def safe_copy(path)
      tmp = Tempfile.new('zappa')
      cmd = 'ffmpeg -i ' + path + ' -vn -y -f wav ' + tmp.path
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        raise ('Cannot open file ' + path ) unless wait_thr.value.success?
      end
      tmp.path
    end
  end
end
