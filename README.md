# Zappa

Zappa is a high level audio manipulation library for Ruby, inspired by pydub.

## Installation

First install ffmpeg:

    brew install ffmpeg

Add this line to your application's Gemfile:

    gem 'zappa'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zappa

## Usage

You can open a wave file:

```
include 'zappa'
s = Segment.from_file('this_is_a_song.wav')
```

and then read any of its properties:

```
puts s.format
```

and save it to a different location:

```
s.export('output.wav')
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/zappa/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
