require 'tempfile'
require 'open3'
require 'pry'

module Zappa
  class Clip
    attr_accessor :wav, :cache

    def initialize(wav=nil)
      if wav
        @wav = wav
      else
        @wav = Wave.new
      end
      @cache = nil
    end

    def from_file(path)
      @wav.unpack(path)
      persist_cache
    end

    def export(path)
      persist_cache if @cache.nil?
      cmd = 'ffmpeg -i ' + @cache + ' -y -f wav ' + path
      Open3.popen3(cmd) do |_stdin, _stdout, _stderr, wait_thr|
        fail 'Cannot export to' + path unless wait_thr.value.success?
      end
    end

    def slice(from, to)
      slice_samples(ms_to_samples(from), ms_to_samples(to))
    end

    def slice_samples(from, to)
      fail 'invalid index' if from < 0 || to > @wav.sample_count
      fail 'negative range' if from >= to
      from *= @wav.frame_size
      to *= @wav.frame_size
      length = (to - from)
      slice = @wav.data.byteslice(from, length)
      clone(slice)
    end

    def +(other)
      fail 'format mismatch' unless @wav.format == other.wav.format 
      w = Wave.new()
      w.format = @wav.format
      w.update_data(@wav.data + other.wav.data)
      Clip.new(w)
    end

    private

    def ms_to_samples(ms)
      (ms * @wav.format.sample_rate / 1000).round
    end

    def persist_cache
      tmp = Tempfile.new('zappa')
      @cache = tmp.path 
      File.write(@cache, @wav.pack)
    end

    def ffmpeg_wav_export(source, destination)
      cmd = 'ffmpeg -i ' + source + ' -vn -y -f wav ' + destination
      Open3.popen3(cmd) do |_stdin, _stdout, _stderr, wait_thr|
        fail 'Cannot open file ' + path unless wait_thr.value.success?
      end
      destination
    end

    def clone(data = nil)
      clone = Clip.new
      clone.wav = Marshal.load(Marshal.dump(@wav))
      clone.wav.update_data(data) if data
      clone
    end
  end
end
