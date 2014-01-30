class PortalStore
  class << self
    def store
      @store ||= []# RDF::Repository.new
    end

    def repo
      @repo ||= RDF::Repository.new
    end

    def load(file='portals.json')
      repo.load(file)
    end

    def portal_uris
      RDF::Query.execute(repo, {
        portal: {
          RDF.type => Portal.vocab.Portal,
        }
      }).map(&:portal)
    end

    def find(title)
      results = RDF::Query.execute(repo, {
        portal: {
          RDF.type => Portal.vocab.Portal,
          Portal.vocab.title => title
        }
      }).map(&:portal)

      if results.first
        Portal.from_rdf(repo, results.first)
      else
        nil
      end
    end

    def export(file='portals.json')
      open(file, 'w'){|f|
        f.write repo.dump(:jsonld)
        #f.write store.map(&:data).to_json
      }
    end

    def <<(portal)
     raise "#{portal} not a Portal!" unless portal.is_a?(Portal)
     repo << portal.to_rdf
    end
  end
end
