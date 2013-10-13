# Author: Christian Calloway callowaylc@gmail
require 'Observable'
require 'singleton'
require_relative 'Observers'

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

  class Facet 

    def initialize(hash)
      @profile = hash
    end  

    # provides access to profile/hash
    def [](key)
      @profile[key]
    end
  end

  # Represents a single habitat-type
  class Habitat < Facet
    attr_accessor :species, :animals

    # provides default for animals without overriding
    # constructor
    def animals
      @animals ||= { }
    end

    # convenience override for << operator to add animals
    # to habitat 
    def <<(animal)
      @animals[animal] = animal

      # return self so we can chain 
      self
    end

    def remove(animal)
      @animals.delete animal
    end

    def females
      @animals.select do |ignore, animal|
        animal.female?
      end
    end

  end  

  # Represents a single species-type
  class Species < Facet
    
    # creates a new animal of species type
    def animal(sex:[ :male, :female ].sample)
      Animal.new do |animal|
        animal.sex     = sex
        animal.species = self
      end 

    end
  end

  # Represents a single animal
  class Animal

    # define class property rules and method dies
    # to provide container for rules of death
    @rules = { }

    class << self
      def dies_of(type, block)
        @rules[type] = block
      end
    end

    # define rules for for death; this should be done in
    # an external dsl
    # @note change hardcoded values to constants
    dies_of :age        , lambda { @age        > self['attributes']['life_span'] }
    dies_of :exposure   , lambda { @exposure   > 1 }
    dies_of :thirst     , lambda { @thirst     > 1 }
    dies_of :starvation , lambda { @starvation > 3 } 


    
    # define instance propertie for animal and starting
    # default values
    attr_accessor :sex, :species

    # defines properties that deal with death
    attr_accessor_with_default :age,        0
    attr_accessor_with_default :starvation, 0
    attr_accessor_with_default :thirst,     0
    attr_accessor_with_default :exposure,   0
    attr_accessor_with_default :gestation,  0
    


    def initialize
      yield(self) if block_given?
    end

    def female?
      @sex == :female
    end

    # determines if animal survived given current properties
    # governing an indivuals death threshold
    def died?
      # iterate through rules regarding death and determine
      # if animal has survived
      # @todo since we are calling this method multiple times
      # we should save binded block for instance
      cause = nil
      died  = false

      self.class.rules.each do |property, rule|
        if (died = instance_eval(&rule))
          cause = property
          break
        end
      end

      # if the animal has died, we yield to block that will
      # handle updating of ecosystem variables
      yield(cause) if died && block_given?

      # finally we return whether animal has died
      died
    end

    def died_of
    end

    def eat_from(habitat)
    end

    def drink_from(habitat)
    end


    def die
    end

    # represents a birth; which changes gestation status
    # and returns new animal
    def birth
      # raise issue if we are not a female
      raise "NaN.. er NaF" unless female?

      # change gestation status
      @gestation = 0

      # finally yield new animal to block, which should
      # be called in habitat context
      yield @species.animal
    end

  end



  # Represents current time in the ecosystem and provides
  # utility methods within that context
  class Time

    def season
    end


  end


  # Represents intervals of time passing during simulation
  class Ticker
    attr_accessor :current

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
      notify_observers(habitat)
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