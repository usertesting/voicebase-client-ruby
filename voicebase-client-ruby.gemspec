# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'voicebase/version'

Gem::Specification.new do |spec|
  spec.name          = "voicebase-client-ruby"
  spec.version       = VoiceBase::version
  spec.authors       = ["Juergen Fesslmeier", "April Wensel", "Jerry Hogsett"]
  spec.email         = ["jerry@usertesting.com", "client-dev@usertesting.com"]

  spec.summary       = %q{Ruby client for VoiceBase API Version 1.x and 2.x.}
  spec.description   = %q{Ruby client for VoiceBase API Version 1.x and 2.x that will make both API versions available at the same time.}
  spec.homepage      = "https://github.com/usertesting/voicebase-client-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 12.1"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "timecop", "~> 0.9"

  spec.add_dependency "httparty", "~> 0.15"
  spec.add_dependency "activesupport", "~> 5.1"
end
