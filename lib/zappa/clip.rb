require 'tempfile'
require 'open3'
require 'zappa/processor'

module Zappa
  class Clip
    attr_accessor :wav, :cache

    def initialize(wav = nil)
      if wav
        @wav = wav
      else
        @wav = Wave.new
      end
      @cache = nil
      @processor = Processor.new
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

    def slice(pos, len)
      slice_samples(ms_to_samples(pos), ms_to_samples(len))
    end

    def slice_samples(pos, len)
      fail 'invalid index' if pos < 0 || (pos + len) > @wav.sample_count
      slice = @wav.samples[pos, len]
      clone(slice)
    end

    def +(other)
      return amplify(other) if other.class == Fixnum

      if other.class == Zappa::Clip
        fail 'format mismatch' unless @wav.format == other.wav.format
        w = Wave.new
        w.format = @wav.format
        samples = []
        samples += @wav.samples if @wav.samples
        samples += other.wav.samples if other.wav.samples
        w.set_samples(samples)
        return Clip.new(w)
      end

      fail "cannot add Zappa::Clip to #{other.class}"
    end

    # Processor Interfaces

    def normalize(headroom)
      clone(@processor.normalize(@wav.samples, headroom))
    end

    def compress(ratio = 2.0, threshold = - 20.0)
      clone(@processor.compress(@wav.samples, ratio, threshold))
    end

    def amplify(db)
      clone(@processor.amplify(@wav.samples, db))
    end

    def invert
      clone(@processor.invert(@wav.samples))
    end

    def filter(type, cutoff)
      filter_types = %w(high_pass low_pass)
      fail "Unknown filter type: #{type}" unless filter_types.include?(type)
      samples = @processor.send("#{type}_filter", @wav.samples,
                                cutoff, @wav.format.sample_rate)
      clone(samples)
    end

    # TODO: - Make utilities generic in a module, and call them specifically here.

    def rms(values)
      # this should be a util
      return 0 if values.size == 0
      fail 'rms only accepts arrays' unless values.class == Array
      values_sq = values.flatten.map { |s| s**2 }
      Math.sqrt(values_sq.inject(:+).to_f / values_sq.length)
    end

    def max_possible_amplitude
      # this should be a property of wave or clip
      (2**@wav.format.bits_per_sample) / 2
    end

    def dbfs
      # this should be a property of wave or clip
      # Sample bit depth gives us the total range
      # Divide by two to get the maximum positive or negative value
      max_poss_amplitude = (2**@wav.format.bits_per_sample) / 2.0
      ratio_to_db(rms(@wav.samples) / max_poss_amplitude)
    end

    def ratio_to_db(ratio)
      # this should be a util
      20 * Math.log10(ratio)
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

    def clone(samples = nil)
      clone = Clip.new
      clone.wav = Marshal.load(Marshal.dump(@wav))
      clone.wav.set_samples(samples) if samples
      clone
    end
  end
end
