require_relative 'helper'

describe Graph do

  before do
    @graph = Graph.new("test", "test")
  end

  def rand_number
    rand(100)
  end

  describe "#add_node" do
    it "increments the node count" do
      @graph.add_node Node.new(rand_number)
      assert_equal 1, @graph.node_count
    end

    it "ignores repeated nodes" do
      node = Node.new rand_number
      @graph.add_node node
      @graph.add_node node
      assert_equal 1, @graph.node_count
    end
  end

  describe "#get_node_by_id" do
    it "returns a node from the graph" do
      id = rand_number
      node = Node.new(id)
      @graph.add_node node
      assert_equal node, @graph.get_node_by_id(id)
    end

    it "raises for invalid node ids" do
      assert_raises Graph::IdError do
        @graph.get_node_by_id(rand_number)
      end
    end
  end

  describe "#get_node_by_index" do
    it "return the node by its insertion number" do
      id = rand_number
      node = Node.new(id)
      @graph.add_node node
      assert_equal node, @graph.get_node_by_index(0)
    end
  end

  describe "#node_count" do
    it "returns the number of nodes in the graph" do
      n = 3
      n.times do |i|
        @graph.add_node Node.new(i)
      end
      assert_equal n, @graph.node_count
    end
  end
end
