# Author: Chistisn Calloway

module Ecosystem

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
      average_deaths = @store[:deaths].inject { | sum, deaths | sum + deaths }.to_f / @store[:deaths].size 


      average_deaths / (average_population + average_deaths)
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
  class TimeContext
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
      if (result = (self.current / self.interval) % 12) == 0
        result = 12
      end

      result
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
end  
