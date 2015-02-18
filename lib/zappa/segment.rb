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

    def from_wav(wav)
      @wav = wav
      persist
    end

    def export(path)
      persist
      cmd = 'ffmpeg -i ' + @cache.path + ' -y -f wav ' + path
      Open3.popen3(cmd) do |_stdin, _stdout, _stderr, wait_thr|
        fail 'Cannot export to' + path unless wait_thr.value.success?
      end
    end

    def spawn(data)
      binding.pry
      new_wav = deep_copy(@wav)
      new_wav.update_data(data)
      seg = Segment.new
      s.wav = new_wav
      seg
    end

    def persist
      fail 'No data to persist' if @wav.nil?
      @cache = Tempfile.new('zappa') if @cache.nil?
      File.write(@cache.path, @wav.pack)
    end

    private

    def safe_copy(path)
      tmp = Tempfile.new('zappa')
      cmd = 'ffmpeg -i ' + path + ' -vn -y -f wav ' + tmp.path
      Open3.popen3(cmd) do |_stdin, _stdout, _stderr, wait_thr|
        fail 'Cannot open file ' + path unless wait_thr.value.success?
      end
      tmp
    end
  end
end
