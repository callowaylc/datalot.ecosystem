# Author: Christian Calloway callowaylc@gmail
require 'Observable'
require 'singleton'
require_relative 'Observers'
require_relative 'Facets'

module Ecosystem

  # creates a new builder instance and passes block
  def build(&block)
    Builder.new(block)
  end

  # provides fluent interface for building ecosystem cycle instance that can 
  # be iterated over
  class Builder

    def initialize(&block)
      @simulation = Simulator.new
      instance_eval(block)
    end

    def a(habitat)
      @simulation.habitat = Habitat.new habitat
    end 

    # determine species and then add adam/eve
    # to the mix
    def for(species)
      @simulation.species = Species.new species
      habitat << adam << eve
    end

    private
    def adam
      @simulation.species.animal :male
    end

    def eve
      @simulation.species.animal :female
    end 

  end

  # provides fluent interface for cycling over time interval
  class Simulator
    attr_accessor :years, :iterations

    def cycle(&block)
      instance_eval(block)
    end

    def over(years)
      @years = years
    end

    def for(iterations)
      @iterations = iterations
    end

    # gets results and yields them 
    def then
      results = nil

      # create a new ticker, set timespan, and then
      # tick over intervals
      ticker = Ticker.new(@years)
      ticker.tick do |t|

        # run update on simulation with time context
        update Time.new(t.current)

      end until ticker.is_done?

      # finally yield with results
      yield(results) if block_given
    end

    private 

    def update(time)
      # do updatin

      # notify observers that simulation is updating
      notify_observers(self, time)
    end

  end



  # Responsible tracking metrics during simulation
  class History
  end


  # Represents current time in the ecosystem and encapsulates broader
  # concepts like season
  # @note we should just use open struct here to automate initialize
  # @note we are assuming hardcoded interval types here; this should be changed
  class Time
    attr_accessor :interval
    
    def initialize(current, interval)
      @current      = current
      self.interval = interval
    end

    def current_year
      (@current / @interval) / 12
    end

    def current_month
      # assumes 1 - 12 month cycle
      (@current / @interval) % 12
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
    # mixin observable module; this will be used to update
    # habitat and species after interval events
    include Observable

    # because we assume passage of time as a constant
    # we set as a constant
    INTERVAL = 1.month

    # initialize time and set current time
    def initialize(years)
      @current = 0
      @years   = years

      # add observers for tick events
      add_observer(Observers::Species.instance)
      add_observer(Observers::Habitat.instance)

    end    

    # iterate the passage of time by interval constant
    def tick(habitat)

      # increment time
      @current += INTERVAL 

      # notify observers of the passage of time; we are passing self
      # here which tightly couples Ticker to observer but in the 
      # interest of a solution..
      # @note passing interval here helps decouple observers from ticker,
      # but we shouldnt have to pass the same value repeatedly..
      notify_observers habitat, Time.new(@current, INTERVAL)
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