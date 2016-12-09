describe VoiceBase::V1::Client do
  let(:client) { VoiceBase::Client.new }

  it "supports client actions" do
    expect(VoiceBase::V1::Client::ACTIONS).to eq(["uploadMedia", "getTranscript", "deleteFile", "getFileStatus"])
  end

  it "has a valid uri" do
    expect(client.uri).to eq("https://api.voicebase.com/services")
  end

  it "should initialize with token" do
    expect(client.api_version).to eq("1.1")
    expect(client.api_host).to eq("https://api.voicebase.com")
    expect(client.api_endpoint).to eq("/services")
    expect(client.debug).to eq(false)
    expect(client.user_agent).to eq("usertesting-client/#{VoiceBase::version}")
    expect(client.cookies).to eq(nil)
    expect(client.locale).to eq("en")
  end

  it "should init with debug" do
    client = VoiceBase::Client.new(debug: true)
    expect(client.debug).to be(true)
  end

  it "should upload media" do
    expect(client).to receive(:post).with({:action => "uploadMedia", "mediaURL" => "http://download.url.example/v0.mp4"})
    client.upload_media(media_url: "http://download.url.example/v0.mp4")
  end

  describe VoiceBase::Client::Token do
    let(:timeout) { 10 }
    let(:initial_time) { Time.local(2016, 5, 2, 16, 22, 0) }
    let(:expired_time) { Time.local(2016, 5, 2, 16, 22, timeout + 1) }

    before do
      Timecop.freeze(initial_time)
    end

    it "should create token instance" do
      token = VoiceBase::Client::Token.new("abcd-token", 1440)
      expect(token.token).to eq("abcd-token")
      expect(token.timeout).to eq(1440)
      expect(token.created_at).not_to eq(nil)
    end

    it "should not be expired?" do
      token = VoiceBase::Client::Token.new("unexpired-token", 2000)
      expect(token.expired?).to eq(false)
    end

    it "should be expired?" do
      token = VoiceBase::Client::Token.new("expired-token", timeout)
      Timecop.travel(expired_time)
      expect(token.expired?).to eq(true)
    end
  end
end
