#
# Test: filesize_units_spec.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require_relative '../spec_helper'
require 'units.rb'

describe HdfsUtils::Units do
  PARSE_TESTS =
    [
      ['123', ['', 123, 512]],
      ['123', ['', 123, 512]],
      ['123c', ['', 123, 1]],
      ['123k', ['', 123, 2**10]],
      ['123M', ['', 123, 2**20]],
      ['123G', ['', 123, 2**30]],
      ['123T', ['', 123, 2**40]],
      ['123P', ['', 123, 2**50]],
      ['123kB', ['', 123, 1000]],
      ['123MB', ['', 123, 1000**2]],
      ['123GB', ['', 123, 1000**3]],
      ['123TB', ['', 123, 1000**4]],
      ['123PB', ['', 123, 1000**5]],
      ['123KiB', ['', 123, 2**10]],
      ['123MiB', ['', 123, 2**20]],
      ['123GiB', ['', 123, 2**30]],
      ['123TiB', ['', 123, 2**40]],
      ['123PiB', ['', 123, 2**50]],
      ['+123MiB', ['+', 123, 2**20]]
    ]

  PARSE_TESTS.each do |val, expected|
    it "should parse #{val} correctly" do
      expect(subject.parse_filesize(val)).to eq(expected)
    end
  end

  NEGATIVE_PARSE_TESTS = %w(123kiB 123KB 123cB 123Mi)

  NEGATIVE_PARSE_TESTS.each do |val|
    it "should raise an error when parsing #{val}" do
      expect { subject.parse_filesize(val) }.to raise_error(RuntimeError)
    end
  end

  FORMAT_TESTS =
    [
      [-1, { 'unix' => '-1B', 'si' => '-1B', 'iec' => '-1B' }],
      [0, { 'unix' => '0B', 'si' => '0B', 'iec' => '0B' }],
      [1, { 'unix' => '1B', 'si' => '1B', 'iec' => '1B' }],
      [12, { 'unix' => '12B', 'si' => '12B', 'iec' => '12B' }],
      [123, { 'unix' => '123B', 'si' => '123B', 'iec' => '123B' }],
      [999, { 'unix' => '999B', 'si' => '999B', 'iec' => '999B' }],
      [1000, { 'unix' => '1000B', 'si' => '1kB', 'iec' => '1000B' }],
      [1001, { 'unix' => '1001B', 'si' => '1.0kB', 'iec' => '1001B' }],
      [1023, { 'unix' => '1023B', 'si' => '1.0kB', 'iec' => '1023B' }],
      [1024, { 'unix' => '1K', 'si' => '1.0kB', 'iec' => '1KiB' }],
      [1025, { 'unix' => '1.0K', 'si' => '1.0kB', 'iec' => '1.0KiB' }],
      [9999, { 'unix' => '9.76K', 'si' => '9.9kB', 'iec' => '9.76KiB' }],
      [99_999, { 'unix' => '97.6K', 'si' => '99kB', 'iec' => '97.6KiB' }],
      [999_999, { 'unix' => '976K', 'si' => '999kB', 'iec' => '976KiB' }],
      [1000**2 - 1, { 'unix' => '976K', 'si' => '999kB', 'iec' => '976KiB' }],
      [1000**2, { 'unix' => '976K', 'si' => '1MB', 'iec' => '976KiB' }],
      [1000**2 + 1, { 'unix' => '976K', 'si' => '1.0MB', 'iec' => '976KiB' }],
      [1024**2 - 1, { 'unix' => '1023K', 'si' => '1.0MB', 'iec' => '1023KiB' }],
      [1024**2, { 'unix' => '1M', 'si' => '1.0MB', 'iec' => '1MiB' }],
      [1024**2 + 1, { 'unix' => '1.0M', 'si' => '1.0MB', 'iec' => '1.0MiB' }],
      [1000**3 - 1, { 'unix' => '953M', 'si' => '999MB', 'iec' => '953MiB' }],
      [1000**3, { 'unix' => '953M', 'si' => '1GB', 'iec' => '953MiB' }],
      [1000**3 + 1, { 'unix' => '953M', 'si' => '1.0GB', 'iec' => '953MiB' }],
      [1024**3 - 1, { 'unix' => '1023M', 'si' => '1.0GB', 'iec' => '1023MiB' }],
      [1024**3, { 'unix' => '1G', 'si' => '1.0GB', 'iec' => '1GiB' }],
      [1024**3 + 1, { 'unix' => '1.0G', 'si' => '1.0GB', 'iec' => '1.0GiB' }],
      [1000**4 - 1, { 'unix' => '931G', 'si' => '999GB', 'iec' => '931GiB' }],
      [1000**4, { 'unix' => '931G', 'si' => '1TB', 'iec' => '931GiB' }],
      [1000**4 + 1, { 'unix' => '931G', 'si' => '1.0TB', 'iec' => '931GiB' }],
      [1024**4 - 1, { 'unix' => '1023G', 'si' => '1.0TB', 'iec' => '1023GiB' }],
      [1024**4, { 'unix' => '1T', 'si' => '1.0TB', 'iec' => '1TiB' }],
      [1024**4 + 1, { 'unix' => '1.0T', 'si' => '1.0TB', 'iec' => '1.0TiB' }],
      [1000**5 - 1, { 'unix' => '909T', 'si' => '999TB', 'iec' => '909TiB' }],
      [1000**5, { 'unix' => '909T', 'si' => '1PB', 'iec' => '909TiB' }],
      [1000**5 + 1, { 'unix' => '909T', 'si' => '1.0PB', 'iec' => '909TiB' }],
      [1024**5 - 1, { 'unix' => '1023T', 'si' => '1.1PB', 'iec' => '1023TiB' }],
      [1024**5, { 'unix' => '1P', 'si' => '1.1PB', 'iec' => '1PiB' }],
      [1024**5 + 1, { 'unix' => '1.0P', 'si' => '1.1PB', 'iec' => '1.0PiB' }],
      [1000**6 - 1, { 'unix' => '888P', 'si' => '999PB', 'iec' => '888PiB' }],
      [1000**6, { 'unix' => '888P', 'si' => '1000PB', 'iec' => '888PiB' }],
      [1000**6 + 1, { 'unix' => '888P', 'si' => '1000PB', 'iec' => '888PiB' }],
      [1024**6 - 1, { 'unix' => '1023P', 'si' => '1152PB',
                      'iec' => '1023PiB' }],
      [1024**6, { 'unix' => '1024P', 'si' => '1152PB', 'iec' => '1024PiB' }],
      [1024**6 + 1, { 'unix' => '1024P', 'si' => '1152PB', 'iec' => '1024PiB' }]
    ]

  FORMAT_TESTS.each do |val, canonicals|
    canonicals.each_pair do |system, expected|
      it "should format #{val} correctly using #{system} units" do
        expect(subject.format_filesize(val, system)).to eq(expected)
      end
    end
  end

  FORMAT_TESTS.each do |val, _canonicals|
    it "should format #{val} correctly using default units" do
      expect(subject.format_filesize(val)).to eq(val.to_s)
    end
  end
end
