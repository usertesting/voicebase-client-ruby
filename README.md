# Voicebase Client Ruby

This is a Ruby client to the VoiceBase API Version [1.x](http://www.voicebase.com/developers/) and [2.x](https://apis.voicebase.com). Some portions of this gem were derived from [voicebase-client-ruby](https://github.com/popuparchive/voicebase-client-ruby).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'voicebase-client-ruby', github: "usertesting/voicebase-client-ruby"
```

And then execute:

    $ bundle

## Usage

For VoiceBase API V1.x:

```ruby
require 'voicebase'

client = VoiceBase::Client.new({
  api_version: "1.1",
  auth_key: "my-voicebase-key",
  auth_secret: "my-voicebase-secret",
})

client.upload_media({
  media_url: "http://my.media-example.com/media1.mp3",
  title: "My fancy media",
  transcription_type: 'machine',
  external_id: 'abcd1234',
  machine_ready_callback: "http://my.example.com/success",
  error_callback: "http://my.example.com/error"
})

```

For VoiceBase API V2.x:

```ruby
require 'voicebase'

client = VoiceBase::Client.new({
  api_version: "2.0.beta",
  auth_key: "my-voicebase-key",
  auth_secret: "my-voicebase-secret",
})

...
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/voicebase/voicebase-client-ruby.

