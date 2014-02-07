class Memo
  class << self
    attr_accessor :portals
  end
end

require 'sinatra'
require 'sinatra/reloader'
require 'json/ld'
require 'rdf/rdfa'

helpers do
  def prefixes
    {
      "" => 'http://ingress-portals.crabdance.com/vocab/'
    }
  end

  def table_doc
<<-'EOF'
!!! XML
!!! 5
%html{:xmlns => "http://www.w3.org/1999/xhtml", :lang => lang, :prefix => prefix}
  %head
    - if base
      %base{:href => base}
    - if title
      %title= title
    %link{:rel => "stylesheet", :href => "/portals.css", :type => "text/css"}
    %script{:src => "https://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js", :type => "text/javascript"}
  %body
    - if base
      %p= "RDFa serialization URI base: &lt;#{base}&gt;"
    - subjects.each do |subject|
      != yield(subject)
    %footer
      %p= "Written by <a href='http://rubygems.org/gems/rdf-rdfa'>RDF::RDFa</a> version #{RDF::RDFa::VERSION}"
EOF
  end

  def default_doc
<<-'EOF'
!!! XML
!!! 5
%html{:xmlns => "http://www.w3.org/1999/xhtml", :lang => lang, :prefix => prefix}
  %head
    - if base
      %base{:href => base}
    - if title
      %title= title
    %link{:rel => "stylesheet", :href => "/portals.css", :type => "text/css"}

  %body
    - subjects.each do |subject|
      != yield(subject)
  end
EOF
  end

  def template
    #RDF::RDFa::Writer::DISTILLER_HAML.merge(doc: table_doc)
    RDF::RDFa::Writer::DEFAULT_HAML.merge(doc: default_doc)
  end

  def portal_rdfa(file = "portals.json")
    Memo.portals ||= RDF::Repository.load(file)
    Memo.portals.dump(:rdfa, prefixes: prefixes, haml: template)
  end
end

get '/' do
  portal_rdfa
end
