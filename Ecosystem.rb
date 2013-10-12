# Author: Christian Calloway callowaylc@gmail
require 'Observable'
require 'singleton'

module Ecosystem

  # creates a new builder instance and passes block
  def build(&block)
    raise "Failed to pass required block" unless block
    Builder.new(block)
  end

  # provides fluent interface for building ecosystem cycle instance that can 
  # be iterated over
  class Builder

    def initialize(block)
      @cycler = Cycler.new
      instance_eval(block)
    end

    def a(habitat)
      @cycler.habitat = Habitat.new habitat
    end 

    def for(species)
      @cycler.species = Species.new species
    def 
  end

  # provides fluent interface for cycling over time interval
  class Cycler
    attr_accessor :years, :iterations

    def cycle(&block)
      raise "Failed to pass required block" unless block
      instance_eval(block)
    end

    def over(years)
      @years = years
    end

    def for(iterations)
      @iterations = iterations
    end
  end

 class Element 
    
  end

  class Animal < Element
    attr_accessor :sex

    def initialize(sex = nil)
      # determine sex, unless overriden
      @sex = [ :male, :female ].sample unless sex
    end

    def female?
    end

    def survive?
    end

    def eat(habitat)
    end

    def drink(habitat)
    end

    def age
    end

  end

  class Habitat < Element
    attr_accessor :species, :animals
  end  

  module Observers

    class Observer
      include Singleton
    end

    # individual species?
    class Species < Observer
      
      def update()
      
      end
      
      
    end

    class Habitat < Observer
      def update(habitat)
        
        # determine which groups of species need to be
        # culled 
      end
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

    # provide attribute accessor for total time
    attr_accessor :total

    # initialize time and set current time interval to 0
    def initialize
      @current = 0

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
      notify_observers(habitat)


    end

    # determines if there is time left in current iteration
    def is_done?
      @current >= @total
    end

  end

 

end