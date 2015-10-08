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
require "highline/import"
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
    # get list of source and target
    source_files = target_files = nil
    begin
      source_files = @client.list(parent_source)
    rescue WebHDFS::FileNotFoundError
      raise "ERROR: source(#{parent_source}) does not exist"  
    end
    begin
      target_files = @client.list(parent_target)
    rescue WebHDFS::FileNotFoundError
      raise "ERROR: target(#{parent_target}) does not exist"  
    end

    source_files.each do |source_stat|
      isFound = false
      target_files.each do |target_stat|
        source_path = "#{parent_source}/#{source_stat['pathSuffix']}"
        target_path = "#{parent_target}/#{target_stat['pathSuffix']}"
        # source and target has the same filename
        if source_stat['pathSuffix'] == target_stat['pathSuffix']
          if source_stat['type'] != target_stat['type']
            puts "ERROR: source(#{source_path}:#{source_stat['type']}) and target(#{target_path}:#{target_stat['type']}) have different type"
          else
            isFound = true
            if source_stat['type'] == 'DIRECTORY'
              mv_suboverlay(target_path, source_path)
            else
              mv_to_file(target_path, source_path)
            end
          end
        end
      end
      if isFound == false
        source_path = "#{parent_source}/#{source_stat['pathSuffix']}"
        target_path = "#{parent_target}/#{source_stat['pathSuffix']}"
        mv_to_file(target_path, source_path)
      end
    end
  end

  #
  # mv any number of sources to an existing directory
  #
  def mv_to_dir(dir, sources)
    sources.each do |source|
      target = "#{dir}/#{File.basename(source)}"
      mv_to_file(target, source)
    end
  end

  #
  # mv a single source to a non-directory target
  #
  def mv_to_file(target, source)
    source_stat = target_stat = nil
    # Check whether the source file exists
    begin
      source_stat = @client.stat(source)
    rescue WebHDFS::FileNotFoundError
      raise "source #{source} does not exist"
    end
    
    # Check whether the target file exists
    begin
      target_stat = @client.stat(target)
    rescue WebHDFS::FileNotFoundError
      # fall through, leave stat = nil
    end
    target_exist = target_stat ? true : false

    if target_exist 
      if source_stat['type'] != target_stat['type']
        puts "ERROR: source(#{source}:#{source_stat['type']}) and target(#{target}:#{target_stat['type']}) have different type"
      else
        overwrite = @settings.no_overwrite ? "n" : "y"
        if @settings.interactive
          overwrite = ask("overwrite #{target}? (y/n [n]) ") { |yn| yn.limit = 1; yn.validate = /[yn]/i } 
          #puts "overwrite: #{overwrite}"
        end

        if @settings.force || overwrite == "y"
          @client.delete(target)
          mv_file(target, source)
        end
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
