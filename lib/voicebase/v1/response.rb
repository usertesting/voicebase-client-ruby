module VoiceBase
  module V1
    module Response
      def self.extended(response)
      end

      def success?
        ok? && request_status == "SUCCESS"
      end
    end
  end
end
