#
# Library: options.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

#
# Options for the mv utility.
#
module MvOptions
  #
  # This procedure provides options that are specific to this utility.
  #
  def util_opts
    lambda do |opts, settings|
      opts.banner = "Usage: #{@name} [options] [file ...]"
      opts.on('-f', 'Do not prompt for confirmation before overwriting the ' \
              'destination path.') do
        settings.force = true
      end
      opts.on('-i', 'Cause mv to write a prompt to standard error before ' \
              'moving a file that would overwrite an existing file. ' \
              'If the response from the standard input begins with the ' \
              'character `y\' or `Y\', the move is attempted.') do
        settings.interactive = true
      end
      opts.on('-n', 'Do not overwrite an existing file.') do
        settings.no_overwrite = true
      end
      opts.on('-v', 'Cause mv to be verbose, showing files after they ' \
              'are moved.') do
        settings.verbose = true
      end
      opts.on('--overlay', 'Moving files and overlaying them into ' \
              'an existing directory.') do
        settings.overlay = true
      end
    end
  end
end
