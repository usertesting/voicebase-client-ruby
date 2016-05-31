require 'spec_helper'

describe VoiceBase::V2::Response do
  let(:v2_api) { '2.0' }

  context "methods dependent on returned HTTP response" do
    context "#success?" do
      let(:http_response_success) { double("http response", code: 200) }
      let(:http_response_error) { double("http response", code: 404) }

      it "is true in the case of a successful response" do
        response = VoiceBase::Response.new(http_response_success, v2_api)
        expect(response.success?).to be_truthy
      end

      it "is false in the case of an error" do
        response = VoiceBase::Response.new(http_response_error, v2_api)
        expect(response.success?).to be_falsey
      end
    end
  end

  context "methods based on returned JSON response" do
    context "#media_id" do
      let(:expected_media_id) { '123' }
      let(:parsed_response) { {'mediaId' => expected_media_id} }
      let(:http_response) { double("http response", code: 200, parsed_response: parsed_response) }

      it "returns the media ID from the parsed JSON response" do
        response = VoiceBase::Response.new(http_response, v2_api)
        expect(response.media_id).to eq(expected_media_id)
      end
    end

    context "#transcript_ready?" do
      let(:parsed_response_ready) { {'media' => { 'status' => 'finished'}} }
      let(:parsed_response_not_ready) { {'media' => { 'status' => 'started'}} }
      let(:http_response_ready) { double("http response", code: 200, parsed_response: parsed_response_ready) }
      let(:http_response_not_ready) { double("http response", code: 200, parsed_response: parsed_response_not_ready) }

      it "is true when the transcript is ready" do
        response = VoiceBase::Response.new(http_response_ready, v2_api)
        expect(response.transcript_ready?).to be_truthy
      end

      it "is false when the transcript is not ready" do
        response = VoiceBase::Response.new(http_response_not_ready, v2_api)
        expect(response.transcript_ready?).to be_falsey
      end
    end

    context "#transcript" do
      let(:transcipt) { 'transcript' }
      let(:parsed_response) { { 'media' => { 'transcripts' => { 'latest' => { 'words' => transcipt }}}}}
      let(:http_response) { double("http response", code: 200, parsed_response: parsed_response) }

      it "gets the transcript" do
        response = VoiceBase::Response.new(http_response, v2_api)
        expect(response.transcript).to eq(transcipt)
      end
    end
    
    context "#keywords" do
      let(:keywords) { 'keywords' }
      let(:parsed_response) { { 'media' => { 'transcripts' => { 'latest' => { 'keywords' => keywords }}}}}
      let(:http_response) { double("http response", code: 200, parsed_response: parsed_response) }

      it "gets the keywords" do
        response = VoiceBase::Response.new(http_response, v2_api)
        expect(response.keywords).to eq(keywords)
      end
    end
    
    context "#topics" do
      let(:topics) { 'topics' }
      let(:parsed_response) { { 'media' => { 'transcripts' => { 'latest' => { 'topics' => topics }}}}}
      let(:http_response) { double("http response", code: 200, parsed_response: parsed_response) }

      it "gets the transcript" do
        response = VoiceBase::Response.new(http_response, v2_api)
        expect(response.topics).to eq(topics)
      end
    end
  end
end
