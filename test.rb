require 'observer'

class Test
  include Observable

  def initialize
    add_observer(Observer.new)
  end

  def test
    changed true
    notify_observers
  end
end

class Observer
  def update
    puts "called updated"
  end
end

t = Test.new
t.test