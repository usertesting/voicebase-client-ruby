module VoiceBase
  module V2
    module Response

      TRANSCRIPT_READY = "finished".freeze

      def success?

        # for the V1 API this indicates both a successful HTTP status code and a values of "SUCCESS" in the
        # returned JSON. with V2, there is no "SUCCESS" value. The combined use was split, adding
        # #transcript_ready? to both interfaces.

        ok?
      end

      def transcript_ready?
        http_response.parsed_response['media'].first['status'].casecmp(TRANSCRIPT_READY) == 0
      end

      #todo double check the format for plain text transcriptions, but it's probably just text only
      def transcript
        http_response.parsed_response['media'].first['transcripts']['latest']['words']
      end

      private

    end
  end
end
