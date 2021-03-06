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
      file3_stat(options[:file3name],
                 options[:file3atime],
                 options[:file3mtime])
      dir2_list
      dir2_cs
    end
    dir_cs
    header
    urls(options)
    more_urls(options)
    setup_environment(options)
    stub_requests(options)
    stub_404_request
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
      'blockSize' => 1_268_435_456,
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
      'accessTime' => 1_435_870_428_982,
      'blockSize' => 268_435_456,
      'childrenNum' => 0,
      'fileId' => 17_200,
      'group' => 'hiveusers',
      'length' => 268_435_456,
      'modificationTime' => 1_431_723_141_592,
      'owner' => 'testuser',
      'pathSuffix' => filename,
      'permission' => '775',
      'replication' => 3,
      'type' => 'FILE'
    }
  end

  def file3_stat(filename, atime, mtime)
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
    # rubocop:disable Style/GuardClause
    if atime
      @file3_stat['accessTime'] = (atime.tv_sec * 1000) +
                                  (atime.tv_usec / 1000)
    end
    if mtime
      @file3_stat['modificationTime'] = (mtime.tv_sec * 1000) +
                                        (mtime.tv_usec / 1000)
    end
    # rubocop:enable Style/GuardClause
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

  def dir_cs
    size =  @file_stat['length']
    count = 1
    if @file2_stat
      size += @file2_stat['length']
      count += 1
    end
    if @file3_stat
      size += @file3_stat['length']
      count += 1
    end
    @dir_cs = {
      'ContentSummary' => {
        'directoryCount' => 2,
        'fileCount' => count,
        'length' => size,
        'quota' => -1,
        'spaceConsumed' => size * 3,
        'spaceQuota' => -1
      }
    }
  end

  def dir2_cs
    size = @file2_stat['length'] + @file3_stat['length']
    @dir2_cs = {
      'ContentSummary' => {
        'directoryCount' => 1,
        'fileCount' => 2,
        'length' => size,
        'quota' => -1,
        'spaceConsumed' => size * 3,
        'spaceQuota' => -1
      }
    }
  end

  def header
    @ctheader = { 'Content-Type' => 'application/json' }

    @hostname = 'nn-cluster.nsdc.altiscale.com'
    @port = '50070'
    @username = 'testuser'
  end

  def urls(options)
    dirname = URI.escape(options[:dirname])
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

    @testdircsurl = 'http://' + @hostname + ':' + @port +
                    '/webhdfs/v1' + dirname +
                    '?op=GETCONTENTSUMMARY&user.name=' +
                    @username
  end

  def more_urls(options)
    return unless options[:file2name]

    @testlist2url = 'http://' + @hostname + ':' + @port +
                    '/webhdfs/v1' + options[:dirname] + '/' +
                    options[:dir2name] +
                    '?op=LISTSTATUS&user.name=' +
                    @username

    @testdir2csurl = 'http://' + @hostname + ':' + @port +
                     '/webhdfs/v1' + options[:dirname] + '/' +
                     options[:dir2name] +
                     '?op=GETCONTENTSUMMARY&user.name=' +
                     @username
  end

  def check_unescaped_path(response_stat)
    lambda do |request|
      path = request.uri.path.to_s
      # Verify fix to webhdfs that escapes URI characters.
      # In webhdfs gem versions 0.6.0 and lower, special
      # characters in the path were not escaped.  A patch from
      # Altiscale fixed this issue in versions 0.7.0 and higher.
      if path.include?('{') || path.include?('}')
        { body: "ERROR: unescaped character in #{path}",
          headers: @ctheader
        }
      else
        { body: JSON.generate(response_stat),
          headers: @ctheader
        }
      end
    end
  end

  def stub_requests(options)
    stub_request(:get, @testrooturl)
      .to_return(body: JSON.generate(@root_stat),
                 headers: @ctheader)

    stub_request(:get, @testdirurl)
      .to_return(check_unescaped_path(@dir_stat))

    stub_request(:get, @testdircsurl)
      .to_return(body: JSON.generate(@dir_cs),
                 headers: @ctheader)

    stub_request(:get, @testlisturl)
      .to_return(body: JSON.generate(@dir_list),
                 headers: @ctheader)

    return unless options[:file2name]

    stub_request(:get, @testlist2url)
      .to_return(body: JSON.generate(@dir2_list),
                 headers: @ctheader)

    stub_request(:get, @testdir2csurl)
      .to_return(body: JSON.generate(@dir2_cs),
                 headers: @ctheader)
  end

  def stub_404_request
    test404url = 'http://' + @hostname + ':' + @port +
                 '/webhdfs/v1/nosuchdir/nosuchfile' +
                 '?op=GETFILESTATUS&user.name=' +
                 @username

    stub_request(:get, test404url).to_return(status: 404)
  end

  def setup_environment(options)
    ENV['HDFS_HOST'] = @hostname
    ENV['HDFS_PORT'] = @port
    ENV.delete('HDFS_USERNAME')
    ENV.delete('HADOOP_USER_NAME')
    env_username = options[:env_username] || 'HDFS_USERNAME'
    ENV[env_username] = @username
  end
end
