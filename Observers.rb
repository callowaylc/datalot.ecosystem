# Author : Christian Calloway callowalc@gmail

# Contains definitions for species and habitat observers

module Ecosystem
  module Observers

    class Observer
      include Singleton
    end

    # responsible for updating species specific context
    class Species < Observer
      
      def update(simulation, time)
        animals  = simulation.habitat.animals
        interval = time.interval

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
      def update(simulation, time)
        habitat  = simulation.habitat        
        interval = time.interval

        # assign current time to habitat
        # @todo remove this later because habitat should not be contextually
        # aware of time, but is needed now to perform uniform operations on
        # habitat
        habitat.time = time

        
        # DEATH ###############################################################
        # iterate through shuffled list of animals 
        habitat.animals.each do |animal|

          # first we address an animals interactions with the habitat;
          # we do this by iterating through an array of symbol representing
          # interactions with the environment - before running an interaction
          # we check if the animal is still alive
          died = false


          handle_death = lambda do |cause|
            habitat.remove animal
            history.note_a :death, from: cause
          end

          # @note I'd like to encapsulate the metrics of death here
          # @note below is awkward; need to change interface
          interactions = [
            %i{ eats_from   starves_for }
            %i{ drinks_from thirsts_for }
            %i{ exposed_to  exposed_for }
          
          ].each do |actions|

            # first thing we need to check is if the animal died;
            # if the case, we remove from habitat and note cause
            # of death
            if died = animal.died? &handle_death
              # remove from habitat
              habitat.remove animal

              # store history of cause of death
              # still need to determine how this looks
              history.something cause
            
            # otherwise the animal is still alive and we perform an interaction
            # on the environment
            end or begin       

              # assigning to scalars to make a bit more interactive
              interacts_with, suffers_for = actions

              # perform actual interaction or increment intervals of suffering
              animal.send(interacts_with, habitat) or animal.send(suffers_for, interval)
            end

            # if our animal has died we break from a "interactions"
            # loop as the animal obviously no longer needs to interact
            # with the environment
            died && break
         
          end

          # check if animal died after last iteration
          # @todo this is really awkward and we need to update the interface
          # for checking animal death
          died || animal.died? do |cause|
            # remove from habitat
            habitat.remove animal

            # store history of cause of death
            # still need to determine how this looks
            history.something cause  
          end

        end

        # MATING AND DELIVERY #################################################
        # determine if habitat can support further breeding or we fall under 
        # statistical sig threshold ; if the case, find available mates left in population
        if !habitat.depleted? || rand <= .005

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