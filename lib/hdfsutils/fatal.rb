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
    BADASSERT = 4 # assertion failure in the code (typically a bug)

    INTERRUPT = 200 # program was interrupted by the user

    BADRUN = -1 # uncaught exception while running

    attr_accessor :logger

    def initialize(name)
      @name = name
      @logger = nil

      # register to handle interrupt signal (typically from control-c)
      trap 'SIGINT' do
        STDERR.puts "\n#{@name}: Interrupted"
        exit! INTERRUPT
      end
    end

    def die(exitcode, exception)
      printable = to_printable(exception)
      unless @logger # print to STDERR and exit immediately
        STDERR.puts @name + ': ' + printable
        exit! exitcode
      end

      # print at the appropriate logger level and exit immediately
      if @logger.debug?
        @logger.debug printable
      else
        @logger.fatal printable
      end
      exit! exitcode
    end

    private

    def to_printable(exception)
      if @logger && @logger.debug?
        exception
      elsif exception.is_a? WebHDFS::ServerError
        # This exception is accompanied by a HTML blob
        # that needs to be parsed and summarized.  In the
        # meantime, summarize generically as follows...
        'WebHDFS Server Error. ' \
        'Run with --log-level debug for more information.'
      elsif exception.message.length > 80
        # Other message that seems too long to display.
        exception.message[0, 59] + "...\n" +
        '(Run with --log-level debug for more information.)'
      else
        exception.message
      end
    end
  end
end
