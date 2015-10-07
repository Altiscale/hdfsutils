#
# Utility: implementation.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

#
# This module implements mv.
#
module MvImplementation
  #
  # The eponymous function moves a list of sources to a target
  #
  def mv(target, sources)
    stat = nil
    begin
      stat = @client.stat(target)
    # rubocop:disable Lint/HandleExceptions
    rescue WebHDFS::FileNotFoundError
      # fall through, leave stat = nil
    end
    # rubocop:enable Lint/HandleExceptions
    target_exists = stat ? true : false
    if target_exists && stat['type'] == 'DIRECTORY'
      mv_to_dir(target, sources)
      return
    end
    fail "target `#{target}' is not a directory" if sources.length > 1
    mv_to_file(target, sources[0])
  end

  #
  # mv any number of sources to an existing directory
  #
  def mv_to_dir(dir, sources)
    sources.each do |src_file|
      dst_file = "#{dir}/#{File.basename(src_file)}"
      mv_to_file(dst_file, src_file)
    end
  end

  #
  # mv a single source to a non-directory target
  #
  def mv_to_file(target, source)
    # Check whether the source file exists
    begin
      stat = @client.stat(source)
    rescue WebHDFS::FileNotFoundError
      raise "source #{source} does not exist"
    end
    
    # Check whether the target file exists
    stat = nil
    begin
      stat = @client.stat(target)
    rescue WebHDFS::FileNotFoundError
      # fall through, leave stat = nil
    end
    target_exist = stat ? true : false

    if target_exist 
      overwrite = !@settings.no_overwrite
      #if @settings.interactive
      #  puts "overwrite #{target}? (y/n [n])"
      #  overwrite = gets
      #end
      if @settings.force || overwrite
        @client.delete(target)
        mv_file(target, source)
      end
    else
      mv_file(target, source)
    end
  end

  def mv_file(target, source)
    @client.rename(source, target)
    if @settings.verbose
      puts "#{source} -> #{target}"
    end
  end
end
