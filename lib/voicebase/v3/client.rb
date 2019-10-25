module VoiceBase
  module V3
    module Client
      def self.extended(client, args = {})
        client.api_host     = client.args[:host] || ENV.fetch('VOICEBASE_V3_API_HOST', 'https://apis.voicebase.com')
        client.api_endpoint = client.args[:api_endpoint] || ENV.fetch('VOICEBASE_V3_API_ENDPOINT', '/v3')
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
        @token = VoiceBase::Client::Token.new(response.tokens.any? && response.tokens.first.fetch("token"))
      rescue NoMethodError => ex
        raise VoiceBase::AuthenticationError, response.status_message
      end

      def upload_media(args = {}, headers = {})
        require_media_file_or_url!(args)
        r = ::VoiceBase::Request::MultipartBuilder.new(headers: default_headers(headers))

        if args[:config]
          r.add(VoiceBase::Request::HashPart.new(name: "configuration", hash: args[:config]))
        end

        if args[:media_url]
          r.add(VoiceBase::Request::TextPart.new(name: "mediaUrl", body: args[:media_url]))
        end

        if args[:media_file]
          r.add(VoiceBase::Request::FilePart.new(name: "media", file: args[:media_file]))
        end

        #TODO: make metadata an object
        if args[:metadata]
          r.add(VoiceBase::Request::HashPart.new(name: "metadata", hash: args[:metadata]))
        end

        response = self.class.post(
            uri + '/media',
            headers: r.headers,
            body: r.body
        )
        VoiceBase::Response.new(response, api_version)
      end

      # I presume this method exists for parity with the V1 API however we are not using it
      def get_media(args = {}, headers = {})
        raise ArgumentError, "Missing argument :media_id" unless args[:media_id]
        url = if args[:media_id]
          uri + "/media/#{args[:media_id]}"
        elsif args[:external_id]
          uri + "/media?externalID=#{args[:external_id]}"
        else
          raise ArgumentError, "Missing argument :media_url or :media_file"
        end
        if args[:external_id]
          uri + "/media?externalID=#{args[:external_id]}"
        else
          raise ArgumentError, "Missing argument :external_id"
        end

        VoiceBase::Response.new(self.class.get(
          url, headers: default_headers(headers)
        ), api_version)
      end

      def get_json_transcript(args, headers)
        raise ArgumentError, "Missing argument :media_id" unless args[:media_id]
        url = uri + "/media/#{args[:media_id]}"

        response = self.class.get(
            url,
            headers: default_headers(headers)
        )

        VoiceBase::Response.new(response, api_version)
      end

      def get_text_transcript(args, headers)
        raise ArgumentError, "Missing argument :media_id" unless args[:media_id]
        url = uri + "/media/#{args[:media_id]}/transcripts/latest"

        headers.merge!({ 'Accept' => 'text/plain' })

        response = self.class.get(
            url,
            headers: default_headers(headers)
        )

        response.parsed_response
      end

      def get_transcript(args = {}, headers = {})
        if args[:format] == "txt"
          get_text_transcript(args, headers)
        else
          get_json_transcript(args, headers)
        end
      end

      # I presume this method exists for parity with the V1 API however we are not using it
      def get_media_progress(args = {}, headers = {})
        raise ArgumentError, "Missing argument :media_id" unless args[:media_id]
        VoiceBase::Response.new(self.class.get(
          uri + "/media/#{args[:media_id]}/progress",
          headers: default_headers(headers)
        ), api_version)
      end

      def delete_file(args = {}, headers = {})
        raise ArgumentError, "Missing argument :media_id" unless args[:media_id]
        url = uri + "/media/#{args[:media_id]}"

        response = self.class.delete(
            url,
            headers: default_headers(headers)
        )

        VoiceBase::Response.new(response, api_version)
      end

      private

      def blank?(value)
        value.nil? || value.empty?
      end

      def default_headers(headers = {})
        authenticate! unless token
        headers = {
            'Authorization' => "Bearer #{token.token}",
            'User-Agent' => user_agent
        }.reject { |k, v| blank?(v) }.merge(headers)
        puts "> headers\n> #{headers}" if debug
        headers
      end

      def require_media_file_or_url!(args = {})
        if args[:media_url].nil? && args[:media_file].nil?
          raise ArgumentError, "Missing argument :media_url or :media_file"
        end
      end
    end
  end
end
