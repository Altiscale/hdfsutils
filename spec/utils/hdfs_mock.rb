#
# Library: common_spec_webmock.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Mock hdfs for testing
#

require 'webhdfs'
module HdfsMock
  class Hdfs
    public

    def initialize
      @fileId = 0
      @blockSize = 0
      @group = 'hdfs'
      @now = 0
      @owner = 'testuser'
      @permissions = 755
      @replication = 0
      @hash = mkemptydir('')
    end

    def mkdir(path)
      parent, base = get_parent(path)
      child = mkemptydir(base)
      # puts "parent #{parent} child #{child}"
      parent[:children][base] = child
    end

    def put(path, content)
      parent, base = get_parent(path)
      child = mkfile(base, content)
      parent[:children][base] = child
    end

    def get(path)
      node = resolve_path(split_path(path))
      fail WebHDFS::FileNotFoundError unless node
      node[:content]
    end

    def delete(path)
      parent, base = get_parent(path)
      child = parent[:children][base]
      fail WebHDFS::FileNotFoundError unless child
      parent[:children].delete(base)
    end

    def rename(sourcepath, destpath)
      sourceparent, sourcebase = get_parent(sourcepath)
      child = sourceparent[:children][sourcebase]
      fail WebHDFS::FileNotFoundError unless child
      destparent, destbase = get_parent(destpath)
      fail WebHDFS::Error if destparent[:children][destbase]
      sourceparent[:children].delete(sourcebase)
      destparent[:children][destbase] = child
      child[:pathSuffix] = destbase
      {}
    end

    def stat(path)
      node = resolve_path(split_path(path))
      fail WebHDFS::FileNotFoundError unless node
      mkstat(node)
    end

    def ls(path)
      #      puts "@hash = #{@hash}"
      node = resolve_path(split_path(path))
      fail WebHDFS::FileNotFoundError unless node
      mklsstat(node)
    end

    private

    def get_parent(path)
      patharray = split_path(path)
      parent = patharray[0..-2]
      base = patharray[-1]
      #      puts "parent #{parent} base #{base}"
      node = resolve_path(parent)
      fail WebHDFS::FileNotFoundError unless node
      fail WebHDFS::Error unless node[:type] == 'DIRECTORY'
      # raise WebHDFS::Error if node[:children][base]
      [node, base]
    end

    def split_path(path)
      # the root directory needs special treatment
      return [] if path == '/'
      path = path[1..-1] if path[0] = '/'
      path.split('/')
    end

    def mkemptydir(basename)
      @fileId = @fileId + 1
      {
        accessTime: @now,
        blockSize: @blockSize,
        children: {},
        fileId: @fileId,
        group: @group,
        length: 0,
        modificationTime: @now,
        owner: @owner,
        pathSuffix: basename,
        permission: @permissions,
        replication: @replication,
        type: 'DIRECTORY'
      }
    end

    def mkfile(basename, content)
      @fileId = @fileId + 1
      {
        accessTime: @now,
        blockSize: @blockSize,
        children: nil,
        fileId: @fileId,
        group: @group,
        length: 0,
        modificationTime: @now,
        owner: @owner,
        pathSuffix: basename,
        permission: @permissions,
        replication: @replication,
        type: 'FILE',
        content: content
      }
    end

    def mkstat(node)
      {
        'FileStatus' => mk_single_stat(node)
      }
    end

    def mk_single_stat(node)
      {
        'accessTime' => node[:accessTime],
        'blockSize' => node[:blockSize],
        'childrenNum' => node[:children] ? node[:children].size : 0,
        'fileId' => node[:fileId],
        'group' => node[:group],
        'length' => node[:length],
        'modificationTime' => node[:modificationTime],
        'owner' => node[:owner],
        'pathSuffix' => node[:pathSuffix],
        'permission' => node[:permission],
        'replication' => node[:replication],
        'type' => node[:type]
      }
    end

    def mklsstat(node)
      {
        'FileStatuses' => {
          'FileStatus' => node[:children].values.map { |n| mk_single_stat(n) }
        }
      }
    end

    def resolve_path(patharray)
      node = @hash
      patharray.each do |n|
        return nil if node[:type] == 'FILE'
        node = node[:children][n]
        return nil unless node
      end
      node
    end
  end
end
