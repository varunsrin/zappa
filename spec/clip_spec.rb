require 'spec_helper'
require 'tempfile'

WAV_IN  = 'spec/audio/basic-5s.wav'
WAV_IN_DATA_SIZE = 882_000

describe Zappa::Clip do
  before :each do
    subject.from_file(WAV_IN)
  end

  describe '#from_file' do
    it 'makes a safe wav copy of the file' do
      orig_file = File.open(WAV_IN, 'rb')
      orig_wav = Zappa::Wave.new
      orig_wav.unpack(orig_file)
      cached_wav = Zappa::Wave.new
      cached_wav.unpack(subject.cache)
      expect(orig_wav).to eq(cached_wav)
    end

    it 'has a path value' do
      expect(subject.cache.nil?).to eq(false)
    end

    it 'raises error if file does not exist' do
      c = Zappa::Clip.new
      expect { c.from_file('some_foo') }.to raise_error(RuntimeError)
    end

    pending 'raises error if ffmpeg is not installed'
  end

  describe '#export' do
    before do
      @tmp = Tempfile.new('zappa-spec')
      subject.cache = nil
      subject.export(@tmp.path)
    end

    it 'persisted the file' do
      expect(subject.cache.nil?).to eq(false)
      # expect the data of cache matches data in object
    end

    it 'exports the clip correctly' do
      export_wav = Zappa::Wave.new
      export_wav.unpack(File.open(@tmp.path, 'rb'))
      expect(subject.wav == export_wav).to eq(true)
    end

    it 'raises error for invalid path' do
      expect { subject.export('some:foo') }.to raise_error(RuntimeError)
    end

    pending 'raises error if ffmpeg is not installed'
  end

  describe '#slice_samples' do
    before :each do
      @slice = subject.slice_samples(4, 4)
    end

    it 'fails if the beginning is negative' do
      expect { subject.slice_samples(-1, 2) }.to raise_error(RuntimeError)
    end

    it 'fails if the length exceeds the wave\'s length' do
      expect { subject.slice_samples(1, WAV_IN_DATA_SIZE) }
        .to raise_error(RuntimeError)
    end

    it 'slices the wave by sample range' do
      expect(@slice.wav.data_size).to eq(16)
    end

    it 'invalidates the cache' do
      expect(@slice.cache).to eq(nil)
    end
  end

  describe '#slice' do
    before :each do
      @slice = subject.slice(0, 4)
    end

    it 'slices the wav by ms range' do
      samples_in_ms = (4 * 44.1).round
      total_bytes = samples_in_ms * 4
      expect(@slice.wav.data_size).to eq(total_bytes)
    end

    it 'invalidates the cache' do
      expect(@slice.cache).to eq(nil)
    end
  end

  describe '#+' do
    context 'concatenation' do
      it 'adds two audio clips together' do
        combined = subject + subject
        expect(combined.wav.data_size).to be(WAV_IN_DATA_SIZE * 2)
      end

      it 'adds audio clip to empty clip' do
        new_clip = Zappa::Clip.new
        combined = subject + new_clip
        expect(combined.wav.data_size).to be(WAV_IN_DATA_SIZE)
      end

      it 'fails if the wave formats are different' do
        sub_copy =  Marshal.load(Marshal.dump(subject))
        sub_copy.wav.format.sample_rate = 22_000
        expect { subject + sub_copy }.to raise_error(RuntimeError)
      end
    end

    context 'amplification' do 
      it 'amplifies clip when added to integer' do
        amplified = subject + 2
        expect(amplified.wav).to eq(subject.amplify(2).wav) # maybe just expect the method to be called?
      end
    end
  end
end
