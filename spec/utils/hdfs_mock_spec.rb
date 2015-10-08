#
# Test: hdfs_mock.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require_relative '../spec_helper'
require_relative 'hdfs_mock'

describe HdfsMock::Hdfs do
  it 'should be initially empty' do
    stat = subject.stat('/')
    expect(stat).not_to be_nil
    expect(stat['FileStatus']['childrenNum']).to eq(0)
    expect(stat['FileStatus']['type']).to eq('DIRECTORY')
  end

  it 'should support mkdir' do
    subject.mkdir('/foo')
    stat = subject.stat('/foo')
    expect(stat).not_to be_nil
    expect(stat['FileStatus']['childrenNum']).to eq(0)
    expect(stat['FileStatus']['pathSuffix']).to eq('foo')
    stat = subject.stat('/')
    expect(stat['FileStatus']['childrenNum']).to eq(1)
    subject.mkdir('/bar')
    stat = subject.stat('/')
    expect(stat['FileStatus']['childrenNum']).to eq(2)
  end

  it 'should support put' do
    subject.put('/foo', 'now is the time')
    stat = subject.stat('/foo')
    expect(stat).not_to be_nil
    expect(stat['FileStatus']['childrenNum']).to eq(0)
    expect(stat['FileStatus']['pathSuffix']).to eq('foo')
    expect(stat['FileStatus']['type']).to eq('FILE')
    content = subject.get('/foo')
    expect(content).to eq('now is the time')
  end

  it 'should support ls' do
    subject.mkdir('/source')
    lsstat = subject.ls('/source')
    expect(lsstat['FileStatuses']['FileStatus'].length).to eq(0)

    subject.mkdir('/source/a')
    stat = subject.stat('/source/a')
    expect(stat['FileStatus']['childrenNum']).to eq(0)

    subject.mkdir('/source/a/b')
    subject.put('/source/a/b/bar.txt', 'now is the time')
    subject.put('/source/a/b/foo.txt', 'now is not the time')
    stat = subject.stat('/source/a/b')
    expect(stat['FileStatus']['childrenNum']).to eq(2)
    lsstat = subject.ls('/source/a/b')
    expect(lsstat['FileStatuses']['FileStatus'].length).to eq(2)
    expect(lsstat['FileStatuses']['FileStatus'].map { |s| s['pathSuffix'] }).to eq(['bar.txt', 'foo.txt'])
  end
end
