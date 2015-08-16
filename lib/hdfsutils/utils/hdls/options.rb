#
# Library: options.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

#
# Options for the ls utility.
#
module LsOptions
  #
  # This procedure provides options that are specific to this utility.
  #
  def util_opts
    lambda do |opts, settings|
      opts.banner = "Usage: #{@name} [options] [file ...]"
      opts.on('-@', 'Extended info (e.g. directory sizes) in long output.') do
        settings.extended = true
      end
      opts.on('-d',
              'Directories are listed as plain files ' \
              '(not searched recursively).') do
        settings.dir_plain = true
      end
      opts.on('-l', 'List in long format.') do
        settings.long_format = true
      end
      opts.on('-R', 'Recursively list subdirectories encountered.') do
        settings.recursive = true
      end
      opts.on('-u', 'Use time of last access, instead of last modification.') do
        settings.access_time = true
      end
    end
  end
end
