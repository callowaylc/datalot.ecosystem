# Author: Christian Calloway callowaylc@gmail
require 'observer'
require 'singleton'
require 'yaml'
require_relative 'Observers'
require_relative 'Entities'
require_relative 'Metrics'

module Ecosystem

  # creates a new builder instance and passes block
  def self.build(&block)

    # create builder and return simulation instance
    builder = Builder.new(block)
    builder.simulation
  end

  # provides fluent interface for building ecosystem cycle instance that can 
  # be iterated over
  class Builder
    attr_reader :simulation

    def initialize(block)
      @simulation = Simulator.new
      instance_eval(&block)
    end

    def a(habitat)
      @simulation.habitat = Habitat.new habitat
    end 

    # determine species and then add adam/eve
    # to the mix
    def with(species)
      @simulation.species = Species.new species
      @simulation.habitat << adam << eve
    end

    private

    def adam
      @simulation.species.animal sex: :male
    end

    def eve
      @simulation.species.animal sex: :female
    end 

  end

  # provides fluent interface for cycling over time interval
  class Simulator
    # mixin observable module; this will be used to update
    # habitat and species after interval events
    include Observable

    attr_accessor :years, :iterations, :habitat, :species

    def initialize
      # add observers for update events
      add_observer(Observers::Species.instance)
      add_observer(Observers::Habitat.instance)      
    end

    # simulate, over and for are all "interface" methods intended
    # only for idiomatic expression
    def simulate(&block)
      instance_eval(&block)
    end

    def over(iterations)
      self.iterations = iterations.to_i
    end

    def through(years)
      self.years = years.to_i.years
    end


    # runs simulation and collects historical data; if a 
    # block is given, history will be yieled to block
    def and_then
      history = History.new(self.habitat, self.species)

      # record start time for habitat/species
      # @note using this for profiling
      start = Time.new

      (1..self.iterations).each do 
        # create a new ticker, set timespan, and then
        # tick over intervals

        ticker = Ticker.new(self.years)
        ticker.tick do |time|

          # call changed true in order to 
          changed true
          notify_observers self, time, history

          # break from iteration if all animals
          # within habitat have perished
          break if self.habitat.empty?

          # otherwise refresh our habitat 
          self.habitat.refresh



        end until ticker.is_done?
      end

      puts "took #{Time.new - start}!"


      # finally yield with results
      yield(history) if block_given?
    end

    private 
  end


  # Represents intervals of time passing during simulation
  class Ticker

    # because we assume passage of time as a constant
    # we set as a constant
    INTERVAL = 1.month

    # initialize time and set current time
    def initialize(total)
      @current = 0
      @total   = total
    end    

    # iterate the passage of time by interval constant
    def tick
      # increment time
      @current += INTERVAL 

      yield TimeContext.new(@current, INTERVAL)
    end

    # determines if there is time left in current iteration
    def is_done?
      @current >= @total
    end

    # reset ticker to 0 time
    def reset
      @current = 0
    end

  end

 

end