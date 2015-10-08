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
    if @settings.overlay
      sources.each do |source|
        source_stat = target_stat = nil
        begin
          source_stat = @client.stat(source)
          target_stat = @client.stat(target)
          #puts "source #{source_stat['type']}"
          #puts "target #{target_stat['type']}"

          raise "Usage: hdmv [source_directory] [target_directory] --overlay" \
            unless source_stat['type'] == 'DIRECTORY' && target_stat['type'] == 'DIRECTORY'
        rescue WebHDFS::FileNotFoundError
          raise "Usage: hdmv [source_directory] [target_directory] --overlay"
        end
        mv_suboverlay(target, source)
      end
    else
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
  end

  def mv_suboverlay(parent_target, parent_source)
    # get list of source
    source_files = target_files = nil
    begin
      source_files = @client.list(parent_source)
      #files.each do |file|
      #  puts "file: #{file['type']}, #{file['pathSuffix']}" 
      #end
    rescue WebHDFS::FileNotFoundError
      raise "source is wrong #{parent_source}"  
    end
    begin
      target_files = @client.list(parent_target)
    rescue WebHDFS::FileNotFoundError
      raise "target is wrong #{parent_target}"  
    end
    # get list of target
    source_files.each do |source|
      isFound = false
      target_files.each do |target|
        if source['pathSuffix'] == target['pathSuffix']
          if source['type'] != target['type']
            puts "ERROR: source(#{source['pathSuffix']}) and target(#{target['pathSuffix']}) has different type"
          else
            isFound = true
            source_name = "#{parent_source}/#{source['pathSuffix']}"
            target_name = "#{parent_target}/#{target['pathSuffix']}"
            if source['type'] == 'DIRECTORY'
              #puts "mv_suboverlay(#{target_name}, #{source_name})"
              mv_suboverlay(target_name, source_name)
            else
              #puts "mv_to_file(#{target_name}, #{source_name})"
              mv_to_file(target_name, source_name)
            end
          end
        end
      end
      if isFound == false
        source_name = "#{parent_source}/#{source['pathSuffix']}"
        target_name = "#{parent_target}/#{source['pathSuffix']}"
        #puts "mv_to_file(#{target_name}, #{source_name})"
        mv_to_file(target_name, source_name)
      end
    end
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
      #if @settings.interactive
      #  puts "overwrite #{target}? (y/n [n])"
      #  overwrite = gets
      #end
      if @settings.force && !@settings.no_overwrite
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
