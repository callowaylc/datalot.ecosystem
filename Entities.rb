# Author: Christian Calloway callowaylc@gmail

# Defines our "facets" (habitat, species, animal) within the ecosystem
module Ecosystem

   class Entity 

    def initialize(hash)
      @profile = hash
    end  

    # provides access to profile/hash
    def [](key)
      @profile[key]
    end

    def to_s
      self['name']
    end
  end

  # Represents a single habitat-type
  class Habitat < Entity
    attr_accessor :food, :water, :time

    def initialize(hash)
      super(hash)
      
      # set animals instance property
      @animals = { }

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

    def population
      @animals.length
    end

    # determines if habitat has been depleted to
    # the point that it can no longer support continued 
    # expansion of species
    def depleted?
      # since this question addresses whether a habitat can
      # support additional species, we check resources against
      # the additional of a single species
      # @note do we need to address case of species extinction here??
      animal = self.animals.first
      raise 'Species has expired' unless animal


      self.food   >= animal.species['attributes']['monthly_food_consumption'].to_i  &&
      self.water  >= animal.species['attributes']['monthly_water_consumption'].to_i 
    end


    # determine current temperature given current time of year
    def temperature

      # get base temperature and random temperature swing value;
      # swing value will have a .5% value 
      # @note we are assuming month is a symbol - we may want
      # to do an explicit check here
      base  = self['average_temperature'][self.time.current_month.to_s].to_i
      swing = rand <= 0.005 ? [*0..15].sample.to_f : [*0..5].sample.to_f

      # calculate and return 
      base + ( swing / base * [ -1, 1 ].sample ) 


    end


    # return shuffled group of animals so we can avoid issues
    # related to preference based on queue order; we return as
    # array since we only care about hash in the context of removing
    # an animal from the queue 
    # @todo this should be decoupled from habitat as there will
    # be instances where we do NOT care about hash order, making this
    # inefficient
    def animals
      @animals.values.shuffle
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
      self.food  = self['monthly_food'].to_i
      self.water = self['monthly_water'].to_i
    end

  end  

  # Represents a single species-type
  class Species < Entity
    
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
      attr_reader :rules

      def dies_of(type, block)
        @rules[type] = block
      end
    end

    # define rules for for death; this should be done in
    # an external dsl
    # @note change hardcoded values to constants
    # @note need to consider interval; here we are tightly coupled to months
    dies_of :age        , proc { self.age        > self.species['attributes']['life_span'].to_i.years }
    dies_of :exposure   , proc { self.exposure   > 1.month }
    dies_of :thirst     , proc { self.thirst     > 1.month }
    dies_of :starvation , proc { self.starvation > 3.months } 


    
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
    attr_accessor_with_default :pregnant,   false


    def initialize
      yield(self) if block_given?
    end

    def female?
      @sex == :female
    end

    def fertile?
      self.age >= self.species['attributes']['minimum_breeding_age'].to_i.years &&
      self.age <= self.species['attributes']['maximum_breeding_age'].to_i.years
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
          puts "animal #{self.object_id} #{self.sex} age is #{self.age} died of #{property}"

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

    # checks exposure against current temperature
    def exposed_to(habitat)
      # just performing a shortcut here
      a = self.species['attributes']

      # if temperature in acceptible range reset exposure, otherwise increment exposure
      # @todo this is ugly; find another way to express this cleanly
      self.exposure = if ((success = a['minimum_temperature']..a['maximum_temperature']).include? habitat.temperature)
        then 0
        else self.exposure + 1
      end

      success
    end


    # attempts to eat from habitat; returns false
    # if habitats food is depleted
    def eats_from(habitat)
      requires = self.species['attributes']['monthly_food_consumption'].to_i

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
      requires = self.species['attributes']['monthly_water_consumption'].to_i

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

    def starves_for(interval)
      self.starvation += interval
    end

    def thirsts_for(interval)
      self.thirst += interval
    end

    def ages_for(interval)
      self.age += interval
    end

    def gestates_for(interval)
      self.gestation += interval
    end

    def exposed_for(interval)
      self.exposure += interval
    end


    # represents the mating act between two animals; is contextually
    # aware of current self sex
    def mate(animal)
      puts "animale:#{self.object_id}/#{self.sex} mates with #{animal.object_id}/#{animal.sex}"
      if female?
        self.pregnant = true

      else
        # @note if a male, we can keep track of child/parent relationshiops
        # @pass

      end
    end

    # @note problem with methods below is they do not fit into
    # context of a male member of the species; abstraction should
    # reflect this - revisit

    # checks to determine if female is pregnant
    def pregnant?
      assert_female

      self.pregnant == true
    end

    # checks to determine if female has reached gestation period
    def is_ready_to_deliver
      assert_female

      self.gestation >= self.species['attributes']['gestation_period'].to_i
    end

    # represents a birth; which changes gestation status
    # and returns new animal
    def delivers
      assert_female

      # reset gestation and pregnancy status
      self.gestation = 0
      self.pregnant  = false

      # finally yield new animal to block, which should
      # be called in habitat context
      yield @species.animal
    end

    private

      def assert_female
        raise "NaN.. er NaF" unless female?
      end


  end
end