class BarabasiAlbert < Model

  INIT_PROB ||= 0.4

  private
  def prepare
    clear_edges
  end

  def run
    print "  - initializing random graph..."
    seed, remaining = init_random_graph

    print "  - adding nodes..."
    add_nodes(seed, remaining)
  end

  def terminate
  end

  def clear_edges
    @graph.clear_edges
  end

  def init_random_graph
    seed, remaining = sample_split(@graph.nodes.to_a)
    seed.combination(2) { |c| draw_link(c, INIT_PROB) }
    unless has_enough_edges
      clear_edges
      return init_random_graph
    end
    puts "    - seed: nodes=#{seed.size} edges=#{@graph.edge_count}"
    [seed, remaining]
  end

  def sample_split(nodes)
    size = [nodes.size * 0.2, 3].max
    s = nodes.to_a.sample(size)
    [s, nodes - s]
  end

  def draw_link(pair, prob)
    if Random.rand < prob
      @graph.add_edge(Edge.new(@graph.edge_count, pair[0].id, pair[1].id))
    end
  end

  def has_enough_edges
    has = @graph.edge_count >= 3
    has ? (puts "ok") : (print ".")

    has
  end

  def weight(node)
    @graph.edges.select do |e|
      e.source == node.id || e.target == node.id
    end.size
  end

  def add_nodes(seed, remaining)
    while rem = remaining.pop
      seed.each do |n|
        draw_link([rem, n], weight(n).to_f/@graph.edge_count)
      end
      seed << rem
      print "."
    end
    puts "ok"
    puts "    - graph: nodes=#{seed.size} edges=#{@graph.edge_count}"
  end
end

