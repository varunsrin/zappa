require 'spec_helper'

describe Zappa::Format do
  let(:src_offset) { 12 }
  let(:fmt_size) { 24 }
  let(:wav_path) { 'spec/audio/basic-5s.wav' }

  it 'unpacks and packs each format chunk correctly' do
    src = File.read(wav_path)
    src_fmt = src.byteslice(src_offset, fmt_size)
    
    file = File.open(wav_path, 'rb')
    file.read(src_offset)
    fmt = Zappa::Format.new(file)
    pck_fmt = fmt.pack.force_encoding('UTF-8')
    
    expect(src_fmt).to eq(pck_fmt)
  end
end
