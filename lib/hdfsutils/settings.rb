#
# Library: settings.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'ostruct'
require 'logger'
require 'settings/system_settings'
require 'settings/environment_settings'
require 'settings/commandline_settings'

module HdfsUtils
  #
  # This class provides standard settings, including options
  # and environment parsing.
  #
  class Settings
    public

    def initialize(name)
      @name = name
      @settings = OpenStruct.new
      @settings.fatal = Fatal.new(name) # initialize as soon as possible
    end

    def run(argv, optsproc)
      # precedence order for settings (higher dominates lower)
      #   1. application defaults (built into this gem)
      #   2. system configuration files (e.g. Hadoop xml files)
      #   3. environment variables (typically set using the shell)
      #   4. command-line arguments
      defaults
      SystemSettings.new(@settings).merge
      EnvironmentSettings.new(@settings).merge
      CommandlineSettings.new(@settings).merge(argv, optsproc)

      init_logger
      @settings
    rescue
      @settings.fatal.die(Fatal::BADINIT, $!)
    end

    private

    def defaults
      @settings[:host] = 'localhost'
      @settings[:port] = '50070'
      @settings[:log_level] = 'Fatal'
    end

    # initialize logger
    def init_logger
      logger = Logger.new(STDERR)
      logger.level = Logger.const_get(@settings[:log_level].upcase)
      logger.progname = @name
      @settings[:logger] = logger
      @settings.fatal.logger = logger unless @settings[:log_level] == 'Fatal'
    end
  end
end
