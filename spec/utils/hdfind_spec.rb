#
# Test: hdfind_spec.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require_relative '../spec_helper'
require_relative 'common_spec_webmock'
require 'utils/hdfind/find'

describe HdfsUtils::Find do
  include CommonSpecWebmock

  it 'should find everything in a directory' do
    dirname = '/user/testuser/testdir'
    filename = 'testfilename001'
    dir2name = 'test_sub_dir'
    file2name = 'testfile002'
    file3name = 'testfile003'
    common_spec_webmock(dirname: dirname,
                        filename: filename,
                        dir2name: dir2name,
                        file2name: file2name,
                        file3name: file3name)

    subdir = dirname + '/' + dir2name
    find_output = dirname + "\n" +
                  dirname + '/' + filename  + "\n" +
                  subdir  + "\n" +
                  subdir  + '/' + file2name + "\n" +
                  subdir  + '/' + file3name + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname]).run
    end.to output(find_output).to_stdout
  end

  it 'should handle atime and mtime properly' do
    dirname = '/user/testuser/another_testdir'
    filename = 'another_test_101'
    dir2name = 'another_sub_dir'
    subdir = dirname + '/' + dir2name
    file2name = 'another_test_102'
    file3name = 'another_test_103'
    common_spec_webmock(dirname: dirname,
                        filename: filename,
                        dir2name: dir2name,
                        file2name: file2name,
                        file3name: file3name,
                        file3atime: Time.new - 60 * 5,
                        file3mtime: Time.new - 60 * 60 * 24 * 5)

    find_output = dirname + '/' + filename  + "\n" +
                  subdir  + '/' + file2name + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-atime', '+7m']).run
    end.to output(find_output).to_stdout

    find_output = subdir  + '/' + file3name + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-atime', '-7m']).run
    end.to output(find_output).to_stdout

    find_output = dirname + "\n" +
                  dirname + '/' + filename  + "\n" +
                  subdir  + "\n" +
                  subdir  + '/' + file2name + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-mtime', '+10d']).run
    end.to output(find_output).to_stdout

    find_output = subdir  + '/' + file3name + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-mtime', '-10d']).run
    end.to output(find_output).to_stdout
  end
end
