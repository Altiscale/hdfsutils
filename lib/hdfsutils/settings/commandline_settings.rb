#
# Library: commandline_settings.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'optparse'
require 'settings/parse_hdfs_uri'

module HdfsUtils
  #
  # This class provides configuration information from the
  # command line arguments.
  #
  class CommandlineSettings
    public

    def initialize(settings)
      @settings = settings
    end

    #
    # Merge the environment settings into the settings structure
    #
    def merge(argv, optsproc)
      setup(optsproc)
      parse(argv)
      validate
    end

    private

    LOG_LEVELS = %w(debug info warn error fatal)

    def setup(optsproc)
      @options = OptionParser.new do |opts|
        # set up options that are specific to the utility
        optsproc.call(opts, @settings) if optsproc

        # set up options that are generic for all utilities
        opts.on('--help', 'Show this help message.') do |_log_level|
          puts opts
          exit! 0
        end
        opts.on('--hdfsuri URI',
                'Location of the webhdfs service.') do |hdfsuri|
          uri = ParseHdfsURI.new.parse(hdfsuri)
          @settings[:host] = uri.host
          @settings[:port] = uri.port.to_s
          @settings[:user] = uri.userinfo
        end
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
      STDERR.puts "#{$!}\n\n"
      STDERR.puts @options
      exit! 1
    end

    # Validate the settings.
    def validate
      unless LOG_LEVELS.include?(@settings.log_level.downcase)
        STDERR.puts "Invalid log_level (#{@settings.log_level}).  " \
                    "Valid values: #{LOG_LEVELS.join(', ')}\n\n"
        STDERR.puts @options
        exit! 1
      end
    end
  end
end
