#
# Utility: implementation.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'output/output_stat' # prints file stat structure

#
# This module implements ls.
#
module LsImplementation
  #
  # The eponymous function lists a single path
  #
  def ls(path)
    # initialize stat printer, if necessary
    @sp = @settings.long_format ? HdfsUtils::OutputStat.new(@settings) : nil

    stat = @client.stat(path)
    # TODO: check possible error returns from @client.stat
    unless stat
      puts @name + ': ' + path + ': ' + 'No such file or directory'
      return
    end
    if (stat['type'] == 'DIRECTORY') && !@settings.dir_plain
      @logger.debug("listing directory #{path}")
      ls_dir(path)
      return
    end
    ls_plain(stat, path)
  end

  #
  # Lists a file or directory as a plain file.
  #
  def ls_plain(stat, path)
    if @sp
      @sp.run(stat, path)
    else
      puts path
    end
  end

  #
  # Lists a directory
  #
  def ls_dir(path)
    list = @client.list(path)

    fail "list operation failed for #{path}" unless list && (list.is_a? Array)
    if list.empty?
      @logger.debug('empty directory: ' + path)
      return
    end
    subdirs = []
    @sp.record(list.length) if @sp
    list.each do |stat|
      suffix = stat['pathSuffix']
      subdirs << File.join(path, suffix) if (stat['type'] == 'DIRECTORY')
      ls_plain(stat, suffix)
    end
    @sp.play if @sp
    return unless @settings.recursive
    subdirs.each do |subdir|
      puts
      puts subdir + ':'
      ls_dir(subdir)
    end
  end
end
