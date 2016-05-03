module VoiceBase
  module V1
    module Response
      def self.extended(response)
      end

      def success?
        ok? && request_status == "SUCCESS"
      end


      def transcript_ready?

        # this was added because with the V1 API, a value in the returned JSON indicates both a
        # successful HTTP request, but also a ready transcript. With V2, there's no JSON value
        # to indicate status. Instead, the HTTP status code indicates request status, and
        # the state becoming "finished" indicates the transcript it ready.

        success?
      end

    end
  end
end
