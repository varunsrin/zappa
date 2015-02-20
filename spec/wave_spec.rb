require 'spec_helper'
require 'tempfile'

describe Zappa::Wave do
  let(:wav_path) { 'spec/audio/basic-5s.wav' }
  let(:empty_path) { 'does-not-exist.wav' }
  let(:wav_data_size) { 882000 }
  let(:wav_def_fmt) { { audio_format: 1,
                        channels: 2,
                        sample_rate: 44_100,
                        byte_rate: 176_400,
                        block_align: 4,
                        bits_per_sample: 16 } }
  let(:wav_def_hdr) { { chunk_id: 'RIFF',
                        chunk_size: 40,
                        format: 'WAVE' } }

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
      expect(w.data).to eq(nil)
      expect(w.data_size).to eq(0)
    end
  end

  describe '#update_data' do
    let (:slice_length) { 4 }

    before :each do
      @new_data = @wav.data.byteslice(0, slice_length)
      @wav.update_data(@new_data)
    end

    it 'updates the wav data correctly' do
      expect(@wav.data).to eq(@new_data)
    end

    it 'updates header data correctly' do
      expect(@wav.header.chunk_size).to eq(40)
      expect(@wav.data_size).to eq(slice_length)
    end
  end

  describe '#pack' do
    it 'packs all sub-chunks into a string' do
      expect(@wav.pack.bytesize).to eq(@file.size)
    end
  end

  describe '#unpack' do
    it 'reads format headers correctly' do
      wav_def_fmt.each do |h|  
        expect(h[1]).to eq(@wav.format.send(h[0]))
      end
    end

    it 'reads data size correctly' do
      expect(@wav.data_size).to eq(wav_data_size)
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
      @new_wave.update_data('')
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
