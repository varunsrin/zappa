require 'spec_helper'
require 'tempfile'

WAV_IN  = 'spec/audio/basic-5s.wav'

describe Zappa::Segment do
  describe '#initialize' do
    it 'does not have a cache value' do
      expect(subject.cache.nil?).to eq(true)
    end
  end

  describe '#from_file' do
    before do
      subject.from_file(WAV_IN)
    end

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
      s = Zappa::Segment.new
      expect { s.from_file('some_foo') }.to raise_error(RuntimeError)
    end

    pending 'raises error if ffmpeg is not installed'
  end


  describe '#persist' do
    before :each do
      subject.from_file(WAV_IN)
    end

    it 'creates new cache, if none exists' do
      subject.cache = nil
      subject.persist
      expect(subject.cache.nil?).to eq(false)
      w = Zappa::Wave.new
      w.unpack(subject.cache)
      expect(subject.wav).to eq(w)
    end

    it 'overwrites cache, if it exists' do
      subject.wav.format.sample_rate = 44101
      subject.persist
      w = Zappa::Wave.new
      w.unpack(subject.cache)
      expect(w.format.sample_rate).to eq(44101)
    end
  end


  describe '#slice_samples' do
    before :each do
      subject.from_file(WAV_IN)
      subject.slice_samples(0, 4)
    end

    it 'slices the wave by sample range' do
      expect(subject.wav.data_size).to eq(16)
    end

    it 'invalidates the cache' do
      expect(subject.cache).to eq(nil)
    end
  end


  describe '#slice' do
    before :each do
      subject.from_file(WAV_IN)
      subject.slice(0, 4)
    end

    it 'slices the wav by ms range' do
      expect(subject.wav.data_size).to eq(704)
    end

    it 'invalidates the cache' do
      expect(subject.cache).to eq(nil)
    end
  end


  describe '#export' do
    before do
      @tmp = Tempfile.new('zappa-spec')
      subject.from_file(WAV_IN)
      subject.cache = nil
      subject.export(@tmp.path)
    end

    it 'persisted the file' do
      expect(subject.cache.nil?).to eq(false)
    end

    it 'exports the segment correctly' do
      orig_wav = Zappa::Wave.new
      orig_wav.unpack(File.open(WAV_IN, 'rb')) 
      export_wav = Zappa::Wave.new
      export_wav.unpack(File.open(@tmp.path, 'rb'))
      expect(orig_wav).to eq(export_wav)
    end

    it 'raises error for invalid path' do
      expect { subject.export('some:foo') }.to raise_error(RuntimeError)
    end

    pending 'raises error if ffmpeg is not installed'
  end
end
