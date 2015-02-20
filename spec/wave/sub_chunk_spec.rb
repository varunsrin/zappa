require 'spec_helper'

describe Zappa::SubChunk do
  OFFSET = 36

  before do
    wav_path = 'spec/audio/basic-5s.wav'
    file = File.open(wav_path, 'rb')
    file.read(OFFSET)
    @pck = Zappa::SubChunk.new(file).pack
    @src = File.read(wav_path)
  end

  it 'unpacks and packs chunk_id correctly' do
    src_id = @src.byteslice(OFFSET, 4)
    pck_id = @pck.byteslice(0, 4)
    expect(src_id).to eq(pck_id)
  end

  it 'unpacks and packs data correctly' do
    src_size = @src.byteslice(OFFSET + 4, 4).unpack('V')
    pck_size = @pck.byteslice(4, 24).unpack('V')
    expect(src_size).to eq(pck_size)

    src_data = @src.byteslice(OFFSET + 8, src_size[0])
    pck_data = @pck.byteslice(8, pck_size[0]).force_encoding('UTF-8')
    expect(src_data).to eq(pck_data)
  end
end
