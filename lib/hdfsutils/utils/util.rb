#
# Library: util.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'settings'
require 'webhdfs/webhdfs_client'
require 'highline/import'

module HdfsUtils
  #
  # Superclass for all utilities.
  #
  class Util
    public

    #
    # Initializes the top-level utility class.
    # name     = [String] Name of the utility.
    # argv     = [String] Command-line argument array.
    # optsproc = [lambda] Options configuration injected by the utility.
    #
    def initialize(name, argv, optsproc = nil)
      @name = name
      @args = argv
      @settings = Settings.new(@name).run(argv, optsproc)
      @args = argv
      @client = WebhdfsClient.new(@settings).start
    end

    #
    # Abstract interface.  Every subclass must implement the run function.
    #
    def run
      fail 'Subclass of Util must override Util::run'
    end

    #
    # Useful operations common between utilities
    #
    def stat?(path)
      stat = nil
      begin
        stat = @client.stat(path)
      # rubocop:disable Lint/HandleExceptions
      rescue WebHDFS::FileNotFoundError
        # fall through, leave stat == nil
      end
      # rubocop:enable Lint/HandleExceptions
      stat
    end

    def list?(path)
      files = nil
      begin
        files = @client.list(path)
          # rubocop:disable Lint/HandleExceptions
        rescue WebHDFS::FileNotFoundError
          raise "ERROR: #{path} does not exist"
      end
      files
    end

    #
    # return: 'y' or 'n'
    #
    def ask?(question)
      answer = 'n'
      if agree("#{question} (y/n) ")
        answer = 'y'
      end
      answer
    end
  end
end
