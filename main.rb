#!/usr/bin/env ruby
# @author Christian Calloway callowaylc@gmail

# Description here


### REQUIRES

require 'yaml'
require 'active_support/all'
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

#%w{ species habitats }.each do |type|
#  config[type].each do |element|
#    element.extend(Object.const_get(type.ucfirst))
#    puts element.hello
#  end
#end

config.species.each do |species|
  config.habitats.each do |habitat| 
    puts Ecosystem::Builder.new do 
      in   habitat
      with species
    end
  end
end

end



