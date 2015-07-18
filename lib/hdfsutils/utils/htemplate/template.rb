#
# Utility: template.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'utils/util'
require 'utils/htemplate/options'
require 'utils/htemplate/implementation'

module HdfsUtils
  #
  # This template provides a generic pattern for all utilities.
  # The top-level file is the name of the Unix utility that the hdfsutils
  # program emulates.  Naming the top-level file for the utility rather
  # than giving it a generic name (e.g. main) makes it easier for a
  # programmer or user who is new the code base to search for the code.
  #
  class Template < Util
    public

    #
    # Initialize the utility.
    #
    def initialize(name, argv)
      # Initialize superclass with arguments and options specialized
      # for this utility.
      super(name, argv, util_opts)
      @logger = @settings.logger
    rescue # never send a stack trace to the user (except when debugging)
      @settings.fatal.die(Fatal::BADINIT, $!)
    end

    #
    # Run the utility.
    #
    def run
      template
    rescue # never send a stack trace to the user (except when debugging)
      @settings.fatal.die(Fatal::BADRUN, $!)
    end

    private

    # The submodules need to be uniquely named across all utilities,
    # because rspec loads the modules for all utilities when performing
    # unit tests.
    include TemplateOptions # provides options that are specific to this utility
    include TemplateImplementation # implements this utility
  end
end
