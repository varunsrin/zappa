require 'spec_helper'

describe Zappa::RiffHeader do
  let(:wav_path) { 'spec/audio/basic-5s.wav' }

  it 'unpacks and packs header correctly' do
    src = File.read(wav_path)
    src_header = src.byteslice(0..11)

    file = File.open(wav_path, 'rb')
    subject.unpack(file)
    pck_header = subject.pack
    
    expect(src_header).to eq(pck_header)
  end
end