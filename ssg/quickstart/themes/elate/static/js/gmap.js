
var google;

function initialize() {
    var myLatlng = new google.maps.LatLng(8.7832, 34.5085);
    
    var ivorycoastString = '<div id="content">'+
            '<div id="siteNotice">'+
            '</div>'+
            '<h1 id="firstHeading" class="firstHeading">2018 Côte d’Ivoire</h1>'+
            '<div id="bodyContent">'+
            '<h4><b>869</b>, Number of observers who sent in data </h4>'+
            '</div>'+
            '</div>';

    var libyaString = '<div id="content">'+
            '<div id="siteNotice">'+
            '</div>'+
            '<h1 id="firstHeading" class="firstHeading">Libya</h1>'+
            '<div id="bodyContent">'+
            '<h4>Libyan leaders postponed national elections to Spring 2019 due to spike in violence </h4>'+
            '</div>'+
            '<p><a href="https://www.reuters.com/article/us-libya-security/rival-libya-leaders-meet-for-first-time-since-may-pm-oks-2019-vote-idUSKCN1NI12Y" target="_blank">Reuters</a> '+
            '(NOVEMBER 13, 2018).</p>'+
 
            '</div>';
    var maliString = '<div id="content">'+
            '<div id="siteNotice">'+
            '</div>'+
            '<h1 id="firstHeading" class="firstHeading">2018 Mali</h1>'+
            '<div id="bodyContent">'+
            '<h4>had <b>1179</b> of observers send in data through Apollo </h4>'+
            '</div>'+
            '</div>';

    var nigeriaString = '<div id="content">'+
            '<div id="siteNotice">'+
            '</div>'+
            '<h1 id="firstHeading" class="firstHeading">2018 Nigeria</h1>'+
            '<div id="bodyContent">'+
            '<h4>had <b>1868</b> of observers who sent in data through Apollo</h4>'+
            '</div>'+
            '</div>';

    var serbiaString = '<div id="content">'+
            '<div id="siteNotice">'+
            '</div>'+
            '<h1 id="firstHeading" class="firstHeading">2018 Serbia</h1>'+
            '<div id="bodyContent">'+
            '<h4><b>~500</b> citizens surveyed about their perception of disinformation with Apollo GeoODK integration</h4>'+
            '</div>'+
            '</div>';
    var tunisiaString = '<div id="content">'+
            '<div id="siteNotice">'+
            '</div>'+
            '<h1 id="firstHeading" class="firstHeading">2018 Tunisia</h1>'+
            '<div id="bodyContent">'+
            '<h4>had <b>2118</b> of observers send in data with Apollo </h4>'+
            '</div>'+
            '</div>';
    var zimbabweString = '<div id="content">'+
            '<div id="siteNotice">'+
            '</div>'+
            '<h1 id="firstHeading" class="firstHeading">2018 Zimbabwe</h1>'+
            '<div id="bodyContent">'+
            '<h4>had <b>750</b> of observers send in data with Apollo</h4>'+
            '</div>'+
            '</div>';

    var location = [
        ['Côte d’Ivoire', 7.5400, 5.5471, ivorycoastString],
        ['Libya', 26.3351, 17.2283,libyaString],
        ['Mali', 17.5707, 3.9962, maliString],
        ['Nigeria', 9.0820, 8.6753, nigeriaString],
        ['Serbia', 44.0165, 21.0059, serbiaString],
        ['Tunisia', 33.8869, 9.5375, tunisiaString],
        ['Zimbabwe', 19.0154, 29.1549, zimbabweString]
    ];

    var map = new google.maps.Map(document.getElementById('map'), {
        zoom: 3,
        center: myLatlng,
        scrollwheel: false,
        styles: [
            {
              "elementType": "geometry",
              "stylers": [
                {
                  "color": "#f5f5f5"
                }
              ]
            },
            {
              "elementType": "labels.icon",
              "stylers": [
                {
                  "visibility": "off"
                }
              ]
            },
            {
              "elementType": "labels.text.fill",
              "stylers": [
                {
                  "color": "#616161"
                }
              ]
            },
            {
              "elementType": "labels.text.stroke",
              "stylers": [
                {
                  "color": "#f5f5f5"
                }
              ]
            },
            {
              "featureType": "administrative.land_parcel",
              "stylers": [
                {
                  "visibility": "off"
                }
              ]
            },
            {
              "featureType": "administrative.land_parcel",
              "elementType": "labels.text.fill",
              "stylers": [
                {
                  "color": "#bdbdbd"
                }
              ]
            },
            {
              "featureType": "administrative.neighborhood",
              "stylers": [
                {
                  "visibility": "off"
                }
              ]
            },
            {
              "featureType": "administrative.province",
              "stylers": [
                {
                  "visibility": "off"
                }
              ]
            },
            {
              "featureType": "poi",
              "elementType": "geometry",
              "stylers": [
                {
                  "color": "#eeeeee"
                }
              ]
            },
            {
              "featureType": "poi",
              "elementType": "labels.text",
              "stylers": [
                {
                  "visibility": "off"
                }
              ]
            },
            {
              "featureType": "poi",
              "elementType": "labels.text.fill",
              "stylers": [
                {
                  "color": "#757575"
                }
              ]
            },
            {
              "featureType": "poi.business",
              "stylers": [
                {
                  "visibility": "off"
                }
              ]
            },
            {
              "featureType": "poi.park",
              "elementType": "geometry",
              "stylers": [
                {
                  "color": "#e5e5e5"
                }
              ]
            },
            {
              "featureType": "poi.park",
              "elementType": "labels.text.fill",
              "stylers": [
                {
                  "color": "#9e9e9e"
                }
              ]
            },
            {
              "featureType": "road",
              "stylers": [
                {
                  "visibility": "off"
                }
              ]
            },
            {
              "featureType": "road",
              "elementType": "geometry",
              "stylers": [
                {
                  "color": "#ffffff"
                }
              ]
            },
            {
              "featureType": "road",
              "elementType": "labels",
              "stylers": [
                {
                  "visibility": "off"
                }
              ]
            },
            {
              "featureType": "road",
              "elementType": "labels.icon",
              "stylers": [
                {
                  "visibility": "off"
                }
              ]
            },
            {
              "featureType": "road.arterial",
              "elementType": "labels.text.fill",
              "stylers": [
                {
                  "color": "#757575"
                }
              ]
            },
            {
              "featureType": "road.highway",
              "elementType": "geometry",
              "stylers": [
                {
                  "color": "#dadada"
                }
              ]
            },
            {
              "featureType": "road.highway",
              "elementType": "labels.text.fill",
              "stylers": [
                {
                  "color": "#616161"
                }
              ]
            },
            {
              "featureType": "road.local",
              "elementType": "labels.text.fill",
              "stylers": [
                {
                  "color": "#9e9e9e"
                }
              ]
            },
            {
              "featureType": "transit",
              "stylers": [
                {
                  "visibility": "off"
                }
              ]
            },
            {
              "featureType": "transit.line",
              "elementType": "geometry",
              "stylers": [
                {
                  "color": "#e5e5e5"
                }
              ]
            },
            {
              "featureType": "transit.station",
              "elementType": "geometry",
              "stylers": [
                {
                  "color": "#eeeeee"
                }
              ]
            },
            {
              "featureType": "water",
              "elementType": "geometry",
              "stylers": [
                {
                  "color": "#c9c9c9"
                }
              ]
            },
            {
              "featureType": "water",
              "elementType": "labels.text",
              "stylers": [
                {
                  "visibility": "off"
                }
              ]
            },
            {
              "featureType": "water",
              "elementType": "labels.text.fill",
              "stylers": [
                {
                  "color": "#9e9e9e"
                }
              ]
            }
          ]
    });

    for (var i = 0; i < location.length; i++) {

        var infowindow = new google.maps.InfoWindow({
            content: location[i][3]
          });

        var marker = new google.maps.Marker({
            position: new google.maps.LatLng(location[i][1], location[i][2]),
            map: map,
            title: location[i][0],
            icon: 'images/loc.png'
        });

        google.maps.event.addListener(marker, 'click', (function (marker, i) {
            return function () {
                infowindow.setContent(location[i][3]);
                infowindow.open(map, marker);
            }
        })(marker, i)); 
    }
}

initialize();