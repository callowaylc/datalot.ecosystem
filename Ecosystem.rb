# Author: Christian Calloway callowaylc@gmail

module Ecosystem

  module Element
  end

  # Represents a habitat in the ecosystem
  module Habitats
    include Element

    def hello
      "hello from habitat"
    end
  end

  module Species
    include Element

    def hello
      "hello from species"
    end
  end

end