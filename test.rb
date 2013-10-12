class Test
  attr_accessor :test

end

t = Test.new
t.test << 1

puts t.test