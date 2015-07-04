#
# Library: output_stat.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'pp'

module HdfsUtils
  class OutputStat
    public

    def initialize(settings)
      @settings = settings
    end

    def run(thing)
      pp thing
      sp = OutputStat.new(@settings)
      @args.each do |path|
        sp.run(@client.stat(path))
      end
    end
  end
end
