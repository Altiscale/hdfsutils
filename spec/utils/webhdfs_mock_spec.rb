#
# Test: TBD
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require_relative '../spec_helper'
require_relative 'hdfs_mock'
require_relative 'webhdfs_mock'
require 'utils/hdfind/find'

describe WebhdfsMock::WebhdfsMock do
  it 'should support stat' do
    mockhdfs = HdfsMock::Hdfs.new
    mockhdfs.mkdir('/source')
    subject = WebhdfsMock::WebhdfsMock.new(mockhdfs)
    stat = subject.stat('/source')
    expect(stat).not_to be_nil
  end
end

describe HdfsUtils::Find do
  include WebhdfsMock

  it 'should do something interesting' do
    mockhdfs = HdfsMock::Hdfs.new
    mockhdfs.mkdir('/source')
    mockhdfs.mkdir('/source/a')
    mockhdfs.mkdir('/source/a/b')
    mockhdfs.put('/source/a/b/bar.txt', 'now is the time')
    mockhdfs.put('/source/a/b/foo.txt', 'now is not the time')
    mockhdfs.mkdir('/source/a/c')
    mockhdfs.put('/source/a/c/baz.txt', 'this is another time')
    setup_webhdfs_mock(mockhdfs)

    find_output = <<EOS
/
/source
/source/a
/source/a/b
/source/a/b/bar.txt
/source/a/b/foo.txt
/source/a/c
/source/a/c/baz.txt
EOS

    expect do
      HdfsUtils::Find.new('find', ['--log-level', 'debug', '/']).run
    end.to output(find_output).to_stdout
  end
end
