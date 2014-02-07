class Portal
  BASE_URI = 'http://ingress-portals.crabdance.com/'
  FIELDS = %w(title image level latE6 health resCount lngE6 team type)

  def self.from_rdf(repo, uri)
    portal_data = RDF::Query.execute(repo, {
      uri => FIELDS.each_with_object({}){|f, h| h[vocab[f]] = f.to_sym}
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
    }.merge(args)
  end

  def title
    @data["title"]
  end

  def lat
    @data["latE6"]
  end

  def lng
    @data["lngE6"]
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
    RDF::URI.new(BASE_URI + 'portal/' + "#{title.gsub(" ","+")}_#{lat}_#{lng}")
  end

  def to_rdf
    g = RDF::Graph.new
    g << [uri, RDF.type, vocab.Portal]
    FIELDS.each do |f|
      g << [uri, vocab[f], @data[f]] if @data[f]
    end
    g
  end
end
