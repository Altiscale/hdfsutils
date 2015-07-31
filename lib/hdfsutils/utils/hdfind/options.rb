#
# Library: options.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

#
# Options for the find utility.
#
module FindOptions
  #
  # Options for the find utility.
  # The lambda is injected into the Util superclass option handling.
  #
  def util_opts
    lambda do |opts, _settings|
      opts.banner = banner
      parse! # process find-specific options that will confuse optparse
    end
  end

  def setup_opts(argv)
    @argv = argv
    @findopts = findopts
    @optshash = {}
    @findopts.each do |findopt| # generate hash from array
      @optshash[findopt[:flag]] = findopt
    end
  end

  #
  # Returns an array so that options appear in the specified order
  # in the banner.
  #
  # rubocop:disable Metrics/MethodLength
  def findopts
    [{ option:      :atime,
       flag:        '-atime',
       value:       'n[smhdw]',
       validate:    validate_time,
       description: 'Access time.'
     },
     { option:      :depth,
       flag:        '-depth',
       value:       'n',
       validate:    validate_number,
       description: 'Depth relative to the starting point.'
     },
     { option:      :iname,
       flag:        '-iname',
       value:       '[pattern]',
       description: 'Path matches pattern (case insensitive).'
     },
     { option:      :ipath,
       flag:        '-ipath',
       value:       '[pattern]',
       description: 'Path matches pattern (case insensitive).'
     },
     { option:      :maxdepth,
       flag:        '-maxdepth',
       value:       'n',
       validate:    validate_nonnegative,
       description: 'Descend at most n directory levels.'
     },
     { option:      :mindepth,
       flag:        '-mindepth',
       value:       'n',
       validate:    validate_nonnegative,
       description: 'Descend at least n directory levels.'
     },
     { option:      :minsize,
       flag:        '-minsize',
       value:       'n',
       validate:    validate_unsigned_numeric,
       description: 'Prunes find expression to objects of a minimum size.'
     },
     { option:      :mtime,
       flag:        '-mtime',
       value:       'n[smhdw]',
       validate:    validate_time,
       description: 'Modification time.'
     },
     { option:      :name,
       flag:        '-name',
       value:       '[pattern]',
       description: 'Name (last component of the path) matches pattern.'
     },
     { option:      :path,
       flag:        '-path',
       value:       '[pattern]',
       description: 'Path matches pattern.'
     },
     { option:      :print,
       flag:        '-print',
       description: 'Print the pathname.'
     },
     { option:      :ls,
       flag:        '-ls',
       description: 'Print ls-style information.'
     },
     { option:      :size,
       flag:        '-size',
       value:       'n[ckMGTP]',
       validate: validate_numeric,
       description: 'File size.'
     }
    ]
  end
  # rubocop:enable Metrics/MethodLength

  def banner
    # standard banner
    display = "Usage: #{@name} [options] [path ...] [expression]"

    # indent is one more space than longest summary
    indent = 1
    @findopts.each do |findopt|
      findopt[:summary] = findopt[:flag]
      findopt[:summary] += ' ' + findopt[:value] if findopt[:value]
      sumlen = findopt[:summary].length
      findopt[:sumlen] = sumlen
      indent = [indent, sumlen + 1].max
    end

    @findopts.each do |findopt|
      display << "\n  "
      display << findopt[:summary]
      display << ' ' * (indent - findopt[:sumlen])
      display << findopt[:description]
    end
    display
  end

  def parse!
    index = 0
    length = @argv.length
    while index < length
      findopt = @optshash[@argv[index]]
      index += findopt ? parseopt(findopt, index) : 1
    end
    default_print # append the default print term, if necessary
    @argv.compact! # removes nil elements removed by parseopt
  end

  #
  # Parses option at index in argv and returns new index.
  #
  def parseopt(findopt, index)
    @argv[index] = nil # strip option out of argv
    unless findopt[:value] # does not require a value
      @findexp << [findopt[:option]] # singleton token
      return 1 # advance index by one
    end

    # option requires a value
    value = @argv[index + 1]
    @argv[index + 1] = nil
    fail "#{findopt[:flag]}: requires additional arguments" unless value
    if findopt[:validate]
      error = findopt[:validate].call(value)
      fail error if error
    end
    @findexp << [findopt[:option], value]
    2 # advance index by two
  end

  #
  # Appends the default print term to the find expression, if necessary.
  #
  def default_print
    cancelprint = {
      exec: true,
      ls: true,
      ok: true,
      print: true,
      print0: true
    }
    @findexp.each do |term|
      return if cancelprint[term[0]]
    end
    @findexp << [:print]
  end

  def validate_time
    lambda do |timeval|
      return nil if timeval.match(/\A[\-\+]{0,1}\d+[smhdw]{0,1}\z/)
      "#{timeval}: illegal time value"
    end
  end

  def validate_number
    lambda do |number|
      return nil if number.match(/\A[\-\+]{0,1}\d+\z/)
      "#{number}: illegal numeric value"
    end
  end

  def validate_nonnegative
    lambda do |nonnegative|
      return nil if nonnegative.match(/\A\d+\z/)
      "#{nonnegative}: value must be a non-negative number"
    end
  end

  def validate_numeric
    lambda do |numval|
      return nil if numval.match(/\A[\-\+]{0,1}\d+[ckMGTP]{0,1}\z/)
      "#{numval}: illegal numeric value"
    end
  end

  def validate_unsigned_numeric
    lambda do |numval|
      return nil if numval.match(/\A\d+[ckMGTP]{0,1}\z/)
      "#{numval}: illegal unsigned numeric value"
    end
  end
end
