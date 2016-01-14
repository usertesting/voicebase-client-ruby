require 'spec_helper'

describe VoiceBase::JSON do
  it "should parse string" do
    json = VoiceBase::JSON.parse(File.new(File.join(fixtures_root, "words.json")))
    expect(json.words.length).to eq(50)
  end
end
