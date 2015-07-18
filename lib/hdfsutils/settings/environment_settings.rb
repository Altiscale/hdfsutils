#
# Library: environment_settings.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'fatal'
require 'settings/parse_hdfs_uri'

module HdfsUtils
  #
  # This class provides configuration information from the
  # execution environment (typically the shell environment).
  #
  class EnvironmentSettings
    public

    def initialize(settings)
      @settings = settings
    end

    #
    # Merge the environment settings into the settings structure
    #
    def merge
      host
      port
      username
      doas
      proxyhost
      proxyport
      hdfsuri
    rescue
      @settings.fatal.die(Fatal::BADENV, $!)
    end

    private

    def host
      return unless ENV['HDFS_HOST']
      @settings[:host] = ENV['HDFS_HOST']
    end

    def port
      return unless ENV['HDFS_PORT']
      @settings[:port] = ENV['HDFS_PORT']
    end

    def username
      return unless ENV['HDFS_USERNAME'] || ENV['USER']
      @settings[:username] = ENV['HDFS_USERNAME'] || ENV['USER']
    end

    def doas
      return unless ENV['HDFS_DOAS']
      @settings[:doas] = ENV['HDFS_DOAS']
    end

    def proxyhost
      return unless ENV['HDFS_PROXYHOST']
      @settings[:proxyhost] = ENV['HDFS_PROXYHOST']
    end

    def proxyport
      return unless ENV['HDFS_PROXYPORT']
      @settings[:proxyport] = ENV['HDFS_PROXYPORT']
    end

    ERRMSG = 'may not both be set in the environment'

    #
    # Set the HDFS URI if it is configured.  Also,
    # verify that there are no environment variables that
    # conflict with the HDFS URI.
    #
    def hdfsuri
      env_uri = ENV['HDFS_URI'] || ENV['HDFS_URL']
      return unless env_uri

      if ENV['HDFS_URI'] && ENV['HDFS_URL']
        fail "HDFS_URI and HDFS_URL #{ERRMSG}"
      end

      varname = ENV['HDFS_URI'] ? 'HDFS_URI' : 'HDFS_URL'

      if ENV['HDFS_HOST']
        fail "HDFS_HOST and #{varname} #{ERRMSG}"
      end

      if ENV['HDFS_PORT']
        fail "HDFS_PORT and #{varname} #{ERRMSG}"
      end

      uri = ParseHdfsURI.new.parse(env_uri)
      @settings[:host] = uri.host
      @settings[:port] = uri.port.to_s
      @settings[:user] = uri.userinfo
    end
  end
end
