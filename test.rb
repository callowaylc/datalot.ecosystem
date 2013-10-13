h = { a: 'aaa', b: 'bbb', c: 'ccc' }
k = nil

h.each { |key, value | k = key; puts value; break }
puts k
