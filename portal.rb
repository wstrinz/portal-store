
class Portal
  BASE_URI = 'http://ingress-portals.crabdance.com/'

  def self.from_rdf(repo, uri)
    portal_data = RDF::Query.execute(repo, {
      uri => {
        vocab.title => :title,
        vocab.latitude => :lat,
        vocab.longitude => :lng
      }
    }).map(&:to_hash)

    # stringify keys
    portal_data = portal_data.map{|portal|
      portal.each_with_object({}){ |entry, h|
        h[entry.first.to_s] = entry.last.raw
      }
    }

    self.new(portal_data.first)
  end

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

  def self.vocab
    RDF::Vocabulary.new BASE_URI + 'vocab/'
  end

  def vocab
    Portal.vocab
  end

  def uri
    RDF::URI.new(BASE_URI + 'portal/' + title.gsub(" ","+"))
  end

  def to_rdf
    g = RDF::Graph.new
    g << [uri, RDF.type, vocab.Portal]
    g << [uri, vocab.title, title]
    g << [uri, vocab.latitude, lat]
    g << [uri, vocab.longitude, lng]
    g
  end
end
