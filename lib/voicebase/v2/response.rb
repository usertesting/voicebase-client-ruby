module VoiceBase
  module V2
    module Response

      def success?

        #todo the V2 API response does not include a "requestStatus" field
        # need to determine Juergen's intent here.

        ok? #&& request_status == "SUCCESS"
      end
    end
  end
end
