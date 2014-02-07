class Memo
  class << self
    attr_accessor :portals
  end
end

require 'sinatra'
require 'sinatra/reloader'
#require 'sinatra/linkeddata'
require 'json/ld'
require 'rdf/rdfa'

helpers do
  def prefixes
    {
      "" => 'http://ingress-portals.crabdance.com/vocab/',
      portal: 'http://ingress-portals.crabdance.com/portal/'
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

  def dump_formats
    {
      "json" => :jsonld
    }
  end

  def template
    #RDF::RDFa::Writer::DISTILLER_HAML.merge(doc: table_doc)
    RDF::RDFa::Writer::DEFAULT_HAML.merge(doc: default_doc)
  end

  def portal_data
    Memo.portals ||= RDF::Repository.load("portals.json", format: :jsonld)
  end

  def portal_rdfa
    Memo.portals.dump(:rdfa, prefixes: prefixes, haml: template)
  end
end

get '/' do
  portal_rdfa
end

get '/map' do
  haml :map
end


get '/portals.?:format?' do
  format = params[:format]
  opts = {prefixes: prefixes}

  if format
    format = dump_formats[params[:format]] || format.to_sym
  elsif request.accept? "text/html"
    format = :rdfa
    opts[:haml] = template
  end

  if format
    portal_data.dump(format, opts)
  else
    portal_data
  end
end
