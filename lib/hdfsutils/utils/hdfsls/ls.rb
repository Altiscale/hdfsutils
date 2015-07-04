#
# Program: hdfs_ls.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require_relative '../util'
require_relative '../../output'

module HdfsUtils
  #
  # This class runs the ls command for HDFS.
  #
  class Ls < Util
    public

    def initialize(argv)
      # TODO: specific options for ls
      super
      @args = argv
    end

    def run
      sp = Output.new(@settings)
      @args.each do |path|
        sp.run(@client.stat(path))
      end
    end
  end
end
