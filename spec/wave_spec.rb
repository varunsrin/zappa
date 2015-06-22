require 'spec_helper'
require 'tempfile'

describe Zappa::Wave do
  let(:wav_path) { 'spec/audio/basic-5s.wav' }
  let(:empty_path) { 'does-not-exist.wav' }
  let(:wav_data_size) { 882_000 }
  let(:wav_def_fmt) do
    { audio_format: 1,
      channels: 2,
      sample_rate: 44_100,
      byte_rate: 176_400,
      block_align: 4,
      bits_per_sample: 16 }
  end
  let(:wav_def_hdr) do
    { chunk_id: 'RIFF',
      chunk_size: 40,
      format: 'WAVE' }
  end

  before :each do
    @file = File.open(wav_path, 'rb')
    @wav = Zappa::Wave.new
    @wav.unpack(@file)
  end

  describe '#initialize' do
    it 'has a default header, format chunks and empty wave chunk' do
      w = Zappa::Wave.new
      wav_def_hdr.each { |h| expect(h[1]).to eq(w.header.send(h[0])) }
      wav_def_fmt.each { |h| expect(h[1]).to eq(w.format.send(h[0])) }
      expect(w.data_size).to eq(0)
      expect(w.samples).to eq([])
    end
  end

  describe 'unpacks and packs wave data' do
    before :each do
      @packed = @wav.pack
      @file_data = File.read(wav_path)
    end

    it 'does not alter the format' do
      packed_fmt = @packed.byteslice(8, 8)
      fmt = @file_data.byteslice(8, 8)
      expect(packed_fmt).to eq(fmt)
    end

    it 'does not alter the wave data' do
      packed_data = @packed.byteslice(16, wav_data_size - 16).force_encoding('UTF-8')
      data = @file_data.byteslice(16, wav_data_size - 16)
      expect(packed_data).to eq(data)
    end
  end

  describe '#set_samples' do
    let (:samples) { [[3, 1], [3, 1]] }

    before :each do
      @wav.set_samples(samples)
    end

    it 'updates the header correctly' do
      expect(@wav.header.chunk_size).to eq(44)
    end

    it 'updates the wave data correctly' do
      expect(@wav.samples).to eq(samples)
    end
  end

  describe '#==' do
    before :each do
      @new_wave = Marshal.load(Marshal.dump(@wav))
    end

    it 'is equal to a wave with identical data' do
      expect(@wav).to eq(@new_wave)
    end

    it 'is equal to a wave with different fmt data' do
      @new_wave.format.bits_per_sample = 2
      expect(@wav).to eq(@new_wave)
    end

    it 'is not equal to a wave with different data' do
      @new_wave.set_samples([3, 1])
      expect(@wav).not_to eq(@new_wave)
    end
  end

  describe '#path_to' do
    it 'returns input, if provided a file' do
      expect(subject.path_to(@file)).to eq(@file.path)
    end

    it 'returns the file at path, if provided a path' do
      expect(subject.path_to(wav_path)).to eq(wav_path)
    end
  end
end
