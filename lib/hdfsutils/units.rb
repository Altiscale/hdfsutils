#
# Library: units.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#
#
# Support for different filesize unit systems:
#   'unix' - base 1024 - compatible with ls -h and du -h
#                      - uses B K M G T P on output
#                        (but c k M G T P are still supported on input)
#   'si'   - base 1000 - B kB MB GB TB PB (input and output)
#   'iec'  - base 1024 - B KiB MiB GiB TiB PiB (input and output)
#
# The algorithm for converting from raw byte numbers to units is slightly
# different from Linux (which itself differs slightly from version to version).
# In summary:
# - It computes the largest unit that allows a representation that is lesser
#   or equal to the raw number: thus 1023 bytes becomes '1023B', not '1.0K'
#   as on some linux systems.
# - The numeric portion is never more than 3 characters (for base-1000 systems)
#   or 4 characters (for base 1024 systems) unless the unit is the maximum
#   (petabytes, at present) in which case as many characters are used
#   as needed. Thus, (1000**6) becomes 1000PB.
# - It uses a decimal point only:
#   - If there is room for at least one digit after decimal point.
#     Thus 99_999 becomes 99kB.
#   - The fractional part is non-zero. Thus (1024**2) becomes 1M.
# - Like unix systems, it truncates the fractional part, removes trailing
#   zeroes, preserving only one if immediately after the decimal point.
#   Thus (1024**2)+1 becomes 1.0M.
#
# The behavior is extensively documented by the unit tests.
#

module HdfsUtils
  #
  # Standard handling of units for input and output for all utilities
  #
  class Units
    public

    FILESIZE_REGEXP = /\A
      (?<op>[\-\+]{0,1})
      (?<num>\d+)
      (?<unit>(c|(kB?)|(KiB)|([MGTP](i?B)?)?))
      \z/x

    UNIT_TO_BYTES = {
      'c' => 2**0,
      'k' => 2**10,
      'M' => 2**20,
      'G' => 2**30,
      'T' => 2**40,
      'P' => 2**50,
      'kB' => 1000,
      'MB' => 1000**2,
      'GB' => 1000**3,
      'TB' => 1000**4,
      'PB' => 1000**5,
      'KiB' => 2**10,
      'MiB' => 2**20,
      'GiB' => 2**30,
      'TiB' => 2**40,
      'PiB' => 2**50,
      ''  => 512
    }

    SI_UNITS = {
      units: %w(B kB MB GB TB PB),
      base: 1000,
      width: 3
    }

    IEC_UNITS = {
      units: %w(B KiB MiB GiB TiB PiB),
      base: 1024,
      width: 4
    }

    UNIX_UNITS = {
      units: %w(B K M G T P),
      base: 1024,
      width: 4
    }

    SYSTEM_TO_UNITS = {
      'unix' => UNIX_UNITS,
      'si' => SI_UNITS,
      'iec' => IEC_UNITS
    }

    def parse_filesize(value)
      md = FILESIZE_REGEXP.match(value)
      fail "#{value}: invalid numeric value" unless md
      [md['op'], md['num'].to_i, UNIT_TO_BYTES[md['unit']]]
    end

    def format_filesize(n, system = 'bytes')
      units = SYSTEM_TO_UNITS[system]
      return n.to_s unless units
      return "0#{units[:units][0]}" if n == 0
      require 'bigdecimal'
      n = BigDecimal.new(n)
      sign = n.sign < 0 ? '-' : ''
      n = n.abs
      i = 0
      while i < units[:units].length - 1
        break if n < units[:base]
        n /= units[:base]
        i += 1
      end
      s = n.to_i.to_s
      if s.length < units[:width] - 1 && n.frac != 0
        _sign, significant_digits, _base, exponent = n.split
        s += '.' + significant_digits[exponent..-1] + '0000000000'
        s = s[0, units[:width]]
        s = s.sub(/\.0*$/, '.0')
        s.chomp!('.')
      end
      "#{sign}#{s}#{units[:units][i]}"
    end
  end
end
