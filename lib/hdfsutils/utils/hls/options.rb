#
# Library: options.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

module Options
  #
  # This procedure provides options that are specific to the utility.
  # It is intended to provide a generic pattern for all utilities.
  # The lambda is injected into the Util superclass option handling.
  #
  def util_opts
    lambda do |opts, settings|
      opts.banner = "Usage: #{@name} [options] [file ...]"
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
    end
  end
end
