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
      start_log
      @client = WebHDFS::Client.new(@settings[:host],
                                    @settings[:port],
                                    @settings[:username],
                                    @settings[:doas],
                                    @settings[:proxyhost],
                                    @settings[:proxyport])

      fail 'nil client' unless @client
      @client.open_timeout = @settings[:open_timeout]
      @client.read_timeout = @settings[:read_timeout]
      check_kerberos
      if @client.respond_to? :reuse_connection
        @logger.debug('  configured webhdfs client to reuse connection')
        @client.reuse_connection = true
      end
      @client
    rescue
      raise 'failed to start webhdfs client [' +
            @settings[:host] + ':' + @settings[:port] + ']: ' +
            $!.message
    end

    private

    def start_log
      @logger.info('starting webhdfs client')
      [:host, :port, :username].each do |k|
        @logger.info("  #{k}: " + @settings[k])
      end
      [:doas, :proxyhost, :proxyport].each do |k|
        @logger.info("  #{k}: " + @settings[k]) if @settings[k]
      end
    end

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
