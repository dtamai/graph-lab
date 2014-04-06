require 'set'

class Graph
  class IdError < IndexError; end

  attr_reader :id, :label
  attr_accessor :edges

  def initialize(id, label="")
    @id = id
    @label = label
    @nodes = Set.new
    @nodes_order = Array.new
    @edges = Array.new
  end

  def add_node(node)
    if @nodes.add?(node)
      @nodes_order << node.id
    end
  end

  def get_node_by_id(id)
    node = @nodes.select { |n| n.id == id }.first
    raise IdError, "unknown node id=#{id}" unless node
    node
  end

  def get_node_by_index(index)
    get_node_by_id(@nodes_order[index])
  end

  def node_count
    @nodes.size
  end

  def nodes
    @nodes.to_enum
  end

  DATA_DIR="data"
  def write_csv(nodes_file=File.join(DATA_DIR, "nodes.csv"),
                edges_file=File.join(DATA_DIR, "edges.csv"))
    File.open(nodes_file, 'w') do |f|
      f << Node.csv_header
      f << "\n"
      f << @nodes.map(&:to_csv).join("\n")
    end

    File.open(edges_file, 'w') do |f|
      f << Edge.csv_header
      f << "\n"
      f << @edges.map(&:to_csv).join("\n")
    end
  end
end
