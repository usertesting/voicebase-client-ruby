require 'spec_helper'

describe VoiceBase::V1::Response do
  context "#success?" do
    let(:parsed_response_success) { {'requestStatus' => "SUCCESS"} }
    let(:parsed_response_failure) { {'requestStatus' => "FAILURE"} }
    let(:parsed_response_error) { {'requestStatus' => "n/a"} }
    let(:http_response_success) { double("http response", code: 200, parsed_response: parsed_response_success) }
    let(:http_response_failure) { double("http response", code: 200, parsed_response: parsed_response_failure) }
    let(:http_response_error) { double("http response", code: 403, parsed_response: parsed_response_error) }

    it "is true in the case of a successful response" do
      response = VoiceBase::Response.new(http_response_success)
      expect(response.success?).to be_truthy
    end

    it "is false in the case of a failure response" do
      response = VoiceBase::Response.new(http_response_failure)
      expect(response.success?).to be_falsey
    end

    it "is false in the case of an error" do
      response = VoiceBase::Response.new(http_response_error)
      expect(response.success?).to be_falsey
    end
  end

end
