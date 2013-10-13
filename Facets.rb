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
end