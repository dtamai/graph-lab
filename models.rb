require_relative 'models/node'
require_relative 'models/edge'
require_relative 'models/graph'
require_relative 'models/model'
require_relative 'models/barabasi_albert'

g = Graph.new(1, "BA")

1.upto(20) do |n|
  g.nodes << Node.new(n)
end

BarabasiAlbert.new(g).apply

g.write_csv


