class BarabasiAlbert

  INIT_PROB ||= 0.4

  def initialize(graph)
    puts "Applying Barabási-Albert model to graph"
    @nodes = graph.nodes
    @edges = graph.edges
  end

  def apply
    @edges.clear
    @edge_count = 0
    run_model

    nil
  end

  private
  def run_model
    # initializing
    print "  - initializing random graph..."
    seed, remaining = sample_split(@nodes)
    seed.combination(2) { |c| draw_link(c, INIT_PROB) }
    unless has_enough_edges
      self.apply
      return
    end

    # adding nodes
    while rem = remaining.pop
      seed.each do |n|
        draw_link([rem, n], weight(n).to_f/@edge_count)
      end
      seed << rem
    end
    puts "  - created #{@edge_count} edges"
  end

  def sample_split(nodes)
    size = [nodes.size * 0.2, 3].max
    s = nodes.sample(size)
    [s, nodes - s]
  end

  def draw_link(pair, prob)
    if Random.rand < prob
      @edges << Edge.new(@edge_count, source=pair[0].id, target=pair[1].id)
      @edge_count += 1
    end
  end

  def has_enough_edges
    r = @edge_count >= 3
    puts r ? "ok" : "failed"
    r
  end

  def weight(node)
    @edges.select do |e|
      e.source == node.id || e.target == node.id
    end.size
  end
end

