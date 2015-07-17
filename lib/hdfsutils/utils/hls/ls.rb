#
# Utility: hls.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'utils/util'
require 'utils/hls/options'
require 'utils/hls/implementation'

module HdfsUtils
  #
  # This class runs the ls command for HDFS.
  # It is intended to provide a generic pattern for all utilities.
  #
  class Ls < Util
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
      @args.each do |path|
        ls(path)
      end
    rescue # never send a stack trace to the user (except when debugging)
      @settings.fatal.die(Fatal::BADRUN, $!)
    end

    private

    include Options # provides options that are specific to this utility
    include Implementation # implements this utility
  end
end
