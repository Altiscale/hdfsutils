#
# Library: parse_hdfs_uri.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require 'uri'

#
# This class parses the HDFS URI, which may be specified on
# the command line, in the environment, or in a Hadoop XML
# configuration file.
#
class ParseHdfsURI
  public

  def initialize(default_port = 50_070)
    @default_port = default_port
  end

  def parse(hdfs_uri)
    uri = parse_standard_uri(hdfs_uri)
    return uri if uri
    parse_try_harder(hdfs_uri)
  end

  private

  #
  # uses the standard ruby URI parsing function
  #
  def parse_standard_uri(hdfs_uri)
    uri = URI(hdfs_uri)
    return nil unless uri.host
    case uri.scheme
    when 'webhdfs' then uri.port = @default_port unless uri.port
    when 'hdfs' then uri.port = @default_port # translate to webhdfs port
    else return nil
    end
    uri
  end

  #
  # try to figure out the URI even if it is just a fragment
  #
  def parse_try_harder(hdfs_uri)
    # support URI fragment that looks like 'hostname:port'
    m = /\A\s*(?<host>[A-Za-z0-9\.\-]+):(?<port>\d+)\s*\z/.match(hdfs_uri)
    return URI("webhdfs://#{m[:host]}:#{m[:port]}") if m

    # support URI fragment that looks like 'hostname'
    m = /\A\s*(?<host>[A-Za-z0-9\.\-]+)\s*\z/.match(hdfs_uri)
    return URI("webhdfs://#{m[:host]}:#{@default_port}") if m
    nil
  end
end
