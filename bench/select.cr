# box.schema.space.create('test')
# box.schema.sequence.create('test_primary_index')
# box.space.test:create_index('primary', {type = 'TREE', sequence = 'test_primary_index'})

require "../src/tarantool"
require "benchmark"

db = Tarantool::Connection.new("localhost", 3301)
db.parse_schema

COUNT = 100_000
channel = Channel(Int32).new(COUNT)

puts Benchmark.measure {
  COUNT.times do |i|
    spawn do
      db.select(:test, 0, {1}, limit: 1)
      channel.send(i)
    end
  end

  COUNT.times do
    channel.receive
  end
}
