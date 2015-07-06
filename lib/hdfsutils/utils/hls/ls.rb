#
# Utility: hls.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'utils/util'
require 'output/output_stat'

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
      sp = OutputStat.new(@settings)
      @args.each do |path|
        sp.run(@client.stat(path), path)
      end
    end
  end
end
