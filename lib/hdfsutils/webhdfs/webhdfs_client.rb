#
# Library: webhdfs_client.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'webhdfs'

#
# This module sets up and stores information about the webhdfs client.
#
module HdfsUtils
  #
  # Superclass for all utilities.
  #
  class WebhdfsClient
    public

    def initialize(settings)
      @settings = settings
    end

    def start
      puts "host: #{@settings[:host]}"
      puts "port: #{@settings[:port]}"
      puts "username: #{@settings[:username]}"
      @client = WebHDFS::Client.new(@settings[:host],
                                    @settings[:port],
                                    @settings[:username])
      fail 'nil client' unless @client
      @client.open_timeout = @settings[:open_timeout]
      @client.read_timeout = @settings[:read_timeout]

      check_kerberos
      @client
    rescue Exception => ex
      raise "failed to start webhdfs client: #{ex.message}"
    end

    private

    def check_kerberos
      # TODO: make kerberos an option to avoid doing the retry
      @kerberos = false
      begin
        @client.kerberos = @kerberos
        @client.stat('/') # this operation should always work
      rescue WebHDFS::SecurityError
        @kerberos = true
        retry
      rescue WebHDFS::KerberosError => ex
        fail "kerberos Error: #{ex.message}"
      end
      @kerberos
    end
  end
end
