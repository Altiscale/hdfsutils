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
    
  end

  #
  # mv a single source to a non-directory target
  #
  def merge_content_summary(target, source)
  end
end
