module VoiceBase
  module V2
    module Response

      TRANSCRIPT_READY = "finished".freeze
      def success?
        ok?
      end

      def transcript_ready?

        http_response.parsed_response['media'].first['status'].casecmp(TRANSCRIPT_READY) == 0
      end
      def transcript
        http_response.parsed_response['media'].first['transcripts']['latest']['words']
      end

      private
    end
  end
end
