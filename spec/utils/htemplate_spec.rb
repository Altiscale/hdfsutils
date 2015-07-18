#
# Test: htemplate_spec.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

require_relative '../spec_helper'
require_relative 'hls_spec_webmock'
require 'utils/htemplate/template'

describe HdfsUtils::Template do
  include HlsSpecWebmock

  it 'should print droids' do
    dirname = '/user/testuser/testdir'
    hls_spec_webmock(dirname: dirname,
                     filename: 'not_used',
                     dir2name: 'not_used')

    template_output = "These aren't the droids we're looking for.\n"

    expect {
      HdfsUtils::Template.new('htemplate', []).run
    }.to output(template_output).to_stdout
  end

  it 'should print droids and business' do
    dirname = '/user/testuser/testdir'
    hls_spec_webmock(dirname: dirname,
                     filename: 'not_used',
                     dir2name: 'not_used')

    template_output = "These aren't the droids we're looking for.\n" \
                      "You can go about your business.\n"

    expect {
      HdfsUtils::Template.new('htemplate', ['--business']).run
    }.to output(template_output).to_stdout
  end

  it 'should print droids and business and movealong' do
    dirname = '/user/testuser/testdir'
    hls_spec_webmock(dirname: dirname,
                     filename: 'not_used',
                     dir2name: 'not_used')

    template_output = "These aren't the droids we're looking for.\n" \
                      "You can go about your business.\n" \
                      "Move along... move along.\n"

    expect {
      HdfsUtils::Template.new('htemplate', ['-m', '--business']).run
    }.to output(template_output).to_stdout
  end

  it 'should print droids and movealong' do
    dirname = '/user/testuser/testdir'
    hls_spec_webmock(dirname: dirname,
                     filename: 'not_used',
                     dir2name: 'not_used')

    template_output = "These aren't the droids we're looking for.\n" \
                      "Move along... move along.\n"

    expect {
      HdfsUtils::Template.new('htemplate', ['--movealong']).run
    }.to output(template_output).to_stdout
  end
end

