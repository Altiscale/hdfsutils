# Test: hdfs_mock_spec.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require_relative '../spec_helper'
require_relative 'hdfs_mock'

describe HdfsMock::Hdfs do
  it 'should initially have only a root' do
    node = subject.get_node('/')
    expect(node).not_to be_nil
    expect(node[:children].size).to eq(0)
    expect(node[:type]).to eq('DIRECTORY')
  end

  it 'should support mkdir' do
    subject.mkdir('/foo')
    node = subject.get_node('/foo')
    expect(node).not_to be_nil
    expect(node[:children].size).to eq(0)
    expect(node[:pathSuffix]).to eq('foo')
    node = subject.get_node('/')
    expect(node[:children].size).to eq(1)
    subject.mkdir('/bar')
    node = subject.get_node('/')
    expect(node[:children].size).to eq(2)
  end

  it 'should support put' do
    subject.put('/foo', 'now is the time')
    node = subject.get_node('/foo')
    expect(node).not_to be_nil
    expect(node[:children]).to be_nil
    expect(node[:pathSuffix]).to eq('foo')
    expect(node[:type]).to eq('FILE')
  end

  it 'should support get' do
    subject.put('/foo', 'now is the time')
    content = subject.get('/foo')
    expect(content).to eq('now is the time')
  end

  it 'should support delete for a file' do
    subject.put('/foo', 'now is the time')
    subject.delete('/foo')
    expect { subject.get_node('/foo') }
      .to raise_error(HdfsMock::Hdfs::FileNotFoundError)
  end

  it 'should support delete for a directory' do
    subject.mkdir('/foo')
    subject.delete('/foo')
    expect { subject.get_node('/foo') }
      .to raise_error(HdfsMock::Hdfs::FileNotFoundError)
  end

  it 'should support rename for a file' do
    subject.put('/foo', 'now is the time')
    subject.rename('/foo', '/bar')
    expect { subject.get_node('/foo') }
      .to raise_error(HdfsMock::Hdfs::FileNotFoundError)
    content = subject.get('/bar')
    expect(content).to eq('now is the time')
  end

  it 'should support rename for a directory' do
    subject.mkdir('/foo')
    subject.rename('/foo', '/bar')
    expect { subject.get_node('/foo') }
      .to raise_error(HdfsMock::Hdfs::FileNotFoundError)
    expect(subject.get_node('/bar')).not_to be_nil
  end
end
