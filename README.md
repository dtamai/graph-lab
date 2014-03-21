graph-lab
=========

## Models

To create a graph using the Barabási-Albert model:

```ruby
g = Graph.new(1, "BA")

1.upto(20) do |n|
  g.nodes << Node.new(n)
end

BarabasiAlbert.new(g).apply
```

And to dump the graph to csv file that can be imported into Gephi:

```ruby
g.write_csv
```
