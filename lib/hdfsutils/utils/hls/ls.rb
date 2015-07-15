#
# Utility: hls.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'utils/util' # superclass for all utilities
require 'fatal' # standardizes exit codes
require 'output/output_stat' # prints file stat structure

module HdfsUtils
  #
  # This class runs the ls command for HDFS.
  #
  class Ls < Util
    public

    def initialize(name, argv)
      # Initialize superclass with arguments and options specialized
      # for this utility.
      super(name, argv, util_opts)
      # initialize stat printer, if necessary
      @sp = @settings.long_format ? OutputStat.new(@settings) : nil
    rescue # never send a stack trace to the user (except when debugging)
      @settings.fatal.die(Fatal::BADINIT, $!)
    end

    def run
      @args.each do |path|
        ls(path)
      end
    rescue # never send a stack trace to the user (except when debugging)
      @settings.fatal.die(Fatal::BADRUN, $!)
    end

    private

    #
    # This procedure provides options that are specific to ls.
    #
    def util_opts
      lambda do |opts, settings|
        opts.banner = "Usage: #{@name} [options] [file ...]"
        opts.on('-d',
                'Directories are listed as plain files ' \
                '(not searched recursively).') do
          settings.dir_plain = true
        end
        opts.on('-l', 'List in long format.') do
          settings.long_format = true
        end
        opts.on('-R', 'Recursively list subdirectories encountered.') do
          settings.recursive = true
        end
      end
    end

    #
    # The eponymous function lists a single path
    #
    def ls(path)
      stat = @client.stat(path)
      # TODO: check possible error returns from @client.stat
      unless stat
        puts @name + ': ' + path + ': ' + 'No such file or directory'
        return
      end
      if (stat['type'] == 'DIRECTORY') && !@settings.dir_plain
        ls_dir(stat, path)
        return
      end
      ls_plain(stat, path)
    end

    #
    # Lists a file or directory as a plain file.
    #
    def ls_plain(stat, path)
      if stat
        if @sp
          @sp.run(stat, path)
        else
          puts path
        end
      else
      end
    end

    #
    # Lists a directory
    #
    def ls_dir(stat, path)
      fail "oops! ls_dir not implemented yet!"
    end
  end
end
