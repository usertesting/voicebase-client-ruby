require 'json'
require 'uri'
require 'httparty'
require 'active_support/core_ext/module'

require "voicebase/version"
require "voicebase/helpers"

require "voicebase/v1"
require "voicebase/v2"

require "voicebase/client"
require "voicebase/client/token"
require "voicebase/response"

module VoiceBase
  class AuthenticationError < StandardError; end
  class ArgumentError < StandardError; end
end
