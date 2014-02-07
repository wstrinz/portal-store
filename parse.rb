require './portal_store'

#class Del
#  include Delaunay
#end
def parse_entities(ents)
  ents.to_s
  ents.map(&:last).select{|e| e["type"] == "portal"}
  #.map{|e|

  # {
  #   "title" => e["title"],
  #   "lat" => e["latE6"],
  #   "lng" => e["lngE6"],
  #   "resCount" => e["resCount"],
  #   "health" => e["resCount"],
  #   "team" => e["team"]
  # }
  #}
end

def parse_log_entity(entity)
  entity.find{|field| field.first == "PORTAL"}.last
# {
#   "title" => portal["name"],
#   "lat" => portal["latE6"],
#   "lng" => portal["lngE6"]
# }
end

def extract_from_json(json)
  js = json
  if js["result"]
    if js["result"].is_a?(Array)
      ents = js["result"].map(&:last)
        .select{|e| e["plext"] && e["plext"]["markup"] }
        .select{|e| e["plext"]["markup"].any?{|field| field.first == "PORTAL"}}
      unless ents.empty?
        return ents.map{|e|
          parse_log_entity e["plext"]["markup"]
        }
      end
    elsif js["result"]["map"]
      return js["result"]["map"].map{|e|
        parse_entities e.last["gameEntities"]
      }
    end
  end

  nil
end

def parse_file(f)
	js = JSON.parse(IO.read f)
  data = extract_from_json(js)
  #puts "Can't find ingress data in file " + f.to_s unless data
  data
end

def parse_batch_file(f)
  f = open(f)
  f.each_line.each_with_index.map do |line, i|
    js = JSON.parse(line)
    data = extract_from_json(js)
    #puts "no data on line" + i.to_s unless data
    data
  end
end

def inval(msg, file)
  #puts msg + ": " + file
  false
end

def json_valid?(string)
  JSON.parse(string)
  return true
rescue JSON::ParserError
  return false
end

def file_valid?(file)
  if File.exist?(file)
    if json_valid? IO.read(file)
      true
    else
      inval "not a json file", file
    end
  else
    inval "File does not exist", file
  end
end

def parse_folder(fo)
  fs = Dir.glob(File.join(fo,"**"))
  fs.select{|fi| file_valid? fi}
    .map{|fi| parse_file fi}
end

def to_coord(int)
  int.to_f / 1000000
end

def coordinate_list(portals)
  portals.map{|p|
    {title: p[:title], coordinates: Coord.new[to_coord(p[:lat]), to_coord(p[:lng])]}
  }
end

def parse
  portals = parse_batch_file('json_dump').flatten.compact.uniq
  PortalStore.load
  #require 'pry'; binding.pry
  portals.each do |p|
    PortalStore << Portal.new(p)
  end

  PortalStore.export
 #p = PortalStore.find("Dick-Eddy Buildings")
 #g = p.to_rdf
 #p2 = Portal.from_rdf(g, p.uri)
 #puts p2.to_rdf.dump(:ttl)
 #PortalStore.store.clear
 #PortalStore.load
end

if __FILE__ == $0
  parse
end
