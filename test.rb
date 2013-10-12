class Test

  def initialize(&block)
    @property = 'hello'

    instance_exec 'suckit', &block
  end
end

t = Test.new { |argument| puts argument; puts @property }
