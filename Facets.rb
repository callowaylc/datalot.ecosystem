# Author: Christian Calloway callowaylc@gmail

# Defines our "facets" (habitat, species, animal) within the ecosystem
module Ecosystem

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
    attr_accessor :species, :food, :water
    attr_accessor_with_default :animals, { }

    def initialize(hash)
      super(hash)
      
      # set food/water stores to default
      refresh
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

    # determines if habitat is "supportive", which equates to whether
    # current food/water levels can support current popuation
    def supportive?

    end


    # return shuffled group of animals so we can avoid issues
    # related to preference based on queue order; we return as
    # array since we only care about hash in the context of removing
    # an animal from the queue 
    # @todo this should be decoupled from habitat as there will
    # be instances where we do NOT care about hash order, making this
    # inefficient
    def animals
      @animals.to_a.shuffle
    end

    def females
      self.animals.select do |animal|
        animal.female?
      end
    end

    def males
      self.animals.reject do |animal|
        animal.female?
      end
    end

    # refreshes food/water store based on profile
    def refresh
      self.food  = self['attributes']['monthly_food']
      self.water = self['attributes']['monthly_water']
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
    # @note need to consider interval; here we are tightly coupled to months
    dies_of :age        , lambda { @age        > self['attributes']['life_span'].to_i.months }
    dies_of :exposure   , lambda { @exposure   > 1.month }
    dies_of :thirst     , lambda { @thirst     > 1.month }
    dies_of :starvation , lambda { @starvation > 3.months } 


    
    # define instance propertie for animal and starting
    # default values
    attr_accessor :sex, :species

    # defines properties that deal with death
    # @note we could iterate through properties, but this is 
    # is more readable?
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

    def fertile?
      @age >= self['attributes']['minimum_breeding_age'] &&
      @age <= self['attributes']['maximum_breeding_age']
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

    # attempts to eat from habitat; returns false
    # if habitats food is depleted
    def eats_from(habitat)
      requires = self['attributes']['monthly_food_consumption'].to_i

      # debit from food store if habitat can current support food
      # requirement for single animal  
      if (succeeds = habitat.food >= requires)
        habitat.food -= requires 
        self.starvation = 0
      end
      
      # return whether animal has successfully consumed
      # from environment
      succeeds
    end

    # attempts to drink from habitat; returns false
    # habitats water is depleted
    # @note too much copy pasta from eats_from
    def drinks_from(habitat)
      requires = self['attributes']['monthly_water_consumption'].to_i

      # debit from food store if habitat can current support food
      # requirement for single animal  
      if (succeeds = habitat.water >= requires)
        habitat.water -= requires
        self.thirst    = 0
      end

      # return whether animal has successfully consumed
      # from environment      
      succeeds      
    end


    def die
    end

    # represents the mating act between two animals; is contextually
    # aware of current self sex
    def mate(animal)

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
end