module VoiceBase
  class Response
    include Helpers
    attr_accessor :http_response

    delegate :code, :body, :headers, :message, to: :http_response, allow_nil: true

    def initialize(http_response, api_version = "1.1")
      @http_response = http_response
      if api_version.to_f < 2
        self.extend(VoiceBase::V1::Response)
      else
        self.extend(VoiceBase::V2::Response)
      end
    end

    def ok?
      code && code >= 200 && code < 300
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
