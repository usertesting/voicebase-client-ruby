require "spec_helper"
require "json"

describe VoiceBase::Response do
  let(:subject) { described_class.new(http_response, version) }
  let(:version) { "3" }
  let(:http_response) { double(:voice_response, parsed_response: json_body) }
  let(:raw_body) { File.open("spec/fixtures/v3/response_raw.txt").read }
  let(:json_body) { JSON.load(raw_body) }

  context "when the version is not supported" do
    let(:version) { "9999" }
    it "raises an error" do
      expect {
        subject
      }.to raise_error(VoiceBase::UnknownApiVersionError)
    end
  end

  describe "#media_id" do
    it "is correct" do
      expect(subject.media_id).to eq "533f2c0e-ce17-41c3-a288-387da796490c"
    end
  end

  describe "#transcript_ready?" do
    it "is correct" do
      [
        { status: "running", ready?: false },
        { status: "finished", ready?: true }
      ].each do |scenario|
        http_response = double(:voice_response, parsed_response: { "status" => scenario[:status] }, code: 200)
        expect(described_class.new(http_response, version).transcript_ready?).to be(scenario[:ready?])
      end
    end
  end

  describe "#transcript" do
    it "is correct" do
      expect(subject.transcript).to eq(json_body["transcript"]["words"])
    end
  end

  describe "#keywords" do
    it "is correct" do
      expect(subject.keywords).to eq(json_body["knowledge"]["keywords"])
    end

    context "when keywords are not in the response" do
      it "return nil" do
        json_body["knowledge"] = nil
        expect(subject.keywords).to be_nil
      end
    end
  end

  describe "#topics" do
    it "is correct" do
      expect(subject.topics).to eq(json_body["knowledge"]["topics"])
    end

    context "when topics are not in the response" do
      it "return nil" do
        json_body["knowledge"] = nil
        expect(subject.topics).to be_nil
      end
    end
  end
end
