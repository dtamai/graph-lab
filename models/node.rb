class Node
  attr_reader :id, :label

  def initialize(id, label="")
    @id = id
    @label = label
  end

  def self.csv_header
    "id"
  end

  def to_csv
    "#{id}"
  end
end
