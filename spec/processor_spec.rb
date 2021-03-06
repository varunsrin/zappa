require 'spec_helper'

describe Zappa::Processor do
  let(:subject) { Zappa::Processor.new }
  let(:samples) { [[0, -1], [24_000, -24_000]] }
  let(:max_val) { 32_768 }
  let(:min_val) { -32_768 }

  describe '#amplify' do
    let(:double_factor) { 6.020599913279623 } # double_factor db == 2x linear

    before do
      @amplified = subject.amplify(samples, double_factor)
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
      expect(inverted).to eq([[0, 1], [-24_000, 24_000]])
    end
  end

  describe '#normalize' do
    it 'normalizes all sample values' do
      normalized = subject.normalize(samples, -0.1)
      expect(normalized).to eq([[0, -1], [32_393, -32_393]])
    end
  end

  describe '#compressor' do
    before do
      @compressed = subject.compress(samples, 4.0, -20.0)
    end

    it 'does not affect values below the threshold' do
      expect(@compressed[0]).to eq([0, -1])
    end

    it 'affects values above the threshold according to the ratio' do
      expect(@compressed[1]).to eq([18_819, -18_819])
    end
  end
end
