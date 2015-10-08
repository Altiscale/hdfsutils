#
# Library: webmock_using_hdfs_mock.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Provides webmock resources for testing utilities.
#

#
# webmock for dynamic hdfs mock
#
module WebmockUsingHdfsMock
  require 'addressable/template'

  public

  def webmock_using_hdfs_mock(mockhdfs)
    @mockhdfs = mockhdfs
    header
    setup_environment
    @general_t = Addressable::Template.new "http://#{@host}:#{@port}" +
      '/webhdfs/v1{/segments*}?op={op}&user.name={user}'
    stub_liststatus
    stub_getfilestatus
    stub_delete
    stub_rename
  end

  private

  def header
    @ctheader = { 'Content-Type' => 'application/json' }

    @host = 'nn-cluster.nsdc.altiscale.com'
    @port = '50070'
    @username = 'testuser'
  end

  def parse_request(request)
    uri = Addressable::URI.parse request.uri
    e = @general_t.extract(uri)
    '/' + e['segments'].join('/')
  end

  def parse_rename_request(request)
    uri = Addressable::URI.parse request.uri
    e = @rename_t.extract(uri)
    source = '/' + e['segments'].join('/')
    dest = '/' + e['destination'].join('/')
    [source, dest]
  end

  def stub_liststatus
    liststatus_t = Addressable::Template.new "http://#{@host}:#{@port}" +
      '/webhdfs/v1{/segments*}?op=LISTSTATUS&user.name={user}'
    stub_request(:get, liststatus_t)
      .to_return(body: lambda do |request|
                         hdfs_path = parse_request(request)
                         JSON.generate(@mockhdfs.ls(hdfs_path))
                       end,
                 headers: @ctheader)
  end

  def stub_getfilestatus
    getfilestatus_t = Addressable::Template.new "http://#{@host}:#{@port}" +
      '/webhdfs/v1{/segments*}?op=GETFILESTATUS&user.name={user}'
    stub_request(:get, getfilestatus_t)
      .to_return(body: lambda do |request|
                         hdfs_path = parse_request request
                         JSON.generate(@mockhdfs.stat(hdfs_path))
                       end,
                 headers: @ctheader)
  end

  def stub_delete
    delete_t = Addressable::Template.new "http://#{@host}:#{@port}" +
      '/webhdfs/v1{/segments*}?op=DELETE&user.name={user}'
    stub_request(:delete, delete_t)
      .to_return(body: lambda do |request|
                         hdfs_path = parse_request request
                         JSON.generate(@mockhdfs.delete(hdfs_path))
                       end,
                 headers: @ctheader)
  end

  def stub_rename
    @rename_t = Addressable::Template.new "http://#{@host}:#{@port}" +
      '/webhdfs/v1{/segments*}?destination={/destination*}&op=RENAME' +
      '&user.name={user}'
    stub_request(:put, @rename_t)
      .to_return(body: lambda do |request|
                         source, dest = parse_rename_request request
                         JSON.generate(@mockhdfs.rename(source, dest))
                       end,
                 headers: @ctheader)
  end

  def setup_environment
    ENV['HDFS_HOST'] = @host
    ENV['HDFS_PORT'] = @port
    ENV['HDFS_USERNAME'] = @username
  end
end
