#
# Library: output_stat.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#
# The OutputStat class formats the information in the file
# status (stat) record returned by the WebHDFS protocol
# via the webhdfs gem.
#
# This class uses a heuristic to make the formatting look
# good to a human reader.  When configured appropriately
# (see below), the class calculates the maximum size of each
# of the variable-size fields.
#
# The maximum size can grow as the class sees each line.
# The class uses the sizes that it learns to align the
# the columns it prints from line to line.  This heuristic
# may cause the alignment to change slightly over time; however,
# the output looks better in general than unaligned output.
#
# There are two ways to configure learning:
# 1. Use the record and play methods.  Record sets the
#    class to learn field sizes for a certain number
#    of lines.  Play prints the lines buffered during
#    the learning process.  This pattern is useful when
#    the calling code knows the number of lines that
#    need to be printed.  For example, the ls utility knows
#    the number of files in a directory before printing the
#    directory.
# 2. Use the batch option when the class is initialized.
#    This option is appropriate when the calling code
#    does not know how many lines it will print a priori.
#    For example, the find utility is expected to print
#    files as it runs.  Providing output quickly is more
#    important than the format of the output.
#
# rubocop:disable Metrics/ClassLength

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
      @defaultalignment = {
        owner: 8,
        group: 5,
        size: 10
      }
      @batch = options[:batch]
      @record = @batch
      @alignment = @defaultalignment
      @timekey = @settings.access_time ? 'accessTime' : 'modificationTime'
    end

    #
    # Set the number of lines to use to learn the maximum sizes of
    # variable length fields.
    #
    def record(lines)
      @logger.debug("OutputStat recording #{lines} line(s).")
      @record = lines
    end

    #
    # Print the file status information or (if recording) buffer the
    # formatted output and learn the alignment of the variable length
    # fields.
    #
    def run(stat, name)
      if @record.nil?
        output_line(to_line(stat, name))
      else
        begin
          @buffer << to_line(stat, name)
          @record -= 1
        rescue
          play # print everything before the error
          raise $!
        end
        play if @record <= 0
      end
    end

    #
    # Print any recorded status information.
    #
    def play
      @logger.debug("OutputStat playing #{@buffer.length} line(s).")
      align
      @buffer.each { |line| output_line(line) }
      @buffer = []
      @record = @batch
    end

    private

    #
    # Convert the file status (stat) and name to the strings that
    # will be assembled into a line of output.
    #
    def to_line(stat, name)
      {
        mode:  output_mode(stat),
        repl:  output_repl(stat),
        owner: stat['owner'] || 'unknown',
        group: stat['group'] || 'unknown',
        size:  output_size(stat),
        time:  output_time(stat),
        name:  name
      }
    end

    #
    # Learn the alignment of the variable length fields.
    #
    def align
      [:owner, :group, :size].each do |field|
        current = @alignment[field]
        @buffer.each do |line|
          new = line[field].length
          current = new if current < new
        end
        @alignment[field] = current
      end
    end

    #
    # Output a line that represents the file status (stat).
    #
    def output_line(line)
      output  = line[:mode] + ' '
      output << line[:repl] + ' '
      output << line[:owner].ljust(@alignment[:owner]) + ' '
      output << line[:group].ljust(@alignment[:group]) + ' '
      output << line[:size].rjust(@alignment[:size]) + ' '
      output << line[:time] + ' '
      output << line[:name]  + "\n"
      puts output
    end

    #
    # Convert the file mode to a string.
    #
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

    #
    # Convert the replication factor to a string.
    #
    def output_repl(stat)
      repl = stat['replication']
      return '  -' if repl == 0
      sprintf('%3d', repl)
    end

    #
    # Convert the file size to a string.
    #
    def output_size(stat)
      HdfsUtils::Units.new.format_filesize(stat['length'],
                                           @settings[:filesizeunits])
    end

    #
    # Convert the appropriate file time information to a string.
    #
    def output_time(stat)
      timemsec = stat[@timekey]
      return '[NOT AVAILABLE] ' if timemsec.nil? || timemsec == 0
      time = Time.at(timemsec / 1000)
      # Outputs UTC.  To output in the local timezone,
      # call time.localtime.strftime
      time.utc.strftime('%Y-%m-%d %H:%M')
    end
  end
end
