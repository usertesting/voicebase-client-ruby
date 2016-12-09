module VoiceBase
  module V2
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
        voicebase_response['media']['status'].casecmp(TRANSCRIPT_READY_STATUS) == 0
      end

      def transcript
        # this retrieves the JSON transcript only
        # the plain text transcript is a plain text non-JSON response
        voicebase_response['media']['transcripts']['latest']['words']
      end

      def keywords
        voicebase_response['media']['keywords']['latest']['words']
      end

      def keyword_groups
        voicebase_response['media']['keywords']['latest']['groups']
      end

      def topics
        voicebase_response['media']['topics']['latest']['topics']
      end

      private

      def voicebase_response
        http_response.parsed_response
      end

    end
  end
end
