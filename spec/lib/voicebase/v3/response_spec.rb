require "spec_helper"
require "json"

describe VoiceBase::Response do
  let(:subject) { described_class.new(http_response, "3") }
  let(:http_response) { double(:voice_response, parsed_response: json_body) }
  let(:raw_body) { File.open("spec/fixtures/v3/response_raw.txt").read }
  let(:json_body) { JSON.load(raw_body) }

  describe "#media_id" do
    it "is correct" do
      expect(subject.media_id).to eq "533f2c0e-ce17-41c3-a288-387da796490c"
    end
  end

  describe "#transcript_ready?" do
    context "when it's finished" do
      let(:json_body) {
        body = JSON.load(raw_body)
        body["status"] = "finished"
        body
      }

      it "is ready" do
        expect(subject.transcript_ready?).to be_truthy
      end
    end

    context "when it's running" do
      let(:json_body) {
        body = JSON.load(raw_body)
        body["status"] = "running"
        body
      }

      it "is not ready" do
        expect(subject.transcript_ready?).to be_falsey
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
  end

  describe "#topics" do
    it "is correct" do
      expect(subject.topics).to eq(json_body["knowledge"]["topics"])
    end
  end
end
