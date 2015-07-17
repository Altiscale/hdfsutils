#
# Library: util.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'settings'
require 'webhdfs/webhdfs_client'

module HdfsUtils
  #
  # Superclass for all utilities.
  #
  class Util
    public

    #
    # Initializes the top-level utility class.
    # name     = [String] Name of the utility.
    # argv     = [String] Command-line argument array.
    # optsproc = [lambda] Options configuration injected by the utility.
    #
    def initialize(name, argv, optsproc=nil)
      @name = name
      @args = argv
      @settings = Settings.new.run(argv, optsproc)
      @args = argv
      @client = WebhdfsClient.new(@settings).start
    end

    #
    # Abstract interface.  Every subclass must implement the run function.
    #
    def run
      raise 'Subclass of Util must override Util::run'
    end
  end
end
