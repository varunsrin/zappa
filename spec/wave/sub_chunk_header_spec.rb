require 'spec_helper'

describe Zappa::SubChunkHeader do
  OFFSET = 36

  before :each do
    file = File.read('spec/audio/basic-5s.wav')
    @sc_header = file.byteslice(OFFSET, 8)
    subject.unpack(@sc_header)
  end

  it 'unpacks subchunk data correctly' do
    expect(subject.chunk_id).to eq('data')
    expect(subject.chunk_size).to eq(882000)
  end

  it 'packs subchunk data into a string' do
    expect(subject.pack).to eq(@sc_header)
  end
end
