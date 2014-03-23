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

To create a graph using the [Watts-Strogatz](https://en.wikipedia.org/wiki/Watts_and_Strogatz_model) model:

```ruby
g = Graph.new(1, "WS")

1.upto(20) do |n|
  g.nodes << Node.new(n)
end

k = 4
ϐ = 0.2

BarabasiAlbert.new(g, k, ϐ).apply
```
where k is the mean degree and ϐ is a parameter that indicates the randomness of the graph.

