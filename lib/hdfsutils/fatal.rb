#
# Library: fatal.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'logger'

module HdfsUtils
  #
  # Standard fatal error handler for all utilities.
  #
  class Fatal
    public

    # All exit codes for all utilities must be standardized by this list.
    BADARGS = 1 # incorrect command-line arguments
    BADENV = 2 # incorrect environment variables
    BADINIT = 3 # uncaught exception in initialization
    BADRUN = -1 # uncaught exception while running

    attr_accessor :logger

    def initialize
      @logger = nil
    end

    def die(exitcode, exception)
      if @logger
        if @logger.level == Logger::DEBUG
          @logger.debug exception
        else
          @logger.fatal exception.message
        end
      else
        STDERR.puts exception
      end
      exit! exitcode
    end
  end
end