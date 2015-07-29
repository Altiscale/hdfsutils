#
# Library: compile.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

#
# This module compiles the expression provided to find.
#
module FindCompile
  # Time constants.  It would be appropriate to hoist these constants
  # to the highest level of the code that needs them.
  MSEC_USEC    = 1000
  SECOND_MSEC  = 1000
  MINUTE_MSEC  = 60 * SECOND_MSEC
  HOUR_MSEC    = 60 * MINUTE_MSEC
  DAY_MSEC     = 24 * HOUR_MSEC
  WEEK_MSEC    =  7 * DAY_MSEC

  def compile_init
    @logger.debug("find expression: #{@findexp}")
    @findterms = findterms
    @now = Time.new
    @nowmsec = ((@now.tv_sec * SECOND_MSEC) + (@now.tv_usec / MSEC_USEC))
  end

  def findterms
    { atime: access_time,
      ls:    ls,
      mtime: modification_time,
      print: print,
      size:  size
    }
  end

  def compile(expression)
    @logger.debug("compiling: #{expression}")
    return -> (_path, _stat, _depth) { true } if expression.empty?
    return compile_term(expression) if expression[0].is_a? Symbol
    compile_conjunction(expression)
  end

  def compile_conjunction(expression)
    terms = [] # terms of the conjunction, represented as an array of lambdas
    expression.each do |subexpr|
      terms << compile(subexpr)
    end
    lambda do |path, stat, depth|
      # execute terms of conjunction in order, returning false if any fail
      terms.each do |term|
        # TODO: optimize query by ordering these terms by a combination of
        # evaluation speed, likely ability to prune, and (when appropriate)
        # preservation of expected side-effects (e.g. for the -exec option).
        return false unless term.call(path, stat, depth)
      end
      true # all terms of the conjunction succeeded
    end
  end

  def compile_term(term)
    termfun = @findterms[term[0]]
    fail "no find term function for #{term[0]}" unless termfun
    termfun.call(term)
  end

  def access_time
    lambda do |term|
      op, num, unitmsec = parse_time(term[1])
      lambda do |_path, stat, _depth|
        accesstime = stat['accessTime']
        return false if accesstime.nil? || (accesstime == 0)
        # assumes that accessTime is less than the current time
        compare_time(accesstime, @nowmsec, op, num, unitmsec)
      end
    end
  end

  def print
    lambda do |_term|
      lambda do |path, _stat, _depth|
        puts path
        true
      end
    end
  end

  def ls
    lambda do |_term|
      lambda do |path, stat, _depth|
        @sp.run(stat, path)
        true
      end
    end
  end

  def modification_time
    lambda do |term|
      op, num, unitmsec = parse_time(term[1])
      lambda do |_path, stat, _depth|
        modtime = stat['modificationTime']
        return false if modtime.nil? || (modtime == 0)
        # assumes that modificationTime is less than the current time
        compare_time(modtime, @nowmsec, op, num, unitmsec)
      end
    end
  end

  def size
    lambda do |term|
      op, num, unitsize = parse_numeric(term[1])
      lambda do |_path, stat, _depth|
        # TODO: use CONTENTSUMMARY for directory
        # In the meantime, directories should never print because length == 0
        # in the stat object.
        return false if stat['type'] == 'DIRECTORY'
        compare_generic(stat['length'], op, num, unitsize)
      end
    end
  end

  # static structure to translate units to milliseconds/unit
  UNIT_TO_MSEC = {
    's' => SECOND_MSEC,
    'm' => MINUTE_MSEC,
    'h' => HOUR_MSEC,
    'd' => DAY_MSEC,
    'w' => WEEK_MSEC,
    nil => DAY_MSEC
  }

  def parse_time(value)
    md = /\A(?<op>[\-\+]{0,1})(?<num>\d+)(?<unit>[smhdw]{0,1})\z/.match(value)
    fail "#{value}: invalid time value" unless md
    [md['op'], md['num'].to_i, UNIT_TO_MSEC[md['unit']]]
  end

  def compare_time(earliermsec, latermsec, op, num, unitmsec)
    # calculate the difference in milliseconds
    diffmsec = latermsec - earliermsec

    compare_generic(diffmsec, op, num, unitmsec)
  end

  UNIT_TO_BYTES = {
    'c' => 2**0,
    'k' => 2**10,
    'M' => 2**20,
    'G' => 2**30,
    'T' => 2**40,
    'P' => 2**50,
    nil => 512
  }

  def parse_numeric(value)
    md = /\A(?<op>[\-\+]{0,1})(?<num>\d+)(?<unit>[ckMGTP]{0,1})\z/.match(value)
    fail "#{value}: invalid numeric value" unless md
    [md['op'], md['num'].to_i, UNIT_TO_BYTES[md['unit']]]
  end

  #
  # compare_generic implements the find semantics for comparison:
  #   1. Round up to the desired unit.
  #   2. Compare based on the given operator.
  #
  def compare_generic(value, op, num, unitsize)
    # get the value in the appropriate unit, rounded up.
    # divmod returns [quotient, modulus]  (An efficient implementation
    # of divmod uses a single CPU operation to return both quantities.)
    divmod = value.divmod(unitsize)
    unitval = divmod[0] # value in the appropriate unit
    unitval += 1 unless divmod[1] == 0 # round up, if necessary

    # do the comparison to generate the return value of this function
    case op
    when '-' then unitval < num
    when '+' then unitval > num
    else          unitval == num # defaults to exact
    end
  end
end
