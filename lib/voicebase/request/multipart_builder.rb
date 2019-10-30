require "securerandom"

module VoiceBase
  module Request
    class MultipartBuilder
      attr_accessor :parts, :boundary
      def initialize(headers:)
        @headers = headers
        @parts = []
        @boundary = SecureRandom.hex
      end

      def add(part)
        parts << part
      end

      def body
        "--#{boundary}\r\n#{multiparts}--#{boundary}--"
      end

      def headers
        @headers.merge({"Content-Type" => "multipart/form-data; boundary=#{boundary}"})
      end

      private

      def multiparts
        parts.map(&:multipart).join("--#{boundary}\r\n")
      end
    end
  end
end
