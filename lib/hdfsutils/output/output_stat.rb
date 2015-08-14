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

    def initialize(settings, options = {})
      @settings = settings
      @logger = @settings[:logger]
      @buffer = []
      @defaultjustification = {
        owner: 8,
        group: 5,
        size: 10
      }
      @batch = options[:batch]
      @record = @batch
      @justification = @defaultjustification
    end

    def record(lines)
      @logger.debug("OutputStat recording #{lines} line(s).")
      @record = lines
    end

    def run(stat, name)
      play if @record == 0
      if @record.nil?
        output_line(to_line(stat, name))
      else
        begin
          @buffer << to_line(stat, name)
          @record -= 1
        rescue
          play # print everything befor the error
          raise $!
        end
      end
    end

    def play
      @logger.debug("OutputStat playing #{@buffer.length} line(s).")
      justify
      @buffer.each { |line| output_line(line) }
      @buffer = []
      @record = @batch
    end

    private

    def to_line(stat, name)
      {
        mode:  output_mode(stat),
        repl:  output_repl(stat),
        owner: stat['owner'] || 'unknown',
        group: stat['group'] || 'unknown',
        size:  output_size(stat),
        mtime: output_mtime(stat),
        name:  name
      }
    end

    def justify
      [:owner, :group, :size].each do |field|
        current = @justification[field]
        @buffer.each do |line|
          new = line[field].length
          current = new if current < new
        end
        @justification[field] = current
      end
    end

    def output_line(line)
      output  = line[:mode] + ' '
      output << line[:repl] + ' '
      output << line[:owner].ljust(@justification[:owner]) + ' '
      output << line[:group].ljust(@justification[:group]) + ' '
      output << line[:size].rjust(@justification[:size]) + ' '
      output << line[:mtime] + ' '
      output << line[:name]  + "\n"
      puts output
    end

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
      HdfsUtils::Units.new.format_filesize(stat['length'],
                                           @settings[:filesizeunits])
    end

    def output_mtime(stat)
      time = Time.at(stat['modificationTime'] / 1000)
      # Outputs UTC.  To output in the local timezone,
      # call time.localtime.strftime
      time.utc.strftime('%Y-%m-%d %H:%M')
    end
  end
end
