class Portal
  def initialize(args={})
    @data = {
      "title" => nil,
      "lat" => nil,
      "lng" => nil
    }.merge(args)
  end

  def title
    @data["title"]
  end

  def lat
    @data["lat"]
  end

  def lng
    @data["lng"]
  end
  
  def to_json
    @data.to_json
  end

  def data
    @data
  end
end
