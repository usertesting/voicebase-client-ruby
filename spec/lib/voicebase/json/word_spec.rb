require 'spec_helper'

describe VoiceBase::JSON::Word do
  let(:word) { VoiceBase::JSON::Word.new({"p" => 1, "s" => 1610, "e" => 1780, "c" => 0.7, "w" => "This", "m" => "article"}) }

  it "should initialize attributes" do
    expect(word.sequence).to eq(1)
    expect(word.start_time).to eq(1610)
    expect(word.end_time).to eq(1780)
    expect(word.confidence).to eq(0.7)
    expect(word.word).to eq("This")
    expect(word.metadata).to eq("article")
  end

  it "aliases attribute getters" do
    expect(word.p).to eq(1)
    expect(word.s).to eq(1610)
    expect(word.e).to eq(1780)
    expect(word.c).to eq(0.7)
    expect(word.w).to eq("This")
    expect(word.m).to eq("article")
  end

  it "aliases attribute setters" do
    expect(word.p=(2)).to eq(2)
    expect(word.s=(4444)).to eq(4444)
    expect(word.e=(5555)).to eq(5555)
    expect(word.c=(0.5)).to eq(0.5)
    expect(word.w=("help")).to eq("help")
    expect(word.m=("punct")).to eq("punct")
  end

  it "#clone" do
    clone = word.clone
    expect(clone.object_id).not_to eq(word.object_id)
    expect(clone.sequence).to eq(word.sequence)
    expect(clone.start_time).to eq(word.start_time)
    expect(clone.end_time).to eq(word.end_time)
    expect(clone.confidence).to eq(word.confidence)
    expect(clone.word).to eq(word.word)
    expect(clone.metadata).to eq(word.metadata)
  end

  it "#empty?" do
    expect(word.empty?).to eq(false)
    expect(VoiceBase::JSON::Word.new.empty?).to eq(true)
    expect(VoiceBase::JSON::Word.new({"w" => "ok"}).empty?).to eq(false)
  end

  it "#to_json" do
    expect(word.to_json).to eq('{"p":1,"c":0.7,"s":1610,"e":1780,"w":"This"}')
  end

  context "#==" do
    it "should be equal" do
      expect(word == word).to eq(true)
    end

    it "should not be not equal" do
      expect(word != word).to eq(false)
    end

    it "should be equal with error" do
      clone = word.clone
      clone.error = "error"
      expect(clone == word).to eq(true)
    end

    it "should not be equal" do
      clone = word.clone
      clone.word = "That"
      expect(clone == word).to eq(false)
    end
  end
end
