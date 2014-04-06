require_relative 'helper'

describe WattsStrogatz do

  before do
    @nodes = Array.new(10) { |i| Node.new(i) }
    @graph = Graph.new("test", "WS")

    @nodes.each do |node|
      @graph.add_node node
    end
  end

  describe "::apply" do
    it "preserves all nodes" do
      WattsStrogatz.apply(@graph, 4, 0.2)
      assert_equal @graph.nodes.map(&:id).sort, @nodes.map(&:id).sort
    end

    it "creates edges" do
      WattsStrogatz.apply(@graph, 4, 0.2)
      assert @graph.edge_count > 0
    end
  end
end

