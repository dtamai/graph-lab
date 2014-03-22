class Graph
  attr_reader :id, :label
  attr_accessor :nodes, :edges

  def initialize(id, label="")
    @id = id
    @label = label
    @nodes = Array.new
    @edges = Array.new
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
