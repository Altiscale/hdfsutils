#
# Utility: implementation.rb
#
# Copyright (C) 2015 Altiscale, Inc.
# Licensed under the Apache License, Version 2.0
#   http://www.apache.org/licenses/LICENSE-2.0
#

#
# This module is the template for the implementation of the utility.
#
module TemplateImplementation
  #
  # This function implements the template utility.
  #
  def template
    puts "These aren't the droids we're looking for."
    puts 'You can go about your business.' if @settings.business
    puts 'Move along... move along.' if @settings.movealong
  end
end
