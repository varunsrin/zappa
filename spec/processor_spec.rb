require 'spec_helper'

describe Zappa::Processor do
  let(:subject) { Zappa::Processor.new }
  let(:samples) { [[0, -1], [24_000, -24_000]] }
  let(:max_val) { 32_768 }
  let(:min_val) { -32_768 }

  describe '#amplify' do
    let(:double_factor) { 6.020599913279623 } # double_factor db == 2x linear
    
    before do
      @amplified = subject.amplify(double_factor, samples)
    end

    it 'doubles sample values' do
      expect(@amplified[0]).to eq(samples[0].collect { |s| s * 2 })
    end

    it 'does not let sample values go over the maximum value' do
      expect(@amplified[1][0]).to eq(max_val)
    end

    it 'does not let sample values go under the minimum value' do
      expect(@amplified[1][1]).to eq(min_val)
    end
  end

  describe '#invert' do
    it 'inverts all sample values' do
      inverted = subject.invert(samples)
      expect(inverted[0][0]).to eq(0)
      expect(inverted[0][1]).to eq(1)
      expect(inverted[1][0]).to eq(-24_000)
      expect(inverted[1][1]).to eq(24_000)
    end
  end
end
