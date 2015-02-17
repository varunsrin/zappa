require 'spec_helper'
require 'tempfile'

WAV_IN  = 'spec/audio/basic-5s.wav'

describe Zappa::Segment, '#from_file' do
  it 'reads wav file data into the segment' do
    subject.from_file(WAV_IN)
    expect(wav_data(subject.data)).to eq(wav_data(IO.binread(WAV_IN)))
  end

  it 'raises error if file does not exist' do
    expect{ subject.from_file('some_foo') }.to raise_error(RuntimeError)
  end

  pending 'does not destroy metadata'
end

describe Zappa::Segment, '#to_file' do
  it 'exports the segment to a wav file' do
    subject.from_file(WAV_IN)
    output = Tempfile.new('zappa-spec').path
    subject.to_file(output)
    expect(IO.binread(subject.safe_wav_path)).to eq(IO.binread(output))
  end

  it 'creates an empty wave container if segment is empty' do
  end

  it 'raises error for invalid path' do
    subject.from_file(WAV_IN)
    expect{ subject.to_file('some:foo') }.to raise_error(RuntimeError)
  end
end

