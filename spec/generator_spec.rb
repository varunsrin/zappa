require 'spec_helper'

describe Zappa::Generator do
  let(:subject) { Zappa::Generator.new(44_100, 1, 16) }
   let(:wav_path) { 'spec/audio/sine-1000hz.wav' }

  describe '#sine' do
    it 'generates a 1000 Hz sine wave' do
      file = File.open(wav_path, 'rb')
      orig_wav = Zappa::Wave.new
      orig_wav.unpack(file)

      gen_clip = subject.sine(1000, 0.01)
      expect(orig_wav).to eq(gen_clip.wav)
    end
  end
end

