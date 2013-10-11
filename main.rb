#!/usr/bin/env ruby
# @author Christian Calloway callowaylc@gmail

# Description here


### REQUIRES

require 'yaml'
require_relative 'Species'
require_relative 'Habitat'

### CONSTANTS 

FILE_CONFIG = './Data.yaml'


### MAIN

# parse yaml file and bind to config variable

parsed = begin
  YAML.load file = open(FILE_CONFIG)

rescue ArgumentError => e
  puts "Could not parse YAML: #{e.message}"
  raise

rescue Exception => e
  puts "Failed to find configuration file '#{FILE_CONFIG}'"
  raise

ensure
    file.close unless file.nil?

end

puts parsed.class