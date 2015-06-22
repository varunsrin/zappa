module Zappa
  class Generator
    attr_accessor :sample_rate, :channels, :bit_depth

    def initialize(sample_rate = 44_100, channels = 2, bit_depth = 16)
      @sample_rate = sample_rate
      @channels = channels
      @bit_depth = bit_depth
      @max_amplitude = ((2 ** bit_depth) / 2) - 1 
    end

    def generate(type, frequency, length)
      types = %w(sine square sawtooth white_noise)
      raise "Cannot generate #{type} wave" unless types.include?(type)

      samples = []
      wave_pos = 0.0
      wave_delta = frequency.to_f / @sample_rate.to_f
      num_samples = (length * @sample_rate).round

      num_samples.times do  |i|
        wave_value = send(type, wave_pos)
        abs_value = (wave_value * @max_amplitude).round
        samples[i] = [abs_value] * @channels
        wave_pos += wave_delta
        wave_pos -= 1.0 if wave_pos >= 1.0
        #TODO - account for skips >= 2.0
      end
      clip_from_samples(samples)
    end

    private

    def clip_from_samples(samples)
      wave = Zappa::Wave.new
      wave.set_samples(samples)
      clip = Zappa::Clip.new(wave)
    end

    def sine(position)
      Math::sin(position * 2 * Math::PI)
    end

    def square(position)
      position < 0.5 ? 1 : -1
    end

    def sawtooth(position)
      2 * (position - (0.5 + position).floor)
    end

    def white_noise(_position); rand(-1.0..1.0); end
  end
end
