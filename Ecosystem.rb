# Author: Christian Calloway callowaylc@gmail
require 'observer'
require 'singleton'
require 'yaml'
require_relative 'Observers'
require_relative 'Entities'

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

      (1..self.iterations).each do 
        # create a new ticker, set timespan, and then
        # tick over intervals

        ticker = Ticker.new(self.years)
        ticker.tick do |time|

          # call changed true in order to 
          changed true
          notify_observers self, time, history

          # refresh our habitat after observers have updated
          # species/habitat
          self.habitat.refresh

        end until ticker.is_done?
        
        break
      end

      # finally yield with results
      yield(history) if block_given?
    end

    private 
  end



  # Responsible tracking metrics during simulation
  class History

    def initialize (habitat, species)
      @store   = { 
        population: [ ],
        death:      [ ]
      }
      @habitat = habitat
      @species = species

    end

    # responsible for recording historical events
    def note(type, value)
      # create array if store[stype] is currently nil
      @store[type] = [ ] if @store[type].nil?

      # add value to store type
      @store[type] << value
    end

    # returns average population over full fimulation
    def average_population
      @store[:population].inject { |sum, population| sum + population }.to_f / @store[:population].size
    end

    # returns max population occurrence 
    def max_population
      @store[:population].max
    end

    # returns death
    def mortality_rate
      # we are going to calculate mortality rate using aggregate
      # of populations and total death, though i think this calculation
      # may be wrong
      deaths.to_f /  @store[:population].inject { | sum, population | sum + population }
    end

    def causes_of_death
      # because of the way we have elected to store values, 
      # we will need to aggregate causes of death
      aggregates = Hash.new(0)

      @store[:death].each do |cause|
        aggregates[cause] += 1 
      end

      aggregates
    end

    # returns yaml formatted representation of history 
    def to_s
      {
        'habitat' => @habitat.to_s,
        'species' => @species.to_s,
        'average population' => average_population,
        'max population' => max_population,
        'mortality rate' => mortality_rate,
      
      }.merge(causes_of_death).to_yaml

    end

    private
      def deaths
        @store[:death].length
      end

  end


  # Represents current time in the ecosystem and encapsulates broader
  # concepts like season
  # @note we should just use open struct here to automate initialize
  # @note we are assuming hardcoded interval types here; this should be changed
  class Time
    attr_accessor :interval, :current
    
    def initialize(current, interval)
      self.current  = current
      self.interval = interval
    end

    def current_year
      (self.current / self.interval) / 12
    end

    def current_month
      # assumes 1 - 12 month cycle
      (self.current / self.interval) % 12
    end

    # determines current season based on hardcoded requirements
    # assumes 1 - 12 month cycle
    def current_season
      season = nil

      { 
        winter: [ 12, 1, 2  ], 
        spring: [ 3,  4, 5  ], 
        summer: [ 6,  7, 8  ],
        fall:   [ 9, 10, 11 ]
      
      }.each do |key, range|
        if range.include? current_month
          season = key
          break
        end
      end

      season
    end

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

      yield Time.new(@current, INTERVAL)
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