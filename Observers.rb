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
      end
      
      
    end

    # responsible for updating habitat specific context
    class Habitat < Observer
      def update(simulation, time)
        
        # iterate through shuffled list of animals so preference
        # to resources is not based on queue order
        simulation.habitat.animals.shuffle.each do |animal|

          # first we check the parameters of death, namely
          # has the species aged 
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