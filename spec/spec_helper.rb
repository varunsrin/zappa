require 'bundler/setup'
Bundler.setup

require 'zappa'

RSpec.configure do |config|
  # config
end

def wav_data(encoded_wav)
  encoded_wav.split('dataPu').last
end
