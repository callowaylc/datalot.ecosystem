# Author: Christian Calloway callowaylc@gmail
require 'Observable'

module Ecosystem

  # provides utility methods that can be mixed into hash
  # data for habitats and species
  module Attributes

    # Represents a habitat in the ecosystem; plurality is just for
    # an easy match on data 
    module Habitats 
    end

    module Species
    end
  end

  class History 

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
    end    

    # iterate the passage of time by interval constant
    def tick

      # increment time
      @current += INTERVAL 

      # notify observers of the passage of time; we are passing self
      # here which tightly couples Ticker to observer but in the 
      # interest of a solution..
      notify_observers(self)


    end

    # determines if there is time left in current iteration
    def is_left?
      @current >= @total
    end
  end

  class Animal
    attr_accessor :sex

    def female?
    end

  end

  class Habitat

    attr_accessor :animals

    def initialize
      # add adam/eve 
      @animals = [ ]


    end

    def refresh
    end

    def temperature
    end

  end

end