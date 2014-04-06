require_relative 'helper'

describe BarabasiAlbert do

  before do
    @nodes = Array.new(10) { |i| Node.new(i) }
    @graph = Graph.new("test", "BA")

    @nodes.each do |node|
      @graph.add_node node
    end
  end

  describe "::apply" do
    it "preserves all nodes" do
      BarabasiAlbert.apply(@graph)
      assert_equal @graph.nodes.map(&:id).sort, @nodes.map(&:id).sort
    end

    it "creates edges" do
      BarabasiAlbert.apply(@graph)
      assert @graph.edge_count > 0
    end
  end
end
