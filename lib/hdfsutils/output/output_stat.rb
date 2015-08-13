#
# Library: output_stat.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'pp'
require 'units'

module HdfsUtils
  #
  # Outputs a webhdfs stat record
  #
  class OutputStat
    public

    def initialize(settings)
      @settings = settings
    end

    def run(stat, name)
      output  = output_mode(stat) + ' '
      output << output_repl(stat) + ' '
      output << stat['owner'] + ' '
      output << stat['group'] + ' '
      output << output_size(stat) + ' '
      output << output_mtime(stat) + ' '
      output << name + "\n"
      puts output
    end

    private

    def output_mode(stat)
      output = ((stat['type'] == 'DIRECTORY') ? 'd' : '-')
      mode = stat['permission'].oct # convert to octal number
      output << (((mode & 0400) == 0) ? '-' : 'r')
      output << (((mode & 0200) == 0) ? '-' : 'w')
      output << (((mode & 0100) == 0) ? '-' : 'x')
      output << (((mode & 0040) == 0) ? '-' : 'r')
      output << (((mode & 0020) == 0) ? '-' : 'w')
      output << (((mode & 0010) == 0) ? '-' : 'x')
      output << (((mode & 0004) == 0) ? '-' : 'r')
      output << (((mode & 0002) == 0) ? '-' : 'w')
      output << (((mode & 0001) == 0) ? '-' : 'x')
      output
    end

    def output_repl(stat)
      repl = stat['replication']
      return '  -' if repl == 0
      sprintf('%3d', repl)
    end

    def output_size(stat)
      s = HdfsUtils::Units.new.format_filesize(stat['length'],
                                               @settings[:filesizeunits])
      sprintf('%10s', s)
    end

    def output_mtime(stat)
      time = Time.at(stat['modificationTime'] / 1000)
      # Outputs UTC.  To output in the local timezone,
      # call time.localtime.strftime
      time.utc.strftime('%Y-%m-%d %H:%M')
    end
  end
end
