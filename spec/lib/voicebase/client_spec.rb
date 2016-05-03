require 'spec_helper'

describe VoiceBase::Client do
  context ".camelize_name" do
    it "changes snake_cased_terms to be lowerCamelCasedTerms" do
      expect(VoiceBase::Client.camelize_name("i_love_transcripts")).to eq("iLoveTranscripts")
    end
  end
end
