module VoiceBase
  class JSON::Word
    attr_accessor :sequence
    attr_accessor :start_time
    attr_accessor :end_time
    attr_accessor :confidence
    attr_writer :word
    attr_accessor :error

    alias_method :p, :sequence
    alias_method :p=, :sequence=
    alias_method :c, :confidence
    alias_method :c=, :confidence=
    alias_method :s, :start_time
    alias_method :s=, :start_time=
    alias_method :e, :end_time
    alias_method :e=, :end_time=
    alias_method :w, :word
    alias_method :w=, :word=

    def initialize(options={})
      options.each do |k,v|
        self.send("#{k}=",v)
      end
    end

    def clone
      clone = Word.new
      clone.sequence   = sequence
      clone.start_time = start_time
      clone.end_time   = end_time
      clone.confidence = confidence
      clone.error      = error
      clone.word       = word
      clone
    end

    def empty?
      sequence.nil? && start_time.nil? && end_time.nil? && word.empty?
    end

    def to_json
      {p: sequence, c: confidence, s: start_time, e: end_time, w: word}.to_json
    end
  end
end