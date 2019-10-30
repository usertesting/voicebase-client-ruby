module VoiceBase
  module V3
    module Response

      TRANSCRIPT_READY_STATUS = "finished".freeze

      def success?
        ok?
      end

      def media_id
        voicebase_response['mediaId']
      end

      def transcript_ready?
        voicebase_response['status'].downcase == TRANSCRIPT_READY_STATUS
      end

      def transcript
        # this retrieves the JSON transcript only
        # the plain text transcript is a plain text non-JSON response
        voicebase_response['transcript']['words']
      end

      def keywords
        knowledge["keywords"]
      end

      def topics
        knowledge['topics']
      end

      private

      def knowledge
        voicebase_response.fetch("knowledge", {}) || {}
      end

      def voicebase_response
        http_response.parsed_response
      end

    end
  end
end
