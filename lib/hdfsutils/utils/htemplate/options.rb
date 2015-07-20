#
# Library: options.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

#
# This module provides options that are specific to the utility.
#
module TemplateOptions
  #
  # This procedure provides options that are specific to the utility.
  # It is intended to provide a generic pattern for all utilities.
  # The lambda is injected into the Util superclass option handling.
  #
  def util_opts
    lambda do |opts, settings|
      opts.banner = "Usage: #{@name} [options]"
      opts.on('-b', '--business', 'Second line of the quote.') do
        settings.business = true
      end
      opts.on('-m', '--movealong', 'Third line of the quote.') do
        settings.movealong = true
      end
    end
  end
end
