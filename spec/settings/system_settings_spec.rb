#
# Test: system_settings_spec.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require_relative '../spec_helper'
require 'settings/system_settings'

describe HdfsUtils::SystemSettings do
  it 'should initialize from hdfs-site.xml' do
    ENV['HADOOP_CONF_DIR'] = File.join(File.dirname(__FILE__),
                                       'hdfs-site-wins')
    settings = {}
    HdfsUtils::SystemSettings.new(settings).merge
    expect(settings[:host]).to eql('sn-cluster-001.nsdc.altiscale.com')
    expect(settings[:port]).to eql('14000')
  end

  it 'should initialize from core-site.xml' do
    ENV['HADOOP_CONF_DIR'] = File.join(File.dirname(__FILE__),
                                       'core-site-wins')
    settings = {}
    HdfsUtils::SystemSettings.new(settings).merge
    expect(settings[:host]).to eql('nn-cluster-003.nsdc.altiscale.com')
    expect(settings[:port]).to eql('50070')
  end
end
