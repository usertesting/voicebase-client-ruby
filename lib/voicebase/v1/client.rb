module VoiceBase
  module V1
    module Client
      include Helpers

      TOKEN_TIMEOUT_IN_MS = 1440
      PARAM_NORMALIZATION = {"Url" => "URL", "Id" => "ID", "Callback" => "CallBack"}
      ACTIONS             = ['uploadMedia', 'getTranscript', 'deleteFile', 'getFileStatus']

      def self.extended(client, args = {})
        client.api_host     = client.args[:api_host] || ENV.fetch('VOICEBASE_V1_API_HOST', 'https://api.voicebase.com')
        client.api_endpoint = client.args[:api_endpoint] || ENV.fetch('VOICEBASE_V1_API_ENDPOINT', '/services')
      end

      def authenticate!
        response = VoiceBase::Response.new(
          self.class.post(uri,
          query: {
            version: @api_version, apiKey: @auth_key,
            password: @auth_secret, action: 'getToken',
            timeout: TOKEN_TIMEOUT_IN_MS
          }), api_version)
        @token = Token.new(response.token, TOKEN_TIMEOUT_IN_MS)
      rescue NoMethodError => ex
        raise VoiceBase::AuthenticationError, response.status_message
      end

      # E.g. @client.upload_media media_url: "https://ut.aws.amazon.com/..."
      def method_missing(method, args, &block)
        if actions.include?(camelize_name(method)) && args.size > 0
          post camelize_keys(args).merge({action: camelize_name(method)})
        else
          super
        end
      end

      private

      def post(query_params, headers = {})
        query = default_query(query_params)

        puts "post #{uri} #{query.inspect}, #{default_headers(headers).inspect}" if debug
        VoiceBase::Response.new(self.class.post(uri,
          query: query, headers: default_headers(headers)), api_version)
      end

      def actions
        ACTIONS
      end

      def default_query(params = {})
        params = params.reverse_merge({version: @api_version,
          apiKey: @auth_key, password: @auth_secret,
          lang: locale})

        # authenticate using token or key/password?
        if token && !token.expired?
          params.merge!({token: token.token})
        else
          params.merge!({apiKey: @auth_key, password: @auth_secret})
        end

        params
      end

      def default_headers(headers = {})
        {'User-Agent' => @user_agent, 'Accept' => 'application/json',
          'Cookie' => @cookies}.reject {|k, v| v.blank?}.merge(headers)
      end

      def camelize_keys(params)
        params.inject({}) {|r, e| r[camelize_and_normalize_name(e.first)] = e.last; r }
      end

      # Parameters are camelized and normalized
      # according to VoiceBase API.
      #
      # E.g.
      #
      #  :media_url -> "mediaURL"
      #  :external_id -> "externalID"
      #  :error_callback -> "errorCallBack"
      #
      def camelize_and_normalize_name(snake_cased_name)
        result = Client.camelize_name(snake_cased_name.to_s)
        PARAM_NORMALIZATION.each {|k, v| result.gsub!(/#{k}/, v) }
        result
      end

    end
  end
end
