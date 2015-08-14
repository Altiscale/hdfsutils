#
# Test: hdls_spec.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require_relative '../spec_helper'
require_relative 'common_spec_webmock'
require 'utils/hdls/ls'

describe HdfsUtils::Ls do
  include CommonSpecWebmock

  it 'should ls a directory as a plain file' do
    dirname = '/user/testuser/testdir'
    common_spec_webmock(dirname: dirname,
                        filename: 'not_used',
                        dir2name: 'not_used')

    ls_output = 'drwxr-xr-x   - testuser users ' \
                '         0 2015-05-15 21:03 ' +
                dirname + "\n"

    expect do
      HdfsUtils::Ls.new('hdls',
                        ['--log-level', 'dEbUg',
                         '-ld',
                         dirname]).run
    end.to output(ls_output).to_stdout
  end

  it 'should ls a directory' do
    dirname = '/user/testuser/anotherdir'
    filename = 'kv1.txt'
    dir2name = 'testdir002'
    common_spec_webmock(dirname: dirname,
                        filename: filename,
                        dir2name: dir2name)

    ls_output = filename + "\n" +
                dir2name + "\n"

    expect do
      HdfsUtils::Ls.new('hdls', [dirname]).run
    end.to output(ls_output).to_stdout
  end

  it 'should ls a directory in long format' do
    dirname = '/user/testuser/yetanotherdir'
    filename = 'another_filename'
    dir2name = 'another_sub_dir'
    common_spec_webmock(dirname: dirname,
                        filename: filename,
                        dir2name: dir2name)

    ls_output = '-rwxrwxr-x   3 testuser users ' +
                '      5812 2015-05-15 21:04 ' +
                filename + "\n" +
                'drwx------   - testuser users ' +
                '         0 2015-05-15 21:07 ' +
                dir2name + "\n"

    expect do
      HdfsUtils::Ls.new('hdls',
                        ['-l',
                         '--log-level', 'warn',
                         dirname]).run
    end.to output(ls_output).to_stdout
  end

  it 'should ls a directory recursively' do
    dirname = '/user/testuser/yetanotherdir'
    filename = 'yet_another_filename'
    dir2name = 'sub_dir_for_recursion'
    file2name = 'testfile002'
    file3name = 'testfile003'
    common_spec_webmock(dirname: dirname,
                        filename: filename,
                        dir2name: dir2name,
                        file2name: file2name,
                        file3name: file3name)

    ls_output = filename + "\n" +
                dir2name + "\n" + "\n" +
                dirname + '/' + dir2name + ':' + "\n" +
                file2name + "\n" +
                file3name + "\n"

    expect do
      HdfsUtils::Ls.new('hdls',
                        ['-R',
                         dirname,
                         '--log-level', 'fatal']).run
    end.to output(ls_output).to_stdout
  end

  it 'should ls a directory recursively in long format' do
    dirname = '/data'
    filename = 'first_data_file'
    dir2name = 'recursion_dir_long'
    file2name = 'second_data_file'
    file3name = 'third_data_file'
    common_spec_webmock(dirname: dirname,
                        filename: filename,
                        dir2name: dir2name,
                        file2name: file2name,
                        file3name: file3name)

    ls_output = '-rwxrwxr-x   3 testuser users ' +
                '      5812 2015-05-15 21:04 ' +
                filename + "\n" +
                'drwx------   - testuser users ' +
                '         0 2015-05-15 21:07 ' +
                dir2name + "\n" + "\n" +
                dirname + '/' + dir2name + ':' + "\n" +
                '-rwxrwxr-x   3 testuser hiveusers ' +
                ' 268435456 2015-05-15 20:52 ' +
                file2name + "\n" +
                '-rwxrwxr-x   3 testuser users     ' +
                ' 379334628 2015-05-15 22:28 ' +
                file3name + "\n"

    expect do
      HdfsUtils::Ls.new('hdls',
                        ['-lR',
                         '--log-level', 'info',
                         dirname]).run
    end.to output(ls_output).to_stdout
  end

  it 'should support unix units for output' do
    dirname = '/data'
    filename = 'first_data_file'
    dir2name = 'recursion_dir_long'
    file2name = 'second_data_file'
    file3name = 'third_data_file'
    common_spec_webmock(dirname: dirname,
                        filename: filename,
                        dir2name: dir2name,
                        file2name: file2name,
                        file3name: file3name)

    ls_output = '-rwxrwxr-x   3 testuser users ' +
                '     5.67K 2015-05-15 21:04 ' +
                filename + "\n" +
                'drwx------   - testuser users ' +
                '        0B 2015-05-15 21:07 ' +
                dir2name + "\n" + "\n" +
                dirname + '/' + dir2name + ':' + "\n" +
                '-rwxrwxr-x   3 testuser hiveusers ' +
                '      256M 2015-05-15 20:52 ' +
                file2name + "\n" +
                '-rwxrwxr-x   3 testuser users     ' +
                '      361M 2015-05-15 22:28 ' +
                file3name + "\n"

    expect do
      HdfsUtils::Ls.new('hdls',
                        ['-lR',
                         '--log-level', 'debug',
                         '--filesizeunits', 'unix',
                         dirname]).run
    end.to output(ls_output).to_stdout
  end
end
