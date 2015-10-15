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
    target_stat = stat?(target)
    if @settings.overlay
      sources.each do |source|
        source_stat = stat?(source)
        fail 'Usage: hdmv [source_directory] [target_directory] --overlay' \
          unless source_stat && target_stat \
            && source_stat['type'] == 'DIRECTORY' \
            && target_stat['type'] == 'DIRECTORY'
        mv_suboverlay(target, source)
      end
    else
      if target_stat && target_stat['type'] == 'DIRECTORY'
        mv_to_dir(target, sources)
        return
      end
      fail "target `#{target}' is not a directory" if sources.length > 1
      mv_to_file(target, sources[0])
    end
  end

  def mv_suboverlay(parent_target, parent_source)
    source_files = list?(parent_source)
    source_files.each do |source_stat|
      source_path = "#{parent_source}/#{source_stat['pathSuffix']}"
      target_path = "#{parent_target}/#{source_stat['pathSuffix']}"

      target_stat = stat?(target_path)
      if target_stat
        if source_stat['type'] != target_stat['type']
          puts 'ERROR: ' \
            "source(#{source}:#{source_stat['type']}) and " \
            "target(#{target}:#{target_stat['type']}) " \
            'have different types'
        else
          if source_stat['type'] == 'DIRECTORY'
            mv_suboverlay(target_path, source_path)
          else
            mv_to_file(target_path, source_path)
          end
        end
      else
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
  # Priority: -f > -n > -i
  def mv_to_file(target, source)
    source_stat = stat?(source)
    target_stat = stat?(target)

    if target_stat
      if source_stat['type'] != target_stat['type']
        puts 'ERROR: ' \
          "source(#{source}:#{source_stat['type']}) and " \
          "target(#{target}:#{target_stat['type']}) " \
          'have different types'
      else
        overwrite = 'n'
        if @settings.interactive || !@settings.force && \
          !@settings.no_overwrite
          overwrite = ask?("overwrite #{target}?")
        end
        if @settings.force || overwrite == 'y'
          @client.delete(target)
          rename_file(target, source)
        end
      end
    else
      rename_file(target, source)
    end
  end

  def rename_file(target, source)
    @client.rename(source, target)
    puts "#{source} -> #{target}" if @settings.verbose
  end
end
