module VoiceBase
  module V3
    module Client
      include VoiceBase::V2::Client

      def self.extended(client, args = {})
        client.api_host     = client.args[:host] || ENV.fetch('VOICEBASE_V3_API_HOST', 'https://apis.voicebase.com')
        client.api_endpoint = client.args[:api_endpoint] || ENV.fetch('VOICEBASE_V3_API_ENDPOINT', '/v3')
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

      private

      def require_media_file_or_url!(args = {})
        if args[:media_url].nil? && args[:media_file].nil?
          raise ArgumentError, "Missing argument :media_url or :media_file"
        end
      end
    end
  end
end
