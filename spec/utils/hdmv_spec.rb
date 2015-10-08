#
# Test: hdls_spec.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require_relative '../spec_helper'
require_relative 'hdfs_mock'
require_relative 'webmock_using_hdfs_mock'
require 'utils/hdmv/mv'
require 'utils/hdls/ls'

describe HdfsUtils::Mv do
  include WebmockUsingHdfsMock

  it 'should move a simple file to another simple file' do
    mockhdfs = HdfsMock::Hdfs.new
    mockhdfs.mkdir('/a')
    mockhdfs.put('/a/bar.txt', 'now is the time')
    webmock_using_hdfs_mock(mockhdfs)

    mv_output = <<EOS
/a/bar.txt -> /a/foo.txt
EOS

    expect do
      HdfsUtils::Mv.new('hdmv',
                        ['-v', '/a/bar.txt', '/a/foo.txt']).run
    end.to output(mv_output).to_stdout

    ls_output = <<EOS
foo.txt
EOS

    expect do
      HdfsUtils::Ls.new('hdls',
                        ['/a']).run
    end.to output(ls_output).to_stdout
  end
end
