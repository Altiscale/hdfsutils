#
# Library: hdfs_mock.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0

#
# Mock hdfs for testing
#
module HdfsMock
  #
  # Mock hdfs for testing
  #
  class Hdfs
    public

    class Error < StandardError; end
    class FileNotFoundError < Error; end
    class FileExistsError < Error; end

    def initialize
      @file_id = 0
      @block_size = 0
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
      fail FileNotFoundError, path unless node
      node[:content]
    end

    def delete(path)
      parent, base = get_parent(path)
      child = parent[:children][base]
      fail FileNotFoundError unless child
      parent[:children].delete(base)
    end

    def rename(sourcepath, destpath)
      sourceparent, sourcebase = get_parent(sourcepath)
      child = sourceparent[:children][sourcebase]
      fail FileNotFoundError, sourcepath unless child
      destparent, destbase = get_parent(destpath)
      fail FileExistsError, destpath if destparent[:children][destbase]
      sourceparent[:children].delete(sourcebase)
      destparent[:children][destbase] = child
      child[:pathSuffix] = destbase
    end

    def get_node(path)
      node = resolve_path(split_path(path))
      fail FileNotFoundError, path unless node
      node
    end

    private

    def get_parent(path)
      patharray = split_path(path)
      parent = patharray[0..-2]
      base = patharray[-1]
      #      puts "parent #{parent} base #{base}"
      node = resolve_path(parent)
      fail FileNotFoundError, path unless node
      [node, base]
    end

    def split_path(path)
      # the root directory needs special treatment
      return [] if path == '/'
      path = path[1..-1] if path[0] = '/'
      path.split('/')
    end

    def mkemptydir(basename)
      @file_id += 1
      {
        accessTime: @now, blockSize: @block_size, children: {},
        fileId: @file_id, group: @group, length: 0,
        modificationTime: @now, owner: @owner, pathSuffix: basename,
        permission: @permissions, replication: @replication,
        type: 'DIRECTORY'
      }
    end

    def mkfile(basename, content)
      @file_id += 1
      {
        accessTime: @now, blockSize: @block_size,
        fileId: @file_id, group: @group, length: 0,
        modificationTime: @now, owner: @owner, pathSuffix: basename,
        permission: @permissions, replication: @replication,
        type: 'FILE', content: content
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
