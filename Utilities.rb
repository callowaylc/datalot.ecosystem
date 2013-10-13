# Author: Christian Calloway callowaylc@gmail

# Recreate rails concept of attr_accessor_with_default
module ExtendAccessors
  def attr_accessor_with_default(name, *default, &block)
    if(default.size >= 1)
      define_method name.to_sym do
        instance_variable_set("@#{name}", default[0]) unless instance_variable_defined?("@#{name}")
        instance_variable_get("@#{name}")
      end
    elsif block_given?
      define_method name.to_sym do
        instance_variable_set("@#{name}", instance_eval(&block)) unless instance_variable_defined?("@#{name}")
        instance_variable_get("@#{name}")
      end
    else
      raise "Must either provide a default value or a default code block"
    end
    define_method "#{name}=".to_sym do |value|
      instance_variable_set("@#{name}",value)
    end
  end

  def attr_changed(name)
    define_method "#{name}=".to_sym do |value|

      # retrieve old value, if it does exist
      old = nil

      begin
        old = instance_variable_get("@#{name}")
      rescue => ignore
      end

      instance_variable_set("@#{name}", value)

      # now yield update event
      yield(name, value, old)
      
    end
  end
end

Object.extend ExtendAccessors



# Patch string class to provide ucfirst define_method

class String
  # adding ucfirst method to string
  def ucfirst
    self.sub(/^\w/) { |string| string.capitalize }
  end
end