class Model

  def self.apply(*args)
    self.new(*args).apply
  end

  def initialize(graph)
    puts "Applying #{self.class.name} model to graph"
    @graph = graph
    @nodes = graph.nodes
    @edges = graph.edges
  end

  def apply
    prepare
    run
    terminate

    nil
  end

  private

  def prepare
    raise "Uninmplemented model"
  end

  def run
    raise "Unimplemented model"
  end

  def terminate
    raise "Unimplemented method"
  end
end
