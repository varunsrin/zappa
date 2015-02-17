require 'spec_helper'
require 'tempfile'

WAV_IN  = 'spec/audio/basic-5s.wav'
WAV_EX  = 'does-not-exist.wav'

describe Zappa::Wave do
  it 'reads format headers correctly' do
    fmt_header = { audio_format: 1,
                   channels: 2,
                   sample_rate: 44_100,
                   byte_rate: 176_400,
                   block_align: 4,
                   bits_per_sample: 16 }
    w = Zappa::Wave.new(WAV_IN)
    expect(w.format).to eq(fmt_header)
  end

  it 'updates file without altering it' do
    orig = Zappa::Wave.new(WAV_IN)
    orig.update
    current = Zappa::Wave.new(WAV_IN)
    expect(orig).to eq(current)
  end

  it 'raises error for incorrect path' do
    expect { Zappa::Wave.new(WAV_EX) }.to raise_error(Zappa::FileError)
  end

  pending 'handles wave files with unknown subchunks'
  pending 'handles wave files with optional tmp data'
end
