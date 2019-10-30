require 'spec_helper'

describe VoiceBase::Client do
  context ".camelize_name" do
    it "changes snake_cased_terms to be lowerCamelCasedTerms" do
      expect(VoiceBase::Client.camelize_name("i_love_transcripts")).to eq("iLoveTranscripts")
    end
  end

  context "when the api version is not supported" do
    it "raises an error" do
      expect {
        described_class.new(api_version: "9999")
      }.to raise_error(VoiceBase::UnknownApiVersionError)
    end
  end
end
