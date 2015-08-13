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
    @mindepth = 0
    @maxdepth = 2**31 # virtually infinite when it comes to HDFS filesystem
    @minsize = 0
    @contentsum = false
  end

  def findterms
    { atime:    time_match,
      depth:    depth,
      ls:       ls,
      iname:    path_match,
      ipath:    path_match,
      maxdepth: depth_constraint,
      mindepth: depth_constraint,
      minsize:  minsize,
      mtime:    time_match,
      name:     path_match,
      path:     path_match,
      print:    print,
      size:     size
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

  def time_match
    lambda do |term|
      op, num, unitmsec = parse_time(term[1])
      lambda do |_path, stat, _depth|
        msec = case term[0]
               when :atime then stat['accessTime']
               when :mtime then stat['modificationTime']
               else fail "unknown time match: #{term[0]}"
               end
        return false if msec.nil? || (msec == 0)
        # assumes that accessTime is less than the current time
        compare_time(msec, @nowmsec, op, num, unitmsec)
      end
    end
  end

  def depth
    lambda do |term|
      op, num = parse_number(term[1])
      lambda do |_path, _stat, depth|
        compare_op(op, depth, num)
      end
    end
  end

  def depth_constraint
    lambda do |term|
      _op, num = parse_number(term[1])
      case term[0]
      when :maxdepth then @maxdepth = num
      when :mindepth then @mindepth = num
      else fail "unknown depth constraint: #{term[0]}"
      end
      lambda do |_path, _stat, _depth|
        true
      end
    end
  end

  def minsize
    lambda do |term|
      fail "unknown depth constraint: #{term[0]}" unless term[0] == :minsize
      _op, num, unitsize = parse_numeric(term[1])
      @minsize = num * unitsize
      @contentsum = true
      lambda do |_path, stat, _depth|
        stat['length'] >= @minsize
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
      @contentsum = true
      lambda do |path, stat, _depth|
        @sp.run(stat, path)
        true
      end
    end
  end

  def size
    lambda do |term|
      op, num, unitsize = parse_numeric(term[1])
      @contentsum = true
      lambda do |_path, stat, _depth|
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
    ''  => DAY_MSEC
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

  def parse_number(value)
    md = /\A(?<op>[\-\+]{0,1})(?<num>\d+)\z/.match(value)
    fail "#{value}: invalid number" unless md
    [md['op'], md['num'].to_i]
  end

  def parse_numeric(value)
    HdfsUtils::Units.new.parse_filesize(value)
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
    compare_op(op, unitval, num)
  end

  def compare_op(op, lval, rval)
    case op
    when '-' then lval < rval
    when '+' then lval > rval
    else          lval == rval # defaults to exact
    end
  end

  def path_match
    lambda do |term|
      lambda do |path, _stat, _depth|
        case term[0]
        when :path then
          matchable = path
          flags = []
        when :name then
          matchable = File.basename(path)
          flags = []
        when :ipath then
          matchable = path
          flags = [File::FNM_CASEFOLD]
        when :iname then
          matchable = File.basename(path)
          flags = [File::FNM_CASEFOLD]
        else fail "unknown path match term: #{term[0]}"
        end
        File.fnmatch(term[1], matchable, *flags)
      end
    end
  end
end
