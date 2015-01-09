<?php 

//Berlin's list of LIDO XML files
$data = generate_json('berlin-concordances.csv', false);

//start RDF/XML file
$open = '<rdf:RDF xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:nm="http://nomisma.org/id/" xmlns:nmo="http://nomisma.org/ontology#"
xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">';

file_put_contents('berlin-rrc.rdf', $open);
$count = 1;
foreach ($data as $row){
	$rdf = process_row($row, $count);
	file_put_contents('berlin-rrc.rdf', $rdf, FILE_APPEND);
	$count++;
}

file_put_contents('berlin-rrc.rdf', '</rdf:RDF>', FILE_APPEND);

function process_row($row, $count){
	//only process rows with OCRE URIs
	$rdf = '';
	if (strlen($row['URI']) > 0){		
		$id = $row['object_number'];
		$file = 'http://ww2.smb.museum/mk_edit/coin_export/4/' . $id . '.xml';
		
		echo "Processing #{$count}: {$id}\n";
		
		$dom = new DOMDocument('1.0', 'UTF-8');
		if ($dom->load($file) === FALSE){
			echo "{$file} failed to load.\n";
		} else {
			$xpath = new DOMXpath($dom);
			$xpath->registerNamespace("lido", "http://www.lido-schema.org");
			$title = $xpath->query("descendant::lido:titleSet/lido:appellationValue")->item(0)->nodeValue;
			if (strlen($xpath->query("descendant::lido:displayDate")->item(0)->nodeValue) > 0){
				$title .= ', ' . $xpath->query("descendant::lido:displayDate")->item(0)->nodeValue;
			}		
			$measurements = $xpath->query("descendant::lido:measurementsSet");
			
			
			$rdf = '<nm:coin rdf:about="http://ww2.smb.museum/ikmk/object.php?id=' . $id . '">';
			$rdf .= '<dcterms:title xml:lang="de">' . $title . '</dcterms:title>';
			$rdf .= '<dcterms:identifier>' . $id . '</dcterms:identifier>';
			$rdf .= '<dcterms:publisher rdf:resource="http://nomisma.org/id/mk_berlin"/>';
			$rdf .= '<nm:collection rdf:resource="http://nomisma.org/id/mk_berlin"/>';
			$rdf .= '<nm:type_series_item rdf:resource="' . $row['URI'] . '"/>';
			
			//measurements			
			foreach($measurements as $measurement){
				$type = $measurement->getElementsByTagNameNS('http://www.lido-schema.org', 'measurementType')->item(0)->nodeValue;
				$value = $measurement->getElementsByTagNameNS('http://www.lido-schema.org', 'measurementValue')->item(0)->nodeValue;
				
				switch ($type){
					case 'diameter':
					case 'weight':
						$rdf .= '<nm:' . $type . ' rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">' . $value . '</nm:' . $type . '>';
						break;
					case 'orientation':
						$rdf .= '<nm:axis rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">' . $value . '</nm:axis>';
						break;
				}
				
			}
			
			//images
			$image_url = $xpath->query("descendant::lido:resourceRepresentation/lido:linkResource")->item(0)->nodeValue;
			if (strlen($image_url) > 0){
				$pieces = explode('/', $image_url);
				$image_id = $pieces[5];
				
				//obverse
				$rdf .= '<nm:obverse><rdf:Description>';
				$rdf .= '<foaf:thumbnail rdf:resource="http://ww2.smb.museum/mk_edit/images/' . $image_id . '/vs_thumb.jpg"/>';
				$rdf .= '<foaf:depiction rdf:resource="http://ww2.smb.museum/mk_edit/images/' . $image_id . '/vs_opt.jpg"/>';
				$rdf .='</rdf:Description></nm:obverse>';
				
				//reverse
				$rdf .= '<nm:reverse><rdf:Description>';
				$rdf .= '<foaf:thumbnail rdf:resource="http://ww2.smb.museum/mk_edit/images/' . $image_id . '/rs_thumb.jpg"/>';
				$rdf .= '<foaf:depiction rdf:resource="http://ww2.smb.museum/mk_edit/images/' . $image_id . '/rs_opt.jpg"/>';
				$rdf .='</rdf:Description></nm:reverse>';
			}
			
			//findspots
			$geonameId = '';
			$findspotUri = '';
			if ($id == '18202297'){
				$rdf .= '<nm:findspot rdf:resource="http://numismatics.org/chrr/id/CTO"/>';
			} elseif ($id == '18214947'){
				$rdf .= '<nm:findspot rdf:resource="http://numismatics.org/chrr/id/CAI"/>';
			} else {
				$places = $xpath->query("descendant::lido:place");
				foreach ($places as $place){
					$attr = $place->getAttribute('lido:politicalEntity');
					
					if ($attr == 'finding_place'){						
						$findspotUri = $place->getElementsByTagNameNS('http://www.lido-schema.org', 'placeID')->item(0)->nodeValue;
						
						echo "Found {$findspotUri}\n";
						
						if (strstr($findspotUri, 'nomisma') !== FALSE){
							$rdf .= '<nm:findspot rdf:resource="' . $findspotUri . '"/>';
						} elseif (strstr($findspotUri, 'geonames') != FALSE){
							$ffrags = explode('/', $findspotUri);
							$geonameId = $ffrags[3];
							
							//if the id is valid
							if ($geonameId != '0'){
								$rdf .= '<nm:findspot rdf:resource="' . $findspotUri . '"/>';
							}
							
						}
					}					
				}				
			}
			
			$rdf .= '</nm:coin>';
			
			//get coordinates
			if (strlen($geonameId) > 0 && $geonameId != '0'){
				$service = 'http://api.geonames.org/get?geonameId=' . $geonameId . '&username=anscoins&style=full';
				$coords = query_geonames($service);
				
				$rdf .= '<geo:SpatialThing rdf:about="' . $findspotUri . '">';
				$rdf .= '<geo:lat rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">' . $coords['lat'] . '</geo:lat>';
				$rdf .= '<geo:long rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">' . $coords['long'] . '</geo:long>';
				$rdf .= '</geo:SpatialThing>
			}
			
			
		}			
	}
	return $rdf;
}

function query_geonames($service){
	$dom = new DOMDocument('1.0', 'UTF-8');
	if ($dom->load($service) === FALSE){
		echo "{$service} failed to load.\n";
	} else {
		$xpath = new DOMXpath($dom);
		
		$coords = array();
		
		$coords['lat'] = $xpath->query('descendant::lat')->item(0)->nodeValue;
		$coords['long'] = $xpath->query('descendant::lng')->item(0)->nodeValue;
		
		return $coords;
	}
}

function generate_json($doc){
	$keys = array();
	$geoData = array();

	$data = csvToArray($doc, ',');

	// Set number of elements (minus 1 because we shift off the first row)
	$count = count($data) - 1;

	//Use first row for names
	$labels = array_shift($data);

	foreach ($labels as $label) {
		$keys[] = $label;
	}

	// Bring it all together
	for ($j = 0; $j < $count; $j++) {
		$d = array_combine($keys, $data[$j]);
		$geoData[$j] = $d;
	}
	return $geoData;
}

// Function to convert CSV into associative array
function csvToArray($file, $delimiter) {
	if (($handle = fopen($file, 'r')) !== FALSE) {
		$i = 0;
		while (($lineArray = fgetcsv($handle, 4000, $delimiter, '"')) !== FALSE) {
			for ($j = 0; $j < count($lineArray); $j++) {
				$arr[$i][$j] = $lineArray[$j];
			}
			$i++;
		}
		fclose($handle);
	}
	return $arr;
}

?>