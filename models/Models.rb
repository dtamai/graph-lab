require_relative 'Node'
require_relative 'Edge'
require_relative 'Graph'
require_relative 'BarabasiAlbert'

g = Graph.new(1, "BA")

1.upto(20) do |n|
  g.nodes << Node.new(n)
end

BarabasiAlbert.new(g).apply

g.write_csv


