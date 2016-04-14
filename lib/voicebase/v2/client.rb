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

      def upload_media(args = {}, headers = {})
        form_args = {
            'media' => require_media_file_or_url(args),
            'configuration' => {
                'configuration' => {
                    'executor' => 'v2'
                }
            }
        }

        if args[:external_id]
          form_args.merge!({
                               'metadata' => {
                                   'metadata' => {
                                       'external' => {
                                           'id' => "#{args[:external_id]}"
                                       }
                                   }
                               }
                           })
        end

        response = self.class.post(
            uri + '/media',
            headers: multipart_headers(headers),
            body: multipart_query(form_args)
        )

        VoiceBase::Response.new(response, api_version)
      end

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

      def get_transcript(args = {}, headers = {})

        #todo as of 4/12/16 the VoiceBase V2 API doesn't support retrieving plain text transcripts using
        # external IDs, so a different method will be needed to get them. Namely, save the VoiceBase
        # media ID from the JSON reqeust response, and use it to make another request for the text.

        url = uri + "/media/?externalId=#{args[:external_id]}"

        response = self.class.get(
            url,
            headers: default_headers(headers)
        )

        VoiceBase::Response.new(response, api_version)
      end

      def get_media_progress(args = {}, headers = {})
        raise ArgumentError, "Missing argument :media_id" unless args[:media_id]
        VoiceBase::Response.new(self.class.get(
          uri + "/media/#{args[:media_id]}/progress",
          headers: default_headers(headers)
        ), api_version)
      end

      def delete_file(args = {}, headers = {})

        #todo https://apis.voicebase.com/console/#/documentation#media_mediaId

      end

      private

      def default_headers(headers = {})
        authenticate! unless token
        headers = {'Authorization' => "Bearer #{token.token}",
          'User-Agent' => user_agent}.reject {|k, v| v.blank?}.merge(headers)
        puts "> headers\n> #{headers}" if debug
        headers
      end

      def multipart_headers(headers = {})
        default_headers(headers.merge({'Content-Type' => MULTIPART_CONTENT_TYPE}))
      end

      def multipart_query(params)
        fp = []

        params.each do |k, v|
          if v.respond_to?(:path) and v.respond_to?(:read) then
            fp.push(FileParam.new(k, v.path, v.read))
          elsif v.is_a?(Hash)
            fp.push(HashParam.new(k, v))
          else
            fp.push(StringParam.new(k, v))
          end
        end

        query = fp.map {|p| "--" + BOUNDARY + "\r\n" + p.to_multipart }.join("") + "--" + BOUNDARY + "--"
        puts "> multipart-query\n> #{query}" if debug
        query
      end

      def require_media_file_or_url(args = {})
        media = if args[:media_url]
          args[:media_url]
        elsif args[:media_file]
          args[:media_file]
        else
          raise ArgumentError, "Missing argument :media_url or :media_file"
        end
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

      class HashParam
        attr_accessor :k, :v

        def initialize(k, v)
          @k, @v = k, v
        end

        def to_multipart
          return "Content-Disposition: form-data; name=\"#{CGI::escape(k.to_s)}\"\r\n\r\n#{v.to_json}\r\n"
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
