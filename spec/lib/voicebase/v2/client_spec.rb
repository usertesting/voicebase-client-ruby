require 'spec_helper'

describe VoiceBase::V2::Client do
  let(:voicebase_options) { {
      api_version: "2",
      auth_key: "key",
      auth_secret: "secret",
      user_agent: "testing"
  } }
  let(:client) { VoiceBase::Client.new(voicebase_options) }

  let(:token) { "asdf" }
  let(:tokens) { [ { "token" => token } ] }
  let(:parsed_response) { {
      'status_message' => nil,
      'tokens' => tokens
  } }
  let(:http_response) { double("http response", parsed_response: parsed_response) }

  let(:auth_token) { "My-Auth-Token" }

  before do
    client.token = double("voicebase token", token: auth_token, to_s: auth_token)
  end

  context "pre-authentication" do
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
  end

  context "post-authentication" do
    let(:media_id) { "some-media-id" }
    let(:voicebase_args) { {
        media_id: media_id
    } }

    let(:headers) { {
        "Authorization" => "Bearer My-Auth-Token",
        "User-Agent" => "testing"
    } }
    let(:httparty_options) {{ headers: @request_headers }}

    before do
      @request_headers = headers
      allow(VoiceBase::Response).to receive(:new).and_return("response")
    end

    context "#upload_media" do
      let(:url) { "https://apis.voicebase.com/v2-beta/media" }
      let(:media_url) { "http://s3.com/video.mp4" }

      before do
        @request_headers.merge!({"Content-Type" => "multipart/form-data; boundary=0123456789ABLEWASIEREISAWELBA9876543210"})
        allow(client).to receive(:require_media_file_or_url).and_return(media_url)
      end

      it "makes an API call to VoiceBase to post the media file" do
        body = "--0123456789ABLEWASIEREISAWELBA9876543210\r\nContent-Disposition: form-data; name=\"media\"\r\n\r\nhttp://s3.com/video.mp4\r\n--0123456789ABLEWASIEREISAWELBA9876543210\r\nContent-Disposition: form-data; name=\"configuration\"\r\n\r\n{\"configuration\":{\"executor\":\"v2\"}}\r\n--0123456789ABLEWASIEREISAWELBA9876543210--"
        httparty_options.merge!({body: body})
        expect(VoiceBase::Client).to receive(:post).with(url, httparty_options).and_return(http_response)
        client.upload_media({}, {})
      end

      it "adds the engine language code if specified" do
        body = "--0123456789ABLEWASIEREISAWELBA9876543210\r\nContent-Disposition: form-data; name=\"media\"\r\n\r\nhttp://s3.com/video.mp4\r\n--0123456789ABLEWASIEREISAWELBA9876543210\r\nContent-Disposition: form-data; name=\"configuration\"\r\n\r\n{\"configuration\":{\"executor\":\"v2\",\"language\":\"en-UK\"}}\r\n--0123456789ABLEWASIEREISAWELBA9876543210--"
        httparty_options.merge!({body: body})
        expect(VoiceBase::Client).to receive(:post).with(url, httparty_options).and_return(http_response)
        client.upload_media({language: 'en-UK'}, {})
      end
    end

    context "#get_media" do
      # add this spec if this method gets used
    end

    context "#get_json_transcript" do
      it "makes an API call to VoiceBase to retrieve the transcript results" do
        url = "https://apis.voicebase.com/v2-beta/media/#{media_id}"
        expect(VoiceBase::Client).to receive(:get).with(url, httparty_options).and_return(http_response)
        client.get_json_transcript(voicebase_args, {})
      end
    end

    context "#get_json_transcript" do
      it "makes an API call to VoiceBase to retrieve the JSON transcript results" do
        url = "https://apis.voicebase.com/v2-beta/media/#{media_id}"
        expect(VoiceBase::Client).to receive(:get).with(url, httparty_options).and_return(http_response)
        client.get_json_transcript(voicebase_args, {})
      end
    end

    context "#get_text_transcript" do
      it "makes an API call to VoiceBase to retrieve the plain text transcript results" do
        url = "https://apis.voicebase.com/v2-beta/media/#{media_id}/transcripts/latest"
        @request_headers.merge!({"Accept" => "text/plain"})
        expect(VoiceBase::Client).to receive(:get).with(url, httparty_options).and_return(http_response)
        client.get_text_transcript(voicebase_args, {})
      end
    end

    context "#get_media_progress" do
      # add this spec if this method gets used
    end

    context "#delete_file" do
      it "makes an API call to VoiceBase to delete the media" do
        url = "https://apis.voicebase.com/v2-beta/media/#{media_id}"
        expect(VoiceBase::Client).to receive(:delete).with(url, httparty_options).and_return(http_response)
        client.delete_file(voicebase_args, {})
      end
    end
  end
end
