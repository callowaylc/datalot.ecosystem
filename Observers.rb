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
          animal.ages_for interval

          # check if animal is in a fertile period and
          # currently in the gestation process  
          if animal.female? && animal.pregnant?
            animal.gestates_for interval
          end


        end
      end
      
      
    end

    # responsible for updating habitat specific context
    class Habitat < Observer
      def update(simulation, time, interval)
        habitat = simulation.habitat
        
        # DEATH ###############################################################
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
            history.something cause

          end          
        end

        # MATING AND DELIVERY #################################################
        # determine if habitat can support further breeding; if
        # the case, find available mates left in population
        unless habitat.depleted?

          # find available candidates within female/male population 
          females = habitat.females.reject { |animal| animal.pregnant? || !animal.fertile? }
          males   = habitat.males.select { |animal| animal.fertile? }

          # now slice that available population 
          females.slice(0, males.length).each do |female|
            female.mate males.sample
          end

        end         

        # finally check all pregnant females who have reached 
        # the end of gestation period
        habitat.females.select { |female| female.pregnant? }.each do |female|
          female.deliver do |animal|
            habitat << animal

          end if female.is_ready_to_deliver?
        end

        # HISTORY/METRICS #####################################################
        # record population metrics in history

      end
    end


  end
end