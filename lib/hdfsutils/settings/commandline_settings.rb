#
# Library: commandline_settings.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'optparse'

module HdfsUtils
  #
  # This class provides configuration information from the execution environment.
  #
  class CommandlineSettings
    public

    def initialize(settings)
      @settings = settings
    end

    #
    # Merge the environment settings into the settings structure
    #
    def merge(argv)
      setup
      parse(argv)
      validate
    end

    private

    LOG_LEVELS = [
      'debug',
      'info',
      'warn',
      'error',
      'fatal'
    ]

    def setup
      @options = OptionParser.new do |opts|
        opts.on('--log-level LEVEL',
                "Log level: #{LOG_LEVELS.join(', ')}") do |log_level|
          @settings.log_level = log_level
        end
      end
    end

    # Parse options and handle possible exceptions.
    def parse(argv)
      @options.parse!(argv)
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument
      puts "#{$!}\n\n"
      puts @options
      exit! 1
    end

    # Validate the settings.
    def validate
      unless LOG_LEVELS.include?(@settings.log_level.downcase)
        STDERR.puts "Invalid log_level (#{@settings.log_level}).  " \
                    "Valid values: #{LOG_LEVELS.join(', ')}\n\n"
        exit! 1
      end
    end
  end
end
