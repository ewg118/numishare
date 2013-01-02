function initialize_map(q,collection_type) {
	map = new OpenLayers.Map('resultMap', {
                    controls: [
                        new OpenLayers.Control.PanZoomBar(),
                        new OpenLayers.Control.Navigation(),
                        new OpenLayers.Control.ScaleLine(),
                    ]
	});
	
                var mintStyle = new OpenLayers.Style({
                    pointRadius: "${radius}",
                    //pointRadius: "5",
                    fillColor: "#ffcc66",
                    fillOpacity: 0.8,
                    strokeColor: "#cc6633",
                    strokeWidth: 2,
                    strokeOpacity: 0.8
                }, {
                    context: {
                        radius: function(feature) {
                            return Math.min(feature.attributes.count, 7) + 3;
                        }
                    }
                });
                 var hoardStyle = new OpenLayers.Style({
                    pointRadius: "${radius}",
                    //pointRadius: "5",
                    fillColor: "#00a000",
                    fillOpacity: 0.8,
                    strokeColor: "#006100",
                    strokeWidth: 2,
                    strokeOpacity: 0.8
                }, {
                    context: {
                        radius: function(feature) {
                            return Math.min(feature.attributes.count, 7) + 3;
                        }
                    }
                });
	map.addLayer(new OpenLayers.Layer.Google("Google Physical", {type: google.maps.MapTypeId.TERRAIN}));
	var mintLayer = new OpenLayers.Layer.Vector("KML", {
	 	styleMap: mintStyle,
	 	
	 	eventListeners: {'loadend': kmlLoaded },
		strategies: [
				new OpenLayers.Strategy.Fixed(),
				new OpenLayers.Strategy.Cluster()
			],
		protocol: new OpenLayers.Protocol.HTTP({
	                url: "mints.kml?q=" + q,
	                format: new OpenLayers.Format.KML({
	                    extractStyles: false, 
	                    extractAttributes: true
	                })
	            })
	});
	map.addLayer(mintLayer);
	
	//add findspot layer for hoards	
	var hoardLayer = new OpenLayers.Layer.Vector("KML", {
 	styleMap: hoardStyle, 	
 	eventListeners: {'loadend': kmlLoaded },
	strategies: [
			new OpenLayers.Strategy.Fixed(),
			new OpenLayers.Strategy.Cluster()
		],
	protocol: new OpenLayers.Protocol.HTTP({
                url: "findspots.kml?q=" + q,
                format: new OpenLayers.Format.KML({
                    extractStyles: false, 
                    extractAttributes: true
                })
            })
	});
	
	if (collection_type == 'hoard'){
		map.addLayer(hoardLayer);
	}

	function kmlLoaded(){
		if (collection_type == 'hoard'){
			map.zoomToExtent(hoardLayer.getDataExtent());
		} else {
			map.zoomToExtent(mintLayer.getDataExtent());
		}
		
		if (q == '*:*'){
			map.zoomTo('2');
		} else {
			map.zoomTo('5');
		}
		
	}
	
	selectControl = new OpenLayers.Control.SelectFeature(
                [mintLayer,hoardLayer],
                {
                    clickout: true, 
                    //toggle: true,
                    multiple: false, 
                    hover: false,
                    //toggleKey: "ctrlKey",
                    //multipleKey: "shiftKey"
                }
            );
	
	map.addControl(selectControl);
	selectControl.activate();
	mintLayer.events.on({"featureselected": onFeatureSelect, "featureunselected": onFeatureUnselect});
	if (collection_type == 'hoard'){
		hoardLayer.events.on({"featureselected": onFeatureSelect, "featureunselected": onFeatureUnselect});
	}
     
	function onPopupClose(evt) {		
		map.removePopup(map.popups[0]);
	}
	
	function onFeatureSelect(event) {
		var message = '';
		var places = new Array();
		if (event.feature.cluster.length > 12){
			message = '<div style="font-size:10px">'+ event.feature.cluster.length + ' places found at this location';	
			for (var i in event.feature.cluster) {
				places.push(event.feature.cluster[i].attributes['name']);
			}
		}
		else if (event.feature.cluster.length > 1 && event.feature.cluster.length <= 12){
			message = '<div style="font-size:10px;width:300px;">'+ event.feature.cluster.length + ' places found at this location: ';
			for (var i in event.feature.cluster) {
				places.push(event.feature.cluster[i].attributes['name']);
				message += event.feature.cluster[i].attributes['name'];
				if (i < event.feature.cluster.length - 1){
					message += ', ';
				}		
			}			
		} else if (event.feature.cluster.length == 1) {
			places.push(event.feature.cluster[0].attributes['name']);
			message =  '<div style="font-size:10px">' + event.feature.cluster[0].attributes['name'];
		}		
				
		message += '</div>';
		
		popup = new OpenLayers.Popup.FramedCloud("id", event.feature.geometry.bounds.getCenterLonLat(), null, message, null, true, onPopupClose);
		event.popup = popup;
		map.addPopup(popup);
	}
	
	function onFeatureUnselect(event) {
		map.removePopup(map.popups[0]);
	}     

}
