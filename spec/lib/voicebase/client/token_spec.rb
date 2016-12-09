require 'spec_helper'
require 'timecop'

describe VoiceBase::Client::Token do
  context "#expired?" do
    let(:timeout) { 10 }
    let(:initial_time) { Time.local(2016, 5, 2, 16, 22, 0) }
    let(:non_expired_time) { Time.local(2016, 5, 2, 16, 22, timeout-1) }
    let(:expired_time) { Time.local(2016, 5, 2, 16, 22, timeout+1) }
    let(:some_token) { 'token' }

    before do
      Timecop.freeze(initial_time)
    end

    it "is false when the timeout period has not expired" do
      token = VoiceBase::Client::Token.new(some_token, timeout)
      Timecop.travel(non_expired_time)
      expect(token.expired?).to be_truthy
    end

    it "is true when the timeout period has expired" do
      token = VoiceBase::Client::Token.new(some_token, timeout)
      Timecop.travel(expired_time)
      expect(token.expired?).to be_truthy
    end

    it "delegates token method to_s" do
      expect(VoiceBase::Client::Token.new("foobar").to_s).to eq("foobar")
    end
  end
end
