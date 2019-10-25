module VoiceBase
  module Request
    class TextPart
      attr_accessor :name, :body
      def initialize(name:, body:)
        @name = name
        @body = body
      end

      def multipart
        "Content-Disposition: form-data; name=\"#{CGI::escape(name)}\"\r\n\r\n#{body}\r\n"
      end
    end
  end
end
