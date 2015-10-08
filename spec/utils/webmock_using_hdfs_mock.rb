#
# Library: tbd
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Provides webmock resources for testing utilities.
#

#
# TBD
#

require 'addressable/template'

module WebmockUsingHdfsMock
  def webmock_using_hdfs_mock(mockhdfs)
    @mockhdfs = mockhdfs
    header
    setup_environment
    stub_requests
    stub_404_request
  end

  def header
    @ctheader = { 'Content-Type' => 'application/json' }

    @hostname = 'nn-cluster.nsdc.altiscale.com'
    @port = '50070'
    @username = 'testuser'
  end

  def parse_request(request)
    uri = Addressable::URI.parse request.uri
    e = @general_template.extract(uri)
    '/' + e['segments'].join('/')
  end

  def parse_rename_request(request)
    uri = Addressable::URI.parse request.uri
    e = @rename_template.extract(uri)
    source = '/' + e['segments'].join('/')
    dest = '/' + e['destination'].join('/')
    [source, dest]
  end

  def stub_requests
    @general_template = Addressable::Template.new "http://#{@hostname}:#{@port}/webhdfs/v1{/segments*}?op={op}&user.name={user}"

    liststatus_template = Addressable::Template.new "http://#{@hostname}:#{@port}/webhdfs/v1{/segments*}?op=LISTSTATUS&user.name={user}"
    stub_request(:get, liststatus_template).to_return(body: lambda do |request|
                                                              hdfs_path = parse_request(request)
                                                              JSON.generate(@mockhdfs.ls(hdfs_path))
                                                            end,
                                                      headers: @ctheader)

    getfilestatus_template = Addressable::Template.new "http://#{@hostname}:#{@port}/webhdfs/v1{/segments*}?op=GETFILESTATUS&user.name={user}"
    stub_request(:get, getfilestatus_template).to_return(body: lambda do |request|
                                                                 hdfs_path = parse_request request
                                                                 JSON.generate(@mockhdfs.stat(hdfs_path))
                                                               end,
                                                         headers: @ctheader)

    # delete_template = Addressable::Template.new "http://#{@hostname}:#{@port}/webhdfs/v1{/segments*}?op=DELETE&user.name={user}"
    # stub_request(:delete, delete_template).to_return(body: lambda do |request|
    #                                                    hdfs_path = parse_request request
    #                                                    JSON.generate(@mockhdfs.delete(hdfs_path))
    #                                                  end,
    #                                                  headers: @ctheader)

    @rename_template = Addressable::Template.new "http://#{@hostname}:#{@port}/webhdfs/v1{/segments*}?destination={/destination*}&op=RENAME&user.name={user}"
    stub_request(:put, @rename_template).to_return(body: lambda do |request|
                                                           hdfs_source_path, hdfs_dest_path  = parse_rename_request request
                                                           JSON.generate(@mockhdfs.rename(hdfs_source_path, hdfs_dest_path))
                                                         end,
                                                   headers: @ctheader)

    #       stub_request(:put, "http://nn-cluster.nsdc.altiscale.com:50070/webhdfs/v1/a/bar.txt?destination=/a/foo.txt&op=RENAME&user.name=testuser").

    #       stub_request(:put, "http://nn-cluster.nsdc.altiscale.com:50070/webhdfs/v1/a/bar.txt?destination=/a/foo.txt&op=RENAME&user.name=testuser").

    #     stub_request(:delete, getfilestatus_template).to_return(body: lambda do |request|
    #                                                               hdfs_path = parse_request request
    #                                                               JSON.generate(@mockhdfs.stat(hdfs_path))
    #                                                             end,
    #                                                             headers: @ctheader)

    # http://nn-cluster.nsdc.altiscale.com:50070/webhdfs/v1/a/bar.txt?op=DELETE&user.name=testuser
  end

  def stub_404_request
    test404url = 'http://' + @hostname + ':' + @port +
                 '/webhdfs/v1/nosuchdir/nosuchfile' +
                 '?op=GETFILESTATUS&user.name=' +
                 @username

    stub_request(:get, test404url).to_return(status: 404)
  end

  def setup_environment
    ENV['HDFS_HOST'] = @hostname
    ENV['HDFS_PORT'] = @port
    ENV['HDFS_USERNAME'] = @username
  end
end
