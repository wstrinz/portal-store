class PortalStore
  extend Enumerable

  class << self
    def prefixes
      {
        "" => 'http://ingress-portals.crabdance.com/vocab/',
        portal: 'http://ingress-portals.crabdance.com/portal/'
      }
    end

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

    def each &block
      Enumerator.new do |enum|
        portal_uris.each do |portal|
          if block_given?
            block.call Portal.from_rdf(repo, portal)
          else
            enum.yield Portal.from_rdf(repo, portal)
          end
        end
      end
    end
    alias_method :each_portal, :each

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
        f.write repo.dump(:jsonld, prefixes: prefixes)
        #f.write store.map(&:data).to_json
      }
    end

    def <<(portal)
     raise "#{portal} not a Portal!" unless portal.is_a?(Portal)
     repo << portal.to_rdf
    end
  end
end
