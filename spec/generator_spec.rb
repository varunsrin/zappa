require 'spec_helper'

describe Zappa::Generator do
  let(:subject) { Zappa::Generator.new(44_100, 1, 16) }
  let(:sine_path) { 'spec/audio/sine-1000hz.wav' }

  describe '#generate' do
    it 'raises an error for unknown types' do
      expect { subject.generate('circle', 1000, 0.01) }
        .to raise_error
    end

    it 'generates a 1000 Hz sine wave' do
      file = File.open(sine_path, 'rb')
      orig_wav = Zappa::Wave.new
      orig_wav.unpack(file)

      gen_clip = subject.generate('sine', 1000, 0.01)
      expect(orig_wav).to eq(gen_clip.wav)
    end

    # generated sawtooth, square waves have slightly diff values 
    # from audacity generated waves. why?
    pending 'generates a 1000 Hz sawtooth wave'
    pending 'generates a 1000 Hz square wave'
  end
end

