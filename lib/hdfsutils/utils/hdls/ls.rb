#
# Utility: hdls.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'utils/util'
require 'utils/hdls/options'
require 'utils/hdls/implementation'

module HdfsUtils
  #
  # This class runs the ls command for HDFS.
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

    include LsOptions # provides options that are specific to ls
    include LsImplementation # implements ls
  end
end
