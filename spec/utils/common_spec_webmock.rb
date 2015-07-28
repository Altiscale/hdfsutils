#
# Library: common_spec_webmock.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Provides webmock resources for testing utilities.
#

#
# webmocks common to multiple tests.
#
module CommonSpecWebmock
  def common_spec_webmock(options)
    root_stat
    dir_stat
    file_stat(options[:filename])
    dir2_stat(options[:dir2name])
    dir_list
    if options[:file2name]
      file2_stat(options[:file2name])
      file3_stat(options[:file3name])
      dir2_list
    end
    urls_and_header(options)
    setup_environment
    stub_requests(options)
  end

  def root_stat
    @root_stat = {
      'FileStatus' => {
        'accessTime' => 0,
        'blockSize' => 0,
        'childrenNum' => 10,
        'fileId' => 16_386,
        'group' => 'hdfs',
        'length' => 0,
        'modificationTime' => 1_433_791_576_835,
        'owner' => 'hdfs',
        'pathSuffix' => '',
        'permission' => '755',
        'replication' => 0,
        'type' => 'DIRECTORY'
      }
    }
  end

  def dir_stat
    @dir_stat = {
      'FileStatus' => {
        'accessTime' => 0,
        'blockSize' => 0,
        'childrenNum' => 2,
        'fileId' => 16_580,
        'group' => 'users',
        'length' => 0,
        'modificationTime' => 1_431_723_784_561,
        'owner' => 'testuser',
        'pathSuffix' => '',
        'permission' => '755',
        'replication' => 0,
        'type' => 'DIRECTORY'
      }
    }
  end

  def file_stat(filename)
    @file_stat = {
      'accessTime' => 1_435_870_426_079,
      'blockSize' => 268_435_456,
      'childrenNum' => 0,
      'fileId' => 17_199,
      'group' => 'users',
      'length' => 5812,
      'modificationTime' => 1_431_723_840_094,
      'owner' => 'testuser',
      'pathSuffix' => filename,
      'permission' => '775',
      'replication' => 3,
      'type' => 'FILE'
    }
  end

  def file2_stat(filename)
    @file2_stat = {
      'accessTime' => 1_435_870_426_079,
      'blockSize' => 268_435_456,
      'childrenNum' => 0,
      'fileId' => 17_200,
      'group' => 'users',
      'length' => 268_435_456,
      'modificationTime' => 1_431_723_141_592,
      'owner' => 'testuser',
      'pathSuffix' => filename,
      'permission' => '775',
      'replication' => 3,
      'type' => 'FILE'
    }
  end

  def file3_stat(filename)
    @file3_stat = {
      'accessTime' => 1_435_870_426_079,
      'blockSize' => 268_435_456,
      'childrenNum' => 0,
      'fileId' => 17_201,
      'group' => 'users',
      'length' => 379_334_628,
      'modificationTime' => 1_431_728_886_662,
      'owner' => 'testuser',
      'pathSuffix' => filename,
      'permission' => '775',
      'replication' => 3,
      'type' => 'FILE'
    }
  end

  def dir2_stat(dir2name)
    @dir2_stat = {
      'accessTime' => 0,
      'blockSize' => 0,
      'childrenNum' => 0,
      'fileId' => 17_175,
      'group' => 'users',
      'length' => 0,
      'modificationTime' => 1_431_724_020_397,
      'owner' => 'testuser',
      'pathSuffix' => dir2name,
      'permission' => '700',
      'replication' => 0,
      'type' => 'DIRECTORY'
    }
  end

  def dir_list
    @dir_list = {
      'FileStatuses' => {
        'FileStatus' => [
          @file_stat,
          @dir2_stat
        ]
      }
    }
  end

  def dir2_list
    @dir2_list = {
      'FileStatuses' => {
        'FileStatus' => [
          @file2_stat,
          @file3_stat
        ]
      }
    }
  end

  def urls_and_header(options)
    dirname = options[:dirname]
    @ctheader = { 'Content-Type' => 'application/json' }

    @hostname = 'nn-cluster.nsdc.altiscale.com'
    @port = '50070'
    @username = 'testuser'

    @testrooturl = 'http://' + @hostname + ':' + @port +
                   '/webhdfs/v1/?op=GETFILESTATUS&user.name=' +
                   @username

    @testdirurl = 'http://' + @hostname + ':' + @port +
                  '/webhdfs/v1' + dirname +
                  '?op=GETFILESTATUS&user.name=' +
                  @username

    @testlisturl = 'http://' + @hostname + ':' + @port +
                   '/webhdfs/v1' + dirname +
                   '?op=LISTSTATUS&user.name=' +
                   @username

    return unless options[:file2name]

    @testlist2url = 'http://' + @hostname + ':' + @port +
                    '/webhdfs/v1' + options[:dirname] + '/' +
                    options[:dir2name] +
                    '?op=LISTSTATUS&user.name=' +
                    @username
  end

  def stub_requests(options)
    stub_request(:get, @testrooturl)
      .to_return(body: JSON.generate(@root_stat),
                 headers: @ctheader)

    stub_request(:get, @testdirurl)
      .to_return(body: JSON.generate(@dir_stat),
                 headers: @ctheader)

    stub_request(:get, @testlisturl)
      .to_return(body: JSON.generate(@dir_list),
                 headers: @ctheader)

    return unless options[:file2name]

    stub_request(:get, @testlist2url)
      .to_return(body: JSON.generate(@dir2_list),
                 headers: @ctheader)
  end

  def setup_environment
    ENV['HDFS_HOST'] = @hostname
    ENV['HDFS_PORT'] = @port
    ENV['HDFS_USERNAME'] = @username
  end
end
