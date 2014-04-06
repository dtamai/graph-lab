require_relative 'models/node'
require_relative 'models/edge'
require_relative 'models/graph'
require_relative 'models/model'
require_relative 'models/barabasi_albert'
require_relative 'models/watts_strogatz'

g = Graph.new(1, "BA")

n = 10
k = 4
ϐ = 0.2

1.upto(n) do |n|
  g.nodes << Node.new(n)
end

WattsStrogatz.apply(g, k, ϐ)

g.write_csv
