require "spec_helper"

describe VoiceBase::V3::Client do
  let(:client) { VoiceBase::Client.new(api_version: "3", auth_key: "auth_key", auth_secret: "secret") }

  describe "#authenticate!" do
    let(:token_response) { double(:response, tokens: [ { "token" => "foo" } ]) }

    before do
      allow(VoiceBase::Response).to receive(:new).and_return(token_response)
      allow(VoiceBase::Client).to receive(:get)
    end

    it "gets authentication token" do
      expect(VoiceBase::Client).to receive(:get).with(
        "https://apis.voicebase.com/v3/access/users/admin/tokens",
        basic_auth: { username: "auth_key", password: "secret" },
        headers: {
          "User-Agent"   => "usertesting-client/1.3.0",
          "Accept"       => "application/json"
        }
      )
      client.authenticate!
    end
  end

  describe "#upload_media" do
    let(:token_response) { double(:response, tokens: [ { "token" => "foo" } ]) }
    let(:file_stream) { double(:io, path: "foo/bar.mp4", read: "foobar") }

    before do
      allow(VoiceBase::Client).to receive(:post)
      allow(VoiceBase::Response).to receive(:new).and_return(token_response)
      allow(VoiceBase::Client).to receive(:get)
    end

    context "when uploading a file" do
      it "sends multipart request to voicebase" do
        expect(VoiceBase::Client).to receive(:post).with("https://apis.voicebase.com/v3/media",
          headers:  {
            "Authorization"=>"Bearer foo",
            "Content-Type"=>
              "multipart/form-data; boundary=0123456789ABLEWASIEREISAWELBA9876543210",
              "User-Agent"=>"usertesting-client/1.3.0"
          },
          body: <<-BODY.strip.gsub("\n", "\r\n")
--0123456789ABLEWASIEREISAWELBA9876543210
Content-Disposition: form-data; name=\"configuration\"

{\"speechModel\":{\"language\":\"en-US\",\"extensions\":[\"usertesting\"],\"features\":[\"advancedPunctuation\"]},\"knowledge\":{\"enableDiscovery\":true,\"enableExternalDataSources\":false}}
--0123456789ABLEWASIEREISAWELBA9876543210
Content-Disposition: form-data; name=\"media\"; filename=\"bar.mp4\"
Content-Type: application/mp4

foobar

--0123456789ABLEWASIEREISAWELBA9876543210--
BODY
        )
        client.upload_media(media_file: file_stream)
      end
    end

    context "when uploading a file path" do
      it "sends multipart request to voicebase" do
        expect(VoiceBase::Client).to receive(:post).with("https://apis.voicebase.com/v3/media",
          headers:  {
            "Authorization"=>"Bearer foo",
            "Content-Type"=>
              "multipart/form-data; boundary=0123456789ABLEWASIEREISAWELBA9876543210",
              "User-Agent"=>"usertesting-client/1.3.0"
          },
          body: <<-BODY.strip.gsub("\n", "\r\n")
--0123456789ABLEWASIEREISAWELBA9876543210
Content-Disposition: form-data; name=\"configuration\"

{\"speechModel\":{\"language\":\"en-US\",\"extensions\":[\"usertesting\"],\"features\":[\"advancedPunctuation\"]},\"knowledge\":{\"enableDiscovery\":true,\"enableExternalDataSources\":false}}
--0123456789ABLEWASIEREISAWELBA9876543210
Content-Disposition: form-data; name=\"mediaUrl\"

https:://s3.amazon.com/audio.m4a
--0123456789ABLEWASIEREISAWELBA9876543210--
BODY
        )
        client.upload_media(media_url: "https:://s3.amazon.com/audio.m4a")
      end
    end

    context "when media is specified" do
      it "raises an error" do
        expect {
          client.upload_media()
        }.to raise_error(VoiceBase::ArgumentError)
      end
    end
  end
end
