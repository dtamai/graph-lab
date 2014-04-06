require_relative 'helper'

describe Graph do

  before do
    @graph = Graph.new("test", "test")
  end

  def rand_number
    rand(100)
  end

  describe "[nodes]" do
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

  describe "[edges]" do
    before do
      3.times do |i|
        @graph.add_node Node.new(i)
      end
    end

    describe "#add_edge" do
      it "increments the edge count" do
        @graph.add_edge Edge.new("test_id", 0, 1)
        assert_equal 1, @graph.edge_count
      end

      it "ignores repeated edges" do
        edge = Edge.new("test_id", 0, 1)
        @graph.add_edge edge
        @graph.add_edge edge
        assert_equal 1, @graph.edge_count
      end

      it "raises for invalid node ids" do
        edge1 = Edge.new("test_id_1", 0, 10)
        edge2 = Edge.new("test_id_2", 10, 0)
        assert_raises Graph::IdError do
          @graph.add_edge edge1
        end
        assert_raises Graph::IdError do
          @graph.add_edge edge2
        end
      end
    end

    describe "#edge_count" do
      it "returns the number of edges in the graph" do
        [0, 1, 2].combination(2).each do |pair|
          @graph.add_edge(Edge.new("id", pair[0], pair[1]))
        end
        assert_equal 3, @graph.edge_count
      end
    end
  end

end
