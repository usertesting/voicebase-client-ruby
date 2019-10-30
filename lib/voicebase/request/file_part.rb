require "mime/types"
require_relative "text_part"

module VoiceBase
  module Request
    class FilePart < TextPart
      attr_accessor :filepath

      def initialize(name:, file:)
        @name = name
        @filepath = file.path
        @body = file.read
      end

      def multipart
        "Content-Disposition: form-data; name=\"#{CGI::escape(name)}\"; filename=\"#{ File.basename(filepath) }\"\r\n" +
          "Content-Type: #{ mime_type.simplified }\r\n\r\n#{ body }\r\n\r\n"
      end

      private

      def mime_type
        MIME::Types.type_for(filepath)[0] || MIME::Types["application/octet-stream"][0]
      end
    end
  end
end
