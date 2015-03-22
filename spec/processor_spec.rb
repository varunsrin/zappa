require 'spec_helper'

describe Zappa::Processor do
  let(:subject) { Zappa::Processor.new }
  let(:max_val) { 32_768 }
  let(:min_val) { -32_768 }

  describe '#amplify' do
    let(:double_factor) { 6.020599913279623 } # double_factor db == 2x linear
    let(:samples) { [[0, -1], [24_000, -24_000]] }

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
end
