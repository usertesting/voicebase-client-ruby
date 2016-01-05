module VoiceBase
  module V2
    module Client
      BOUNDARY               = "0123456789ABLEWASIEREISAWELBA9876543210"
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
    end
  end
end
