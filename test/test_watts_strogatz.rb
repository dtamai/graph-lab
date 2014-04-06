require_relative 'helper'

describe WattsStrogatz do

  before do
    @nodes = Array.new(10) { |i| Node.new(i) }
    @graph = Graph.new("test", "WS")
    @graph.nodes = @nodes
  end

  describe "::apply" do
    it "preserves all nodes" do
      WattsStrogatz.apply(@graph, 4, 0.2)
      assert_equal @graph.nodes, @nodes
    end

    it "creates edges" do
      WattsStrogatz.apply(@graph, 4, 0.2)
      assert @graph.edges.size > 0
    end
  end
end

