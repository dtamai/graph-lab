class Model
  def initialize(graph)
    puts "Applying #{self.class.name} model to graph"
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