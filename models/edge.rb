class Edge
  attr_reader :id, :label
  attr_accessor :source, :target

  def initialize(id, label="", source, target)
    @id = id
    @label = label
    @source = source
    @target = target
  end

  def self.csv_header
    "id,source,target"
  end

  def to_csv
    "#{id},#{source},#{target}"
  end
end
