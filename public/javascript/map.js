var map = L.map('map').setView([43.07572, -89.38528], 13);

L.tileLayer('http://{s}.tile.cloudmade.com/06374E2EBDB94876A5809F68EA929231/997/256/{z}/{x}/{y}.png', {
  attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>',
  maxZoom: 18
}).addTo(map);

map.locate({setView: true, maxZoom: 16});

$.get('portals.json', function(portals) {
  portals = JSON.parse(portals)
  //var mad_kiosks = _.filter(portals.d.list, function(k){ return k.Address.City == "Madison" });
  var locs = _.map(portals["@graph"], function(p){
    return {
      title: p[":title"],
      lat: (+ p[":latE6"]["@value"]) / 1000000,
      team: (p[":team"]),
      resonators: (p[":resCount"]["@value"]),
      lng: (+ p[":lngE6"]["@value"]) / 1000000
    }
  });

  locs = _.filter(locs, function(l){ return !(isNaN(l.lat + l.lng)) })

  var portal_names = _.map(locs, function(p){ return p.title });
  $('#txt').text(portal_names)

  var markers = _.map(locs, function(l){
    return L.marker([l.lat, l.lng]).addTo(map)
  })

  var greenIcon = L.icon({
    iconUrl: 'http://maps.google.com/mapfiles/marker_green.png',

    iconSize:     [28, 45],
    iconAnchor:   [14, 45],
    popupAnchor:  [-3, -26]
  });

  var greyIcon = L.icon({
    iconUrl: 'http://maps.google.com/mapfiles/marker_grey.png',

    iconSize:     [28, 45],
    iconAnchor:   [14, 45],
    popupAnchor:  [-3, -26]
  });

  for(i=0;i<markers.length;i++){
    portal = locs[i]
    var team = portal.team
    var title = portal.title
    var resos = portal.resonators

    markers[i].bindPopup("<b>" + title + "</b><br> Team: " + team + "<br> Resonators: " + resos )

    if(team == "NEUTRAL")
      markers[i].setIcon(greyIcon)
    else if(team == "ENLIGHTENED")
      markers[i].setIcon(greenIcon)
  }
})
