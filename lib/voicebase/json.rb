module VoiceBase
  class JSON
    include Enumerable

    class ParseError < StandardError; end

    class << self

      def parse(input, options = {})
        @debug = options.fetch(:debug, false)
        if input.is_a?(String)
          parse_string(input)
        elsif input.is_a?(::File)
          parse_file(input)
        else
          raise "Invalid input. Expected a String or File, got #{input.class.name}."
        end
      end

      private

      def parse_file(json_file)
        parse_string ::File.open(json_file, 'rb') { |f| json_file.read }
      end

      def parse_string(json_string_data)
        result = new

        json_hash_data = ::JSON.parse(json_string_data)
        raise ParseError, "Invalid format" unless json_hash_data.is_a?(Array)
        json_hash_data.each_with_index do |word_hash, index|
          word = Word.new(word_hash)
          result.words << word unless word.empty?

          %w(p c s e w).each do |field|
            if word.send(field).nil?
              word.error = "#{index}, Invalid formatting of #{field}, [#{word_hash[field]}]"
              $stderr.puts word.error if @debug
            end
          end
        end
        result
      end
    end

    attr_writer :words

    def initialize(word_array = nil)
      raise StandardError, "Must be initialized with words." if word_array.is_a?(Array) && !words.all? {|w| w.is_a?(VoiceBase::JSON::Word)}
      @words = word_array || []
    end

    def words
      @words ||= []
    end

    def errors
      @words.map {|w| w.error if w.error}.compact
    end

    def each(&block)
      @words.each {|word| block.call(word)}
    end

    def gt(start_time)
      VoiceBase::JSON.new(select {|w| w.start_time > start_time})
    end

    def gteq(start_time)
      VoiceBase::JSON.new(select {|w| w.start_time >= start_time})
    end

    def lt(start_time)
      VoiceBase::JSON.new(select {|w| w.start_time < start_time})
    end

    def lteq(start_time)
      VoiceBase::JSON.new(select {|w| w.start_time <= start_time})
    end

    def to_a
      @words
    end

    def to_json
      map {|w| w.to_hash}.to_json
    end
  end
end