require 'spec_helper'

describe Zappa::WaveData do
  before :each do
    @samples = [[7,5], [1,3], [4,4]]
    @dummy_samples = [[1,2], [3,4]]
    subject.set_samples(@samples)
  end

  describe 'set samples' do
    before :each do
      subject.set_samples(@dummy_samples)
    end

    it 'recalculates size correctly' do
      expect(subject.chunk_size).to eq(8)
    end

    it 'replaces existing samples with new samples' do
      expect(subject.samples).to eq(@dummy_samples)
    end
  end

  describe 'equality' do
    it 'is equal if the data is equal' do
      d = Zappa::WaveData.new
      d.set_samples(@samples)
      expect(subject).to eq(d)
    end

    it 'is not equal if the data is not equal' do
      d = Zappa::WaveData.new
      d.set_samples(@dummy_samples)
      expect(subject).not_to eq(d)
    end
  end
end
