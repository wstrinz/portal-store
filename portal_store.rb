class PortalStore
  class << self
    def store
      @store ||= []
    end

    def load(file='portals.json')
      JSON.parse(IO.read(file)).each do |p|
        store << Portal.new(p)
      end
    end

    def export(file='portals.json')
      open(file, 'w'){|f|
        f.write store.map(&:data).to_json
      }
    end

    def <<(portal)
      raise "#{portal} not a Portal!" unless portal.is_a?(Portal)
      store << portal 
    end
  end
end
