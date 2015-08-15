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
require 'units'

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

  it 'should implement atime and mtime' do
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

  it 'should implement size and print a file in long format' do
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
                        file3name: file3name)

    find_output = 'drwxr-xr-x   - testuser users ' +
                  ' 647775896 2015-05-15 21:03 ' +
                  dirname + "\n" +
                  'drwx------   - testuser users ' +
                  ' 647770084 2015-05-15 21:07 ' +
                  subdir  + "\n" +
                  '-rwxrwxr-x   3 testuser users ' +
                  ' 379334628 2015-05-15 22:28 ' +
                  subdir  + '/' + file3name + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-size', '+300M', '-ls']).run
    end.to output(find_output).to_stdout

    find_output = 'drwxr-xr-x   - testuser users ' +
                  ' 647775896 2015-05-15 21:03 ' +
                  dirname + "\n" +
                  'drwx------   - testuser users ' +
                  ' 647770084 2015-05-15 21:07 ' +
                  subdir  + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-minsize', '500000k', '-ls']).run
    end.to output(find_output).to_stdout
  end

  it 'should support unix units for size' do
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
                        file3name: file3name)

    find_output = 'drwxr-xr-x   - testuser users ' +
                  '      617M 2015-05-15 21:03 ' +
                  dirname + "\n" +
                  'drwx------   - testuser users ' +
                  '      617M 2015-05-15 21:07 ' +
                  subdir  + "\n" +
                  '-rwxrwxr-x   3 testuser users ' +
                  '      361M 2015-05-15 22:28 ' +
                  subdir  + '/' + file3name + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-size', '+379334627c', '-ls',
                                   '--filesizeunits', 'unix']).run
    end.to output(find_output).to_stdout

    find_output = 'drwxr-xr-x   - testuser users ' +
                  '      617M 2015-05-15 21:03 ' +
                  dirname + "\n" +
                  'drwx------   - testuser users ' +
                  '      617M 2015-05-15 21:07 ' +
                  subdir  + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-minsize', '500000k', '-ls',
                                   '--filesizeunits', 'unix']).run
    end.to output(find_output).to_stdout
  end

  it 'should support SI units for size' do
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
                        file3name: file3name)

    find_output = 'drwxr-xr-x   - testuser users ' +
                  '     647MB 2015-05-15 21:03 ' +
                  dirname + "\n" +
                  'drwx------   - testuser users ' +
                  '     647MB 2015-05-15 21:07 ' +
                  subdir  + "\n" +
                  '-rwxrwxr-x   3 testuser users ' +
                  '     379MB 2015-05-15 22:28 ' +
                  subdir  + '/' + file3name + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-size', '+370MB', '-ls',
                                   '--filesizeunits', 'si']).run
    end.to output(find_output).to_stdout

    find_output = 'drwxr-xr-x   - testuser users ' +
                  '     647MB 2015-05-15 21:03 ' +
                  dirname + "\n" +
                  'drwx------   - testuser users ' +
                  '     647MB 2015-05-15 21:07 ' +
                  subdir  + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-minsize', '500000k', '-ls',
                                   '--filesizeunits', 'si']).run
    end.to output(find_output).to_stdout
  end

  it 'should support IEC units for size' do
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
                        file3name: file3name)

    find_output = 'drwxr-xr-x   - testuser users ' +
                  '    617MiB 2015-05-15 21:03 ' +
                  dirname + "\n" +
                  'drwx------   - testuser users ' +
                  '    617MiB 2015-05-15 21:07 ' +
                  subdir  + "\n" +
                  '-rwxrwxr-x   3 testuser users ' +
                  '    361MiB 2015-05-15 22:28 ' +
                  subdir  + '/' + file3name + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-size', '+360MiB', '-ls',
                                   '--filesizeunits', 'iec']).run
    end.to output(find_output).to_stdout

    find_output = 'drwxr-xr-x   - testuser users ' +
                  '    617MiB 2015-05-15 21:03 ' +
                  dirname + "\n" +
                  'drwx------   - testuser users ' +
                  '    617MiB 2015-05-15 21:07 ' +
                  subdir  + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-minsize', '500000k', '-ls',
                                   '--filesizeunits', 'iec']).run
    end.to output(find_output).to_stdout
  end

  it 'should implement name and path' do
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
                        file3name: file3name)

    find_output = '-rwxrwxr-x   3 testuser users ' +
                  ' 379334628 2015-05-15 22:28 ' +
                  subdir  + '/' + file3name + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-name', 'another*103', '-ls']).run
    end.to output(find_output).to_stdout

    expect do
      HdfsUtils::Find.new('find', [dirname,
                                   '-path',
                                   '*r/t???user/*another?t[es][es]t?103',
                                   '-ls']).run
    end.to output(find_output).to_stdout
  end

  it 'should output an error for a file that does not exist' do
    dirname = '/dir1'
    filename = 'fn1'
    dir2name = 'dir2'
    common_spec_webmock(dirname: dirname,
                        filename: filename,
                        dir2name: dir2name)

    ls_output = "hdfind: /nosuchdir/nosuchfile: No such file or directory\n"

    expect do
      HdfsUtils::Find.new('hdfind', ['/nosuchdir/nosuchfile']).run
    end.to output(ls_output).to_stdout
  end

  it 'should implement depth' do
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
                        file3name: file3name)

    find_output = dirname + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-depth', '0']).run
    end.to output(find_output).to_stdout

    expect do
      HdfsUtils::Find.new('find', [dirname, '-maxdepth', '0']).run
    end.to output(find_output).to_stdout

    expect do
      HdfsUtils::Find.new('find', [dirname, '-depth', '-1']).run
    end.to output(find_output).to_stdout

    # Providing a minimum directory size between the size of
    # the top directory (dirname) and the next level directory
    # (dir2name) should result two lines of output:
    # - the top directory
    # - the file in the top directory
    # The next level directory and the files that are the
    # next level down should be ignored.
    find_output = dirname + "\n" + File.join(dirname, filename) + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname,
                                   '-mindirsize',
                                   '647775800c']).run
    end.to output(find_output).to_stdout

    find_output = dirname + '/' + filename + "\n" +
                  subdir + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-depth', '1']).run
    end.to output(find_output).to_stdout

    find_output = subdir + '/' + file2name + "\n" +
                  subdir + '/' + file3name + "\n"

    expect do
      HdfsUtils::Find.new('find', [dirname, '-depth', '2']).run
    end.to output(find_output).to_stdout

    expect do
      HdfsUtils::Find.new('find', [dirname, '-depth', '+1']).run
    end.to output(find_output).to_stdout

    expect do
      HdfsUtils::Find.new('find', [dirname, '-mindepth', '2']).run
    end.to output(find_output).to_stdout
  end
end
