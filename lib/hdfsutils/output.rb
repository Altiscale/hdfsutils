#
# Library: output.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'pp'

module HdfsUtils
  #
  # The Output class provides default output functionality.  It is useful
  # when writing code, but should always be subclassed for each type of
  # object that needs to be printed.
  #
  class Output
    public

    def initialize(settings)
      @settings = settings
    end

    #
    # By default, print using the ruby pretty printer.
    #
    def run(thing)
      pp thing
    end
  end
end
