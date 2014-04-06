graph-lab
=========

## Models

To create a graph using the [Barabási-Albert](https://en.wikipedia.org/wiki/Barab%C3%A1si%E2%80%93Albert_model) model:

```ruby
g = Graph.new(1, "BA")

1.upto(20) do |n|
  g.nodes << Node.new(n)
end

BarabasiAlbert.apply(g)
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

WattsStrogatz.apply(g, k, ϐ)
```
where k is the mean degree and ϐ is a parameter that indicates the randomness of the graph.

