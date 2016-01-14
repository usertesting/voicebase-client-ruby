require 'spec_helper'

class VoiceBase::TestClass
  include VoiceBase::Helpers
end

describe VoiceBase::Helpers do

  context "class" do
    it "should camelize name" do
      expect(VoiceBase::TestClass.camelize_name("request_status")).to eq("requestStatus")
    end
  end

  it "should camelize name" do
    expect(VoiceBase::TestClass.new.camelize_name("request_status")).to eq("requestStatus")
  end

end