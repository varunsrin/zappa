module Zappa
  class WaveData
    attr_reader :samples, :chunk_id, :chunk_size

    def initialize
      @chunk_id = 'data'
      @chunk_size = 0
      @samples = []
    end

    def set_samples(samples)
      @samples = samples
      frame_size = samples[1].size
      @chunk_size = @samples.size * frame_size * 2
    end

    def ==(other)
      other.chunk_size == @chunk_size && other.chunk_id == @chunk_id
    end
  end
end
