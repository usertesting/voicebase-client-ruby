module VoiceBase
  class Client
    attr_accessor :args
    attr_accessor :api_host
    attr_accessor :api_endpoint
    attr_accessor :api_version
    attr_accessor :debug
    attr_accessor :user_agent
    attr_accessor :cookies
    attr_accessor :locale
    attr_accessor :token

    # E.g. "request_status" -> "requestStatus"
    def self.camelize_name(snake_cased_name)
      snake_cased_name.to_s.camelize(:lower)
    end

    def initialize(args = {})
      @args                = args
      @api_version         = args[:api_version] || ENV.fetch('VOICEBASE_API_VERSION', '1.1')
      @auth_key            = args[:auth_key] || ENV['VOICEBASE_API_KEY']
      @auth_secret         = args[:auth_secret] || ENV['VOICEBASE_API_SECRET']
      @debug               = !!args[:debug]
      @user_agent          = args[:user_agent] || "usertesting-client/#{VoiceBase::version}"
      @locale              = args[:locale] || 'en'  # US English

      if @api_version.to_f < 2.0
        self.class.include(HTTMultiParty)
        self.extend(VoiceBase::V1::Client)
      else
        self.class.include(HTTParty)
        self.extend(VoiceBase::V2::Client)
      end
    end

    def uri
      @api_host + @api_endpoint
    end

  end
end
