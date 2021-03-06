class WattsStrogatz < Model

  def initialize(graph, k, ϐ)
    super(graph)

    validate k, ϐ

    @k = k
    @ϐ = ϐ
  end

  private

  def prepare
    @graph.clear_edges
  end

  def run
    print "  - creating regular lattice ring..."
    create_ring(@k/2)
    puts "ok"

    print "  - rewiring nodes..."
    rewire_nodes
    puts "ok"
  end

  def terminate
  end

  def validate(k, ϐ)
    n = @graph.node_count
    ln_N = Math.log(n)

    invalids = []
    invalids << "[K=#{k} K must be even]" unless k.even?
    invalids << "[ϐ=#{ϐ} beta must be [0, 1]]" unless (0..1).include? ϐ
    invalids << "[K=#{k} N=#{n} N must be greater (2 times) than K]" unless n > 2*k
    invalids << "[K=#{k} ln(N)=%.2f K must be greater than ln(N)]" % ln_N unless k > ln_N
    invalids << "[ln(N)=%.2f ln(N) must be greater than 1]" % ln_N unless ln_N > 1
    raise ArgumentError, invalids.join(' ') if invalids.size > 0
  end

  def create_ring(distance)
    return if distance == 0

    size = @graph.node_count
    low_arc_indexes = 0..(size - distance - 1)
    high_arc_indexes = (low_arc_indexes.max + 1)..(size - 1)

    low_arc_indexes.each do |i|
      add_edge([@graph.get_node_by_index(i), @graph.get_node_by_index(i + distance)])
    end

    high_arc_indexes.each do |i|
      add_edge([@graph.get_node_by_index(i), @graph.get_node_by_index(distance - size + i)])
    end

    create_ring(distance - 1)
  end

  def add_edge(pair)
    @graph.add_edge(Edge.new(@graph.edge_count, pair[0].id, pair[1].id))
  end

  def rewire_nodes
    size = @graph.node_count

    0.upto(size - 1) do |i|
      source_id = @graph.get_node_by_index(i)

      # Save all target nodes before rewiring, otherwise this may not converge
      targets_ids = @graph.edges.select { |e| e.source == source_id }.map(&:target)
      targets_ids.each do |target_id|
        new_target_id = draw_new_target(source_id)
        draw_rewire(source_id, target_id, new_target_id, @ϐ)
      end
    end
  end

  def draw_new_target(id)
    # Targets will change when rewiring, so a new check is required
    unavailable = @graph.edges.select { |e| e.source == id }.map(&:target)
    unavailable.concat @graph.edges.select { |e| e.target == id }.map(&:source)
    unavailable.concat [id]
    new_target_id = @nodes[Random.rand(@nodes.size)].id

    unless unavailable.include? new_target_id
      return new_target_id
    else
      return draw_new_target(id)
    end
  end

  def draw_rewire(i, j, k, prob)
    if Random.rand < prob
      edge = @graph.edges.select { |e| e.source == i && e.target == j }.pop
      edge.target = k
    end
  end

end
