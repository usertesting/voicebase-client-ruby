module VoiceBase
  module V3
    module Response

      TRANSCRIPT_READY_STATUS = "finished".freeze

      def success?

        # for the V1 API this indicates both a successful HTTP status code and a values of "SUCCESS" in the
        # returned JSON. with V2, there is no "SUCCESS" value. The combined use was split, adding
        # #transcript_ready? to both interfaces.

        ok?
      end

      def media_id
        voicebase_response['mediaId']
      end

      def transcript_ready?
        voicebase_response['status'].casecmp(TRANSCRIPT_READY_STATUS) == 0
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
