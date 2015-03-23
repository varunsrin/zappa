module Zappa
  class Processor
    # amplify the signal
    def amplify(db, samples)
      mul_samples(samples, db_to_float(db))
    end

    def invert(samples)
      mul_samples(samples, -1)
    end

    private

    def mul_samples(samples, factor)
      samples.map { |f| mul_frame(f, factor) }
    end

    def mul_frame(frame, factor)
      frame.map { |s| clip((s * factor).round) }
    end

    def clip(value, max = 32_768)
      return max if value > max
      return -max if value < (-max)
      value
    end

    # convert db values to floats
    def db_to_float(db); 10**(db / 20); end
  end
end
