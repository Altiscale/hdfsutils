#
# Utility: find.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'utils/util'
require 'utils/hfind/options'
require 'utils/hfind/implementation'

module HdfsUtils
  #
  # This class runs the find command for HDFS.
  # It is intended to provide a generic pattern for all utilities.
  #
  class Find < Util
    public

    #
    # Initialize the utility.
    #
    def initialize(name, argv)
      # Initialize superclass with arguments and options specialized
      # for this utility.
      super(name, argv, util_opts)
      @logger = @settings.logger
    rescue # never send a stack trace to the user (except when debugging)
      @settings.fatal.die(Fatal::BADINIT, $!)
    end

    #
    # Run the utility.
    #
    def run
      find
    rescue # never send a stack trace to the user (except when debugging)
      @settings.fatal.die(Fatal::BADRUN, $!)
    end

    private

    include FindOptions # provides options that are specific to find
    include FindImplementation # implements find
  end
end
