require_relative "text_part"
require "json"

module VoiceBase
  module Request
    class HashPart < TextPart
      def initialize(name:, hash:)
        @name = name
        @body = ::JSON.dump(hash)
      end
    end
  end
end
