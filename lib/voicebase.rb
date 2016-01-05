require 'json'
require 'uri'
require 'httparty'
require 'active_support/core_ext/module'

require "voicebase/version"
require "voicebase/helpers"

module VoiceBase

  class AuthenticationError < StandardError; end
  class ArgumentError < StandardError; end

  module V1
    module Client
      include Helpers

      TOKEN_TIMEOUT_IN_MS = 1440
      PARAM_NORMALIZATION = {"Url" => "URL", "Id" => "ID", "Callback" => "CallBack"}
      ACTIONS             = ['uploadMedia', 'getTranscript', 'deleteFile']

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

    module Response
      def self.extended(response)
      end

      def success?
        ok? &&  request_status == "SUCCESS"
      end

    end
  end

  module V2
    module Client
      BOUNDARY     = "0123456789ABLEWASIEREISAWELBA9876543210"
      MULTIPART_CONTENT_TYPE = "multipart/form-data; boundary=#{BOUNDARY}"

      def self.extended(client, args = {})
        client.api_host     = client.args[:host] || ENV.fetch('VOICEBASE_V2_API_HOST', 'https://apis.voicebase.com')
        client.api_endpoint = client.args[:api_endpoint] || ENV.fetch('VOICEBASE_V2_API_ENDPOINT', '/v2-beta')
      end

      def authenticate!
        auth = {:username => @auth_key, :password => @auth_secret}
        response = VoiceBase::Response.new(
          self.class.get(
            uri + '/access/users/admin/tokens',
            basic_auth: auth,
            headers: {
              'User-Agent'   => @user_agent,
              'Accept'       => 'application/json'
            }
          ), api_version)
        @token = VoiceBase::Client::Token.new(response.tokens.try(:first).try(:[], 'token'))
      rescue NoMethodError => ex
        raise VoiceBase::AuthenticationError, response.status_message
      end

      def upload_media(args = {})
        body = if args[:media_url]
          multipart_query({'media': args[:media_url]})
        elsif args[:media_file]
          multipart_query({'media': File.open(args[:media_file])})
        else
          raise ArgumentError, "Specify either :media_url or :media_file"
        end
        VoiceBase::Response.new(self.class.post(
          uri + '/media',
          headers: multipart_headers,
          body: body
        ), api_version)
      end

      def get_transcript(args = {})
        VoiceBase::Response.new(self.class.get(
          uri + "/media/#{args[:media_id]}/transcripts",
          headers: default_headers
        ), api_version)
      end

      private

      def default_headers(headers = {})
        authenticate! unless token
        {'Authorization' => "Bearer #{token.token}",
          'User-Agent'   => user_agent}.reject {|k, v| v.blank?}.merge(headers)
      end

      def multipart_headers(headers = {})
        default_headers({ 'Content-Type' => MULTIPART_CONTENT_TYPE })
      end

      def multipart_query(params)
        fp = []

        params.each do |k, v|
          if v.respond_to?(:path) and v.respond_to?(:read) then
            fp.push(FileParam.new(k, v.path, v.read))
          else
            fp.push(StringParam.new(k, v))
          end
        end

        query = fp.map {|p| "--" + BOUNDARY + "\r\n" + p.to_multipart }.join("") + "--" + BOUNDARY + "--"
        query
      end

      class StringParam
        attr_accessor :k, :v

        def initialize(k, v)
          @k, @v = k, v
        end

        def to_multipart
          return "Content-Disposition: form-data; name=\"#{CGI::escape(k.to_s)}\"\r\n\r\n#{v}\r\n"
        end
      end

      # Formats the contents of a file or string for inclusion with a multipart
      # form post
      class FileParam
        attr_accessor :k, :filename, :content

        def initialize(k, filename, content)
          @k, @filename, @content = k, filename, content
        end

        def to_multipart
          # If we can tell the possible mime-type from the filename, use the
          # first in the list; otherwise, use "application/octet-stream"
          mime_type = MIME::Types.type_for(filename)[0] || MIME::Types["application/octet-stream"][0]
          return "Content-Disposition: form-data; name=\"#{CGI::escape(k.to_s)}\"; filename=\"#{ filename }\"\r\n" +
            "Content-Type: #{ mime_type.simplified }\r\n\r\n#{ content }\r\n"
        end
      end
    end # module Client

    module Response
    end
  end

  class Client
    include HTTParty

    attr_accessor :args
    attr_accessor :api_host
    attr_accessor :api_endpoint
    attr_accessor :api_version
    attr_accessor :debug
    attr_accessor :user_agent
    attr_accessor :cookies
    attr_accessor :locale
    attr_accessor :token

    class Token
      attr_accessor :token, :created_at, :timeout

      def initialize(token, timeout = Float::INFINITY)
        raise VoiceBase::AuthenticationError, "Authentication token cannot be empty" unless token
        @token      = token
        @created_at = Time.now
        @timeout    = timeout
      end

      def expired?
        Time.now > created_at + (timeout / 1000.to_f)
      end
    end

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
        self.extend(VoiceBase::V1::Client)
      else
        self.extend(VoiceBase::V2::Client)
      end
    end

    def uri
      @api_host + @api_endpoint
    end

  end

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
