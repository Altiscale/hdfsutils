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
      @logger = settings[:logger]
    end

    def start
      @logger.info('starting webhdfs client')
      @logger.info('  host: ' + @settings[:host])
      @logger.info('  port: ' + @settings[:port])
      @logger.info('  username: ' + @settings[:username])

      @client = WebHDFS::Client.new(@settings[:host],
                                    @settings[:port],
                                    @settings[:username])
      fail 'nil client' unless @client
      @client.open_timeout = @settings[:open_timeout]
      @client.read_timeout = @settings[:read_timeout]

      check_kerberos
      @client
    rescue
      raise 'failed to start webhdfs client [' +
            @settings[:host] + ':' + @settings[:port] + ']: ' +
            $!.message
    end

    private

    def check_kerberos
      # TODO: make kerberos an option to avoid doing the retry
      @kerberos = false
      begin
        @client.kerberos = @kerberos
        if @client.stat('/') # this operation should always work
          @logger.debug('webhdfs started')
        else
          @logger.warn('webhdfs failed to GETFILESTATUS /')
        end
      rescue WebHDFS::SecurityError
        @logger.debug('webhdfs start failed: trying kerberos authentication')
        @kerberos = true
        retry
      rescue WebHDFS::KerberosError => ex
        raise "kerberos Error: #{ex.message}"
      end
      @kerberos
    end
  end
end
