

# class RDFHelp
#   class << self
#     def raw_value(obj)
#       if obj.is_a? RDF::URI
#         obj.to_s
#       elsif obj.is_a? RDF::Literal
#         obj.object
#       else
#         raise "not an RDF Literal or URI: #{obj}"
#       end
#     end
#   end
# end

module RDF
  class URI
    alias_method :raw, :to_s
  end

  class Literal
    alias_method :raw, :object
  end
end
