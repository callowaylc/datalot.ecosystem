# Author : Christian Calloway callowalc@gmail

# Contains definitions for species and habitat observers

module Ecosystem
  module Observers

    class Observer
      include Singleton
    end

    # responsible for updating species specific context
    class Species < Observer
      
      def update(simulation, time, interval)
        animals = simulation.habitat.animals

        # iterate through animals
        animals.each do |animal|

          # age our animals for given time interval
          animal.age += interval

          # check if animal is in a fertile period and
          # currently in the gestation process  
          if animal.female? && animal.pregnant?
            animal.gestation += interval
          end


        end
      end
      
      
    end

    # responsible for updating habitat specific context
    class Habitat < Observer
      def update(simulation, time, interval)
        habitat = simulation.habitat
        
        # iterate through shuffled list of animals 
        habitat.animals.each do |animal|

          # first we address consumption
          # @note I'd like to encapsulate the metrics of death
          animal.eats_from   habitat or animal.starves_for interval
          animal.drinks_from habitat or animal.thirsts_for interval

          # second-to-last we cull animal if it has reached a point
          # where it can no longer survive
          animal.died? do |cause|
            # remove from habitat
            habitat.remove animal

            # store history of cause of death
            # still need to determine how this looks
          end          
        end

        # finally, we determine if habitat can support further 
        # breeding
        unless habitat.depleted?

          # find available candidates within female population 
          females = habitat.females.reject { |animal| animal.pregnant? }

          # now slice that available population 
          females.slice(0, habitat.males.length).each do |female|

          end

            # iterate through number of males and start gestation process

          end

          # iterate through available males 
        end         

        # of surviving animals, retrieve females and determine
        # if any are in gestation
        pregnant = simulation.habitat.females.select do |female|
          female.pregnant?
        end

        pregnant.each do |female|

        end


      end
    end


  end
end