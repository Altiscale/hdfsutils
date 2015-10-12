#
# Test: webhdfs_mock_spec.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require_relative '../spec_helper'
require_relative 'hdfs_mock'
require_relative 'webhdfs_mock'
require 'settings'
require 'utils/hdfind/find'
require 'utils/hdls/ls'
require 'utils/hdmv/mv'
require 'webhdfs/webhdfs_client'

describe WebhdfsMock::WebhdfsMock do
  include WebhdfsMock

  before(:each) do
    # make an empty underlying mock hdfs before each test
    @mockhdfs = HdfsMock::Hdfs.new
    setup_webhdfs_mock(@mockhdfs)
    settings = HdfsUtils::Settings.new('webhdfs_mock_spec').run([], nil)
    @client = HdfsUtils::WebhdfsClient.new(settings).start
  end

  it 'should support stat on a plain file' do
    @mockhdfs.put('/f', 'some content')
    stat = @client.stat('/f')
    expect(stat['pathSuffix']).to eq('f')
    expect(stat['type']).to eq('FILE')
  end

  it 'should support stat on a directory' do
    @mockhdfs.mkdir('/d')
    stat = @client.stat('/d')
    expect(stat['pathSuffix']).to eq('d')
    expect(stat['type']).to eq('DIRECTORY')
    expect(stat['childrenNum']).to eq(0)
  end

  it 'should throw if statting a file that does not exist' do
    expect { @mockhdfs.get_node('/foo') }
      .to raise_error(HdfsMock::Hdfs::FileNotFoundError)
    expect { @client.stat('/foo') }
      .to raise_error(WebHDFS::FileNotFoundError)
  end

  it 'should support list' do
    @mockhdfs.mkdir('/d')
    @mockhdfs.put('/d/f1', 'some content')
    @mockhdfs.put('/d/f2', 'other content')
    list = @client.list('/d')
    expect(list.is_a? Array).to be_truthy
    expect(list.length).to eq(2)
  end

  it 'should support delete' do
    @mockhdfs.put('/f', 'some content')
    @client.delete('/f')
    expect { @client.stat('/f') }
      .to raise_error(WebHDFS::FileNotFoundError)
  end

  it 'should support rename' do
    @mockhdfs.put('/f', 'some content')
    @client.rename('/f', '/g')
    expect { @client.stat('/f') }
      .to raise_error(WebHDFS::FileNotFoundError)
    stat = @client.stat('/g')
    expect(stat['pathSuffix']).to eq('g')
    expect(stat['type']).to eq('FILE')
  end
end

# it should support blue-sky cases for all utilities

describe HdfsUtils::Ls do
  include WebhdfsMock

  it 'should work with WebhdfsMock' do
    mockhdfs = HdfsMock::Hdfs.new
    mockhdfs.mkdir('/source')
    mockhdfs.mkdir('/source/c')
    mockhdfs.mkdir('/source/a')
    mockhdfs.put('/source/b', 'this is content')
    setup_webhdfs_mock(mockhdfs)

    ls_output = <<EOS
a
b
c
EOS

    expect do
      HdfsUtils::Ls.new('ls', ['--log-level', 'debug', '/source']).run
    end.to output(ls_output).to_stdout
  end
end

describe HdfsUtils::Find do
  include WebhdfsMock

  it 'should work with WebhdfsMock' do
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

describe HdfsUtils::Mv do
  include WebhdfsMock

  it 'should work with WebhdfsMock' do
    mockhdfs = HdfsMock::Hdfs.new
    mockhdfs.mkdir('/a')
    mockhdfs.put('/a/bar.txt', 'now is the time')
    setup_webhdfs_mock(mockhdfs)

    HdfsUtils::Mv.new('hdmv',
                      ['/a/bar.txt', '/a/foo.txt']).run

    ls_output = <<EOS
foo.txt
EOS

    expect do
      HdfsUtils::Ls.new('hdls',
                        ['/a']).run
    end.to output(ls_output).to_stdout
  end
end
