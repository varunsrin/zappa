require 'tempfile'
require 'open3'
require 'pry'

module Zappa
  class Segment
    attr_accessor :wav, :cache

    def initialize
      @wav = Wave.new
      @cache = nil
    end

    def from_file(path)
      @cache = safe_copy(path) 
      @wav.unpack(@cache)
    end

    def slice(from, to)
      slice_samples(ms_to_samples(from), ms_to_samples(to))
    end

    def slice_samples(from, to)
      slice = @wav.slice_samples(from, to)
      @wav.update_data(slice)
      @cache = nil
    end

    def export(path)
      persist if @cache.nil?
      cmd = 'ffmpeg -i ' + @cache + ' -y -f wav ' + path
      Open3.popen3(cmd) do |_stdin, _stdout, _stderr, wait_thr|
        fail 'Cannot export to' + path unless wait_thr.value.success?
      end
    end

    def persist
      if @cache.nil?
        tmp = Tempfile.new('zappa')
        @cache = tmp.path 
      end
      File.write(@cache, @wav.pack)
    end

    private

    def ms_to_samples(ms)
      (ms * @wav.format.sample_rate / 1000).round
    end

    def safe_copy(path)
      tmp = Tempfile.new('zappa')
      cmd = 'ffmpeg -i ' + path + ' -vn -y -f wav ' + tmp.path
      Open3.popen3(cmd) do |_stdin, _stdout, _stderr, wait_thr|
        fail 'Cannot open file ' + path unless wait_thr.value.success?
      end
      tmp.path
    end
  end
end
