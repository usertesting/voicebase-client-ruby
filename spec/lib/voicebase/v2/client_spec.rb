require 'spec_helper'

describe VoiceBase::V2::Client do

  let(:voicebase_options) {{
      api_version: "2",
      auth_key: "key",
      auth_secret: "secret",
      user_agent: "testing"
  }}
  let(:client) { VoiceBase::Client.new(voicebase_options)}

  let(:token) { double("token", try: "asdf") }
  let(:token_array) { double("token array", try: token) }
  let(:tokens) { double("tokens", try: token_array) }
  let(:parsed_response) {{
      'status_message' => nil,
      'tokens' => tokens
  }}
  let(:http_response) { double("http response",  parsed_response: parsed_response) }

  before do

  end
  context "#authenticate!" do
    it "makes an API call to VoiceBase with the key & secret and processes a returned token" do

      url = "https://apis.voicebase.com/v2-beta/access/users/admin/tokens"
      httparty_options = {
          basic_auth:
              {
                  username: "key",
                  password: "secret"
              },
          headers:
              {
                  "User-Agent" => "testing",
                  "Accept" => "application/json"
              }
      }

      allow(VoiceBase::Client::Token).to receive(:new).with(token)

      expect(VoiceBase::Client).to receive(:get).with(url, httparty_options).and_return(http_response)
      client.authenticate!
    end
  end

  context "#upload_media" do
    let(:auth_token) { "My-Auth-Token" }

    before do
      client.token = double("voicebase token", token: auth_token)
    end

    it "makes an API call to VoiceBase to post the media file" do
      url = "https://apis.voicebase.com/v2-beta/media"

      headers = {
          "Authorization" => "Bearer My-Auth-Token",
          "User-Agent" => "testing",
          "Content-Type" => "multipart/form-data; boundary=0123456789ABLEWASIEREISAWELBA9876543210"
      }
      body = "--0123456789ABLEWASIEREISAWELBA9876543210\r\nContent-Disposition: form-data; name=\"media\"\r\n\r\nhttp://s3.com/video.mp4\r\n--0123456789ABLEWASIEREISAWELBA9876543210\r\nContent-Disposition: form-data; name=\"configuration\"\r\n\r\n{\"configuration\":{\"executor\":\"v2\"}}\r\n--0123456789ABLEWASIEREISAWELBA9876543210--"
      httparty_options = {
          headers: headers,
          body: body
      }

      media_url = "http://s3.com/video.mp4"
      allow(client).to receive(:authenticate!)
      allow(client).to receive(:require_media_file_or_url).and_return(media_url)

      expect(VoiceBase::Client).to receive(:post).with(url, httparty_options).and_return(http_response)
      client.upload_media({}, {})
    end
  end




  # def upload_media(args = {}, headers = {})
  #
  #   media_url = require_media_file_or_url(args)
  #
  #   form_args = {
  #       'media' => media_url,
  #       'configuration' => {
  #           'configuration' => {
  #               'executor' => 'v2'
  #           }
  #       }
  #   }
  #
  #   # external ID is only partially supported in the V2 API (can't get plain text transcripts or delete media)
  #   if args[:external_id]
  #     form_args.merge!({
  #                          'metadata' => {
  #                              'metadata' => {
  #                                  'external' => {
  #                                      'id' => "#{args[:external_id]}"
  #                                  }
  #                              }
  #                          }
  #                      })
  #   end
  #
  #   response = self.class.post(
  #       uri + '/media',
  #       headers: multipart_headers(headers),
  #       body: multipart_query(form_args)
  #   )
  #
  #   VoiceBase::Response.new(response, api_version)
  # end
  #













  # # I presume this method exists for parity with the V1 API however it is not used by the Orders app
  # def get_media(args = {}, headers = {})
  #   raise ArgumentError, "Missing argument :media_id" unless args[:media_id]
  #   url = if args[:media_id]
  #           uri + "/media/#{args[:media_id]}"
  #         elsif args[:external_id]
  #           uri + "/media?externalID=#{args[:external_id]}"
  #         else
  #           raise ArgumentError, "Missing argument :media_url or :media_file"
  #         end
  #   if args[:external_id]
  #     uri + "/media?externalID=#{args[:external_id]}"
  #   else
  #     raise ArgumentError, "Missing argument :external_id"
  #   end
  #
  #   VoiceBase::Response.new(self.class.get(
  #       url, headers: default_headers(headers)
  #   ), api_version)
  # end
  #












  # def get_json_transcript(args, headers)
  #   url = if args[:media_id]
  #           uri + "/media/#{args[:media_id]}"
  #         else
  #           raise ArgumentError, "Missing argument :media_id"
  #         end
  #
  #   response = self.class.get(
  #       url,
  #       headers: default_headers(headers)
  #   )
  #
  #   VoiceBase::Response.new(response, api_version)
  # end
  #














  # def get_text_transcript(args, headers)
  #   url = if args[:media_id]
  #           uri + "/media/#{args[:media_id]}/transcripts/latest"
  #         else
  #           raise ArgumentError, "Missing argument :media_id"
  #         end
  #
  #   headers.merge!({ 'Accept' => 'text/plain' })
  #
  #   response = self.class.get(
  #       url,
  #       headers: default_headers(headers)
  #   )
  #
  #   response.parsed_response
  # end
  #










  # def get_transcript(args = {}, headers = {})
  #   if args[:format] == "txt"
  #     get_text_transcript(args, headers)
  #   else
  #     get_json_transcript(args, headers)
  #   end
  # end
  #















  # # is this used?
  # def get_media_progress(args = {}, headers = {})
  #   raise ArgumentError, "Missing argument :media_id" unless args[:media_id]
  #   VoiceBase::Response.new(self.class.get(
  #       uri + "/media/#{args[:media_id]}/progress",
  #       headers: default_headers(headers)
  #   ), api_version)
  # end
  #











  # def delete_file(args = {}, headers = {})
  #   url = if args[:media_id]
  #           uri + "/media/#{args[:media_id]}"
  #         else
  #           raise ArgumentError, "Missing argument :media_id"
  #         end
  #
  #   response = self.class.delete(
  #       url,
  #       headers: default_headers(headers)
  #   )
  #
  #   VoiceBase::Response.new(response, api_version)
  # end





end
