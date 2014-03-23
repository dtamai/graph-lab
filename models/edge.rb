class Edge
  attr_reader :id, :label, :type
  attr_accessor :source, :target

  def initialize(id, label="",type="undirected", source, target)
    @id = id
    @label = label
    @source = source
    @target = target
    @type = type
  end

  def self.csv_header
    "id,source,target,type"
  end

  def to_csv
    "#{id},#{source},#{target},#{type}"
  end
end
