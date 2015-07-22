#
# Library: system_settings.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

module HdfsUtils
  #
  # This class provides configuration information from the
  # local systems Hadoop configuration files.
  #
  class SystemSettings
    public

    def initialize(settings)
      @settings = settings
    end

    #
    # Merge the system settings into the settings structure
    #
    def merge
    end
  end
end
