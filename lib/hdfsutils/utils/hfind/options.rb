#
# Library: options.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

module FindOptions
  #
  # This procedure provides options that are specific to the utility.
  # It is intended to provide a generic pattern for all utilities.
  # The lambda is injected into the Util superclass option handling.
  #
  def util_opts
    lambda do |opts, _settings|
      opts.banner = "Usage: #{@name} [options] [file ...]"
    end
  end
end
