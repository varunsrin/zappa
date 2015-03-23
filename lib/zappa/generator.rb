module Zappa
  class Generator
    attr_accessor :sample_rate, :channels, :bit_depth

    def initialize(sample_rate = 44_100, channels = 2, bit_depth = 16)
      @sample_rate = sample_rate
      @channels = channels
      @bit_depth = bit_depth
      @max_amplitude = ((2 ** bit_depth) / 2) - 1 
    end

    def sine(frequency, length)
      wave_pos = 0.0
      wave_delta = frequency.to_f / @sample_rate.to_f
      num_samples = (length * @sample_rate).round
      samples = []
      num_samples.times do  |i|
        value = (sine_at(wave_pos) * @max_amplitude).round
        samples[i] = [value] * @channels
        wave_pos += wave_delta
        wave_pos -= 1.0 if wave_pos >= 1.0
      end
      clip_from_samples(samples)
    end

    private

    def clip_from_samples(samples)
      wave = Zappa::Wave.new
      wave.set_samples(samples)
      clip = Zappa::Clip.new(wave)
    end

    def sine_at(position); Math::sin(position * 2 * Math::PI); end
  end
end
