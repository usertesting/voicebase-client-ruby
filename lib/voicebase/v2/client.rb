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
        @token = VoiceBase::Client::Token.new(response.tokens.any? && response.tokens.first.fetch("token"))
      rescue NoMethodError => ex
        byebug
        raise VoiceBase::AuthenticationError, response.status_message
      end

      def upload_media(args = {}, headers = {})
        media_url = require_media_file_or_url(args)
        form_args = form_args(media_url, args[:language]) # language codes: en-US (default), en-UK, en-AU
        form_args.merge! metadata(args[:external_id]) if args[:external_id]

        response = self.class.post(
            uri + '/media',
            headers: multipart_headers(headers),
            body: multipart_query(form_args)
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

      def form_args(media_url, language = nil)
        args = {
          'media' => media_url,
          'configuration' => {
            'configuration' => {
              'executor' => 'v2'
            }
          }
        }
        args['configuration']['configuration'].merge!({'language' => language}) if language
        args
      end

      def metadata(external_id)
        {
          'metadata' => {
            'metadata' => {
              'external' => {
                'id' => "#{external_id}"
              }
            }
          }
        }
      end

      def blank?(value)
        value.nil? || value.empty?
      end

      def default_headers(headers = {})
        authenticate! unless token
        headers = {
          'User-Agent' => user_agent,
        }.tap {|o|
          o['Authorization'] = "Bearer #{token}" if token
        }.reject { |k, v| blank?(v) }.merge(headers)
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
