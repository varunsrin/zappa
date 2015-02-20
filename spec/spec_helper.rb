require 'bundler/setup'
Bundler.setup

require 'coveralls'
Coveralls.wear!

require 'zappa'

RSpec.configure do |config|
  # config
end

def slice_and_unpack(item, offset, size, enc)
  item = item.byteslice(offset, size)
  item = item.unpack(enc) if enc
end
