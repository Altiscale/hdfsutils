#
# Library: system_settings.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'rexml/document'
require 'settings/parse_hdfs_uri'

module HdfsUtils
  #
  # This class provides configuration information from the
  # local systems Hadoop configuration files.
  #
  class SystemSettings
    public

    def initialize(settings)
      @settings = settings
      @confdir = ENV['HADOOP_CONF_DIR'] || '/etc/hadoop'
    end

    #
    # Merge the system settings into the settings structure
    #
    def merge
      uri = hdfs_site_host_and_port || core_site_host
      return unless uri && uri.host
      @settings[:host] = uri.host
      @settings[:port] = uri.port.to_s if uri.port
    end

    private

    def hdfs_site_host_and_port
      hostport = get_xml_value('hdfs-site.xml',
                               'dfs.namenode.http-address.master')
      return nil unless hostport

      # return URI with parsed host and port, or nil
      ParseHdfsURI.new.parse(hostport)
    end

    def core_site_host
      urival = get_xml_value('core-site.xml', 'fs.defaultFS')
      return nil unless urival

      # parse URI.  save host, but overwrite port (typically 8020 for HDFS)
      uri = ParseHdfsURI.new.parse(urival)
      return nil unless uri
      uri.port = 50_070
      uri
    end

    def get_xml_value(filename, keyname)
      xml = REXML::Document.new(File.open(File.join(@confdir, filename)))
      xml.elements.each('//property') do |el|
        next unless el.elements['name'].text == keyname
        return el.elements['value'].text
      end
      nil
    rescue
      nil
    end
  end
end
