#
# Library: implementation.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'output/output_stat' # prints file stat structure

#
# This module implements find.
# While this implementation may inform the code for other utilities,
# it is not intended to provide a generic pattern for all utilities.
#
module FindImplementation
  #
  # The eponymous function implements the find command.
  #
  def find
    compile_init
    compiled = compile(@findexp)
    @sp = HdfsUtils::OutputStat.new(@settings, batch: 1)
    @args = ["/user/#{@settings[:username]}"] if @args.empty?
    @args.each do |path|
      stat = nil
      begin
        stat = @client.stat(path)
      # rubocop:disable Lint/HandleExceptions
      rescue WebHDFS::FileNotFoundError
        # fall through, leave stat == nil
      end
      # rubocop:enable Lint/HandleExceptions
      unless stat
        puts @name + ': ' + path + ': ' + 'No such file or directory'
        next
      end
      find_path(stat, path, compiled, 0)
    end
    @sp.play
  end

  def find_path(stat, path, compiled, depth)
    isdir = (stat['type'] == 'DIRECTORY')
    merge_content_summary(stat, path) if isdir && @contentsum
    return if stat['length'] < @minsize
    return if isdir && (stat['length'] < @mindirsize)
    compiled.call(path, stat, depth) if @mindepth <= depth
    return if depth >= @maxdepth
    find_dir(path, compiled, depth) if isdir
  end

  def merge_content_summary(stat, path)
    cs = @client.content_summary(path)
    fail "content summary failed for #{path}" unless cs && (cs.is_a? Hash)
    stat.merge!(cs)
  end

  def find_dir(path, compiled, depth)
    list = @client.list(path)
    fail "list operation failed for #{path}" unless list && (list.is_a? Array)
    list.each do |stat|
      suffix = stat['pathSuffix']
      find_path(stat, File.join(path, suffix), compiled, depth + 1)
    end
  end
end
