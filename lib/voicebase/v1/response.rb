module VoiceBase
  module V1
    module Response
      def self.extended(response)
      end

      def success?
        ok? && request_status == "SUCCESS"
      end

      # need a separate #transcript_ready? method because with V2
      # the HTTP status code is used to indicate request success, but
      # a separate status field indicates the current transcription stage at VoiceBase

      def transcript_ready?
        success?
      end

    end
  end
end
