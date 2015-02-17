require 'spec_helper'
require 'tempfile'

WAV_IN  = 'spec/audio/basic-5s.wav'

describe Zappa::Segment do
  before do
    subject.from_file(WAV_IN)
  end

  describe '#from_file' do
    it 'makes a safe copy of the source wav file' do
      expect(Zappa::Wave.new(WAV_IN))
        .to eq(Zappa::Wave.new(subject.source.file_path))
    end

    it 'raises error if file does not exist' do
      expect { Zappa::Segment.new('some_foo') }.to raise_error(RuntimeError)
    end

    pending 'raises error if ffmpeg is not installed'
    pending 'only permits wav files'
  end

  describe '#to_file' do
    it 'exports the segment to a wav file' do
      tmp = Tempfile.new('zappa-spec')
      subject.to_file(tmp.path)
      expect(Zappa::Wave.new(WAV_IN)).to eq(Zappa::Wave.new(tmp.path))
    end

    it 'raises error if segment is empty' do
      w = Zappa::Segment.new
      expect { w.to_file('foo.wav') }.to raise_error(RuntimeError)
    end

    it 'raises error for invalid path' do
      expect { subject.to_file('some:foo') }.to raise_error(RuntimeError)
    end

    pending 'raises error if ffmpeg is not installed'
  end
end
