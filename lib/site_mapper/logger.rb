module SiteMapper
  # Handles logging
  class Logger
    # @param [Symbol] type of logger class to be used
    def self.use_logger_type(type)
      fail 'Logger already set' if defined?(@@log)
      @@log = case type.to_s
      when 'nil', 'default'
        NilLogger
      when 'system'
        SystemOutLogger
      else
        fail ArgumentError, "Unknown logger type: '#{type}'"
      end
      @@log
    end

    # @param [Class, #log, #err_log] logger a logger class
    def self.use_logger(logger)
      fail 'Logger already set' if defined?(@@log)
      @@log = logger
    end

    # @param [String] msg to be logged
    def self.log(msg)
      @@log ||= use_logger_type(:default)
      @@log.log(msg)
    end

    # @param [String] err_msg to be logged
    def self.err_log(err_msg)
      @@log ||= use_logger_type(:default)
      @@log.err_log(err_msg)
    end

    # Log to terminal.
    module SystemOutLogger
      # @param [String] msg to be logged to STDOUT
      def self.log(msg)
        STDOUT.puts(msg)
      end

      # @param [String] msg to be logged to STDERR
      def self.err_log(msg)
        STDERR.puts("[ERROR] #{msg}")
      end
    end

    # Don't log
    module NilLogger
      # @param [String] msg to be ignored
      def self.log(msg);end
      # @param [String] msg to be ignored
      def self.err_log(msg);end
    end
  end
end
