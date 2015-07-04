#
# Library: settings.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'ostruct'
require_relative 'settings/environment_settings'

module HdfsUtils
  #
  # This class provides standard settings, including options
  # and environment parsing.
  #
  class Settings
    public

    def initialize
      @settings = OpenStruct.new
    end

    def run(argv)
      # precedence order for settings (higher dominates lower)
      #   1. application defaults (built into this gem)
      #   2. system configuration files (e.g. Hadoop xml files)
      #   3. environment variables (typically set using the shell)
      #   4. command-line arguments
      EnvironmentSettings.new.merge(@settings)
      @settings
    end
  end
end
