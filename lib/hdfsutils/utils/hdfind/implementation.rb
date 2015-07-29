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
    @sp = HdfsUtils::OutputStat.new(@settings)
    @args.each do |path|
      stat = @client.stat(path)
      find_path(stat, path, compiled, 0)
    end
  end

  def find_path(stat, path, compiled, depth)
    compiled.call(path, stat, depth)
    find_dir(path, compiled, depth) if stat['type'] == 'DIRECTORY'
  end

  def find_dir(path, compiled, depth)
    list = @client.list(path)
    fail "list operation failed for #{path}" unless list && (list.is_a? Array)
    list.each do |stat|
      suffix = stat['pathSuffix']
      find_path(stat, path + '/' + suffix, compiled, depth + 1)
    end
  end
end
