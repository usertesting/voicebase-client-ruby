module VoiceBase
  class Client::Token
    attr_accessor :token, :created_at, :timeout

    def initialize(token, timeout = Float::INFINITY)
      raise VoiceBase::AuthenticationError, "Authentication token cannot be empty" unless token
      @token      = token
      @created_at = Time.now
      @timeout    = timeout
    end

    def expired?
      Time.now > created_at + (timeout / 1000.to_f)
    end

    def to_s
      @token
    end
  end
end
