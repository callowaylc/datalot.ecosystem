
h = { a: 'a', b: 'b', c: 'c' }

k = nil
h.each { |key, value| k = key}
  
puts k
