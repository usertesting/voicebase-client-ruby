require 'spec_helper'

describe VoiceBase::Response do
  context "#ok?" do
    let(:http_response_success) { double("http response", code: 200) }
    let(:http_response_error) { double("http response", code: 404) }

    it "is true in the case of a successful response" do
      response = VoiceBase::Response.new(http_response_success)
      expect(response.ok?).to be_truthy
    end

    it "is false in the case of an error" do
      response = VoiceBase::Response.new(http_response_error)
      expect(response.ok?).to be_falsey
    end
  end

  context "#method_missing" do
    let(:value) { 123 }
    let(:parsed_response) { { 'someValue' => value } }
    let(:http_response) { double("http response", parsed_response: parsed_response) }

    it "treats an expected value from the http parsed response as a method" do
      voicebase_response = VoiceBase::Response.new(http_response)
      expect( voicebase_response.some_value ).to eq(value)
    end
  end
end
