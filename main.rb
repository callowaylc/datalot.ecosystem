#!/usr/bin/env ruby
# @author Christian Calloway callowaylc@gmail

# Description here


### REQUIRES

require 'yaml'
require_relative 'Ecosystem'

### CONSTANTS 

FILE_CONFIG = './Data.yaml'

### PATCHES

class String
  # adding ucfirst method to string
  def ucfirst
    self.sub(/^\w/) { |string| string.capitalize }
  end
end



### MAIN

# include ecosystem module/namespace

include Ecosystem

# parse yaml file and bind hash instance to config variable

config = begin
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

# mix habitats and species methods into their respective hashes

%w{ species habitats }.each do |type|
  config[type].each do |element|
    element.extend(Object.const_get(type.ucfirst))
    puts element.hello
  end
end