module VoiceBase
  module Helpers
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
    end

    module ClassMethods

      # E.g. "request_status" -> "requestStatus"
      def camelize_name(snake_cased_name)
        snake_cased_name.to_s.camelize(:lower)
      end

    end

    module InstanceMethods

      def camelize_name(snake_cased_name)
        self.class.camelize_name(snake_cased_name)
      end

    end
  end
end
