#!/usr/bin/env ruby
# Author: Christian Calloway callowaylc@gmail

# Description here


### REQUIRES

require 'yaml'
require 'active_support/all'

require_relative 'Utilities'
require_relative 'Ecosystem'


### CONSTANTS 

FILE_CONFIG = './Data.yaml'

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

# iterate across species/habitats and build individual
# ecosystems for each

config.species.each do |species|
  config.habitats.each do |habitat| 

    # build ecosystem instance
    ecosystem = Ecosystem::build {
      a    habitat
      with species
    }

    # now cycle over iterations/years; use results defined to_s method
    # to print to stdout
    ecosystem.simulate { 
      through config.years 
      over    onfig.iterations

      and_then { |result| puts result } 
    }

  end
end