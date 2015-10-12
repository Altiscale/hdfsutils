#
# Utility: hdmv.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'utils/util'
require 'utils/hdmv/options'
require 'utils/hdmv/implementation'

module HdfsUtils
  #
  # This class runs the ls command for HDFS.
  #
  class Mv < Util
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
      target = @args[-1]
      sources = @args[0..-2]
      mv(target, sources)
    rescue # never send a stack trace to the user (except when debugging)
      @settings.fatal.die(Fatal::BADRUN, $!)
    end

    private

    include MvOptions # provides options that are specific to ls
    include MvImplementation # implements ls
  end
end
