class WattsStrogatz < Model

  def initialize(graph, k, ϐ)
    super(graph)

    validate k, ϐ

    @k = k
    @ϐ = ϐ
  end

  private

  def prepare
    @edges.clear
    @edge_count = 0

    print "  - creating regular lattice ring..."
    create_ring(@k/2)
    puts "ok"
  end

  def run
  end

  def terminate
  end

  def validate(k, ϐ)
    n = @nodes.size
    ln_N = Math.log(n)

    invalids = []
    invalids << "[k=#{k} k must be even]" unless k.even?
    invalids << "[ϐ=#{ϐ} beta must be [0, 1]]" unless (0..1).include? ϐ
    invalids << "[k=#{k} N=#{n} k must be less then N]" unless k < n
    invalids << "[k=#{k} ln(N)=%.2f k must be greater than ln(N)]" % ln_N unless k > ln_N
    invalids << "[ln(N)=%.2f ln(N) must be greater than 1]" % ln_N unless ln_N > 1
    raise ArgumentError, invalids.join(' ') if invalids.size > 0
  end

  def create_ring(distance)
    return if distance == 0

    size = @nodes.size
    low_arc_indexes = 0..(size - distance - 1)
    high_arc_indexes = (low_arc_indexes.max + 1)..(size - 1)

    low_arc_indexes.each do |i|
      add_edge([@nodes[i], @nodes[i + distance]])
    end

    high_arc_indexes.each do |i|
      add_edge([@nodes[i], @nodes[distance - size + i]])
    end

    create_ring(distance - 1)
  end

  def add_edge(pair)
    @edges << Edge.new(@edge_count, source=pair[0].id, target=pair[1].id)
    @edge_count += 1
  end

end
