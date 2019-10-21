module VoiceBase
  class Response
    include Helpers
    attr_accessor :http_response

    delegate :code, :body, :headers, :message, to: :http_response, allow_nil: true

    def initialize(http_response, api_version = "1.1")
      @http_response = http_response
      if api_version.to_f < 2
        self.extend(VoiceBase::V1::Response)
      elsif api_version.to_f == 2.0
        self.extend(VoiceBase::V2::Response)
      elsif api_version.to_f == 3.0
        self.extend(VoiceBase::V3::Response)
      else
         raise "Unknown version"
      end
    end

    def ok?
      http_response.code && http_response.code >= 200 && http_response.code < 300
    end

    # E.g.
    #
    # @response.request_status is derived from the
    # response hash 'statusMessage' key, or
    # @response.status_message from 'statusMessage'
    #
    def method_missing(method, *args, &block)
      if result = http_response.parsed_response[camelize_name(method)]
        result
      else
        super
      end
    end
  end
end
