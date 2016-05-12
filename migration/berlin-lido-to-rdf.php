<?php 

/*Berlin OCRE export: http://ww2.smb.museum/mk_edit/coin_export/21/content.txt
 *Priene export: http://ww2.smb.museum/mk_edit/coin_export/30/content.txt
*/

//Berlin's list of LIDO XML files
$project = 'berlin';
$data = generate_json($project . '-concordances.csv', false);
$prefix = 'http://ww2.smb.museum/mk_edit/coin_export/21/';
//start RDF/XML file
//use XML writer to generate RDF
$writer = new XMLWriter();
$writer->openURI($project . ".rdf");
//$writer->openURI('php://output');
$writer->startDocument('1.0','UTF-8');
$writer->setIndent(true);
//now we need to define our Indent string,which is basically how many blank spaces we want to have for the indent
$writer->setIndentString("    ");

$writer->startElement('rdf:RDF');
$writer->writeAttribute('xmlns:xsd', 'http://www.w3.org/2001/XMLSchema#');
$writer->writeAttribute('xmlns:nm', "http://nomisma.org/id/");
$writer->writeAttribute('xmlns:nmo', "http://nomisma.org/ontology#");
$writer->writeAttribute('xmlns:dcterms', "http://purl.org/dc/terms/");
$writer->writeAttribute('xmlns:foaf', "http://xmlns.com/foaf/0.1/");
$writer->writeAttribute('xmlns:geo', "http://www.w3.org/2003/01/geo/wgs84_pos#");
$writer->writeAttribute('xmlns:rdf', "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
$writer->writeAttribute('xmlns:void', "http://rdfs.org/ns/void#");

$count = 1;
foreach ($data as $row){
	if (strlen($row['URI']) > 0){
		echo "Processing #{$count}: {$row['object_number']}\n";
		process_row($row, $prefix, $project, $writer);
		$count++;
	}
}

$writer->endElement();
$writer->flush();

function process_row($row, $prefix, $project, $writer){
	$id = $row['object_number'];
	$file = $prefix . $id . '.xml';
		
	$dom = new DOMDocument('1.0', 'UTF-8');
	if ($dom->load($file) === FALSE){
		echo "{$file} failed to load.\n";
	} else {
		$xpath = new DOMXpath($dom);
		$xpath->registerNamespace("lido", "http://www.lido-schema.org");
		$title = $xpath->query("descendant::lido:titleSet/lido:appellationValue")->item(0)->nodeValue . ', ' . $xpath->query("descendant::lido:eventDate/lido:displayDate")->item(0)->nodeValue;
		$measurements = $xpath->query("descendant::lido:measurementsSet");
		
		$writer->startElement('nmo:NumismaticObject');
			$writer->writeAttribute('rdf:about', "http://ww2.smb.museum/ikmk/object.php?id={$id}");
			$writer->startElement('dcterms:title');
				$writer->writeAttribute('xml:lang', 'de');
				$writer->text($title);
			$writer->endElement();
			$writer->writeElement('dcterms:identifier', $id);
			if ($project == 'berlin'){
				$writer->startElement('nmo:hasCollection');
					$writer->writeAttribute('rdf:resource', 'http://nomisma.org/id/mk_berlin');
				$writer->endElement();
			}			
			$writer->startElement('nmo:hasTypeSeriesItem');
				$writer->writeAttribute('rdf:resource', $row['URI']);
			$writer->endElement();
			
			//measurements
			foreach($measurements as $measurement){
				$type = $measurement->getElementsByTagNameNS('http://www.lido-schema.org', 'measurementType')->item(0)->nodeValue;
				$value = $measurement->getElementsByTagNameNS('http://www.lido-schema.org', 'measurementValue')->item(0)->nodeValue;
			
				switch ($type){
					case 'diameter':
						$writer->startElement('nmo:hasDiameter');
							$writer->writeAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#decimal');
							$writer->text($value);
						$writer->endElement();
						break;
					case 'weight':
						$writer->startElement('nmo:hasWeight');
							$writer->writeAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#decimal');
							$writer->text($value);
						$writer->endElement();
						break;
					case 'orientation':
						$writer->startElement('nmo:hasAxis');
							$writer->writeAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#integer');
							$writer->text($value);
						$writer->endElement();
						break;
				}
			}

			//images
			$image_url = $xpath->query("descendant::lido:resourceRepresentation/lido:linkResource")->item(0)->nodeValue;
			if (strlen($image_url) > 0){
				$pieces = explode('/', $image_url);
				$image_id = $pieces[5];
				
				//obverse
				$writer->startElement('nmo:hasObverse');
					$writer->startElement('rdf:Description');
						$writer->startElement('foaf:thumbnail');
							$writer->writeAttribute('rdf:resource', "http://ww2.smb.museum/mk_edit/images/{$image_id}/vs_thumb.jpg");
						$writer->endElement();
						$writer->startElement('foaf:depiction');
							$writer->writeAttribute('rdf:resource', "http://ww2.smb.museum/mk_edit/images/{$image_id}/vs_opt.jpg");
						$writer->endElement();
					$writer->endElement();
				$writer->endElement();
				
				//reverse
				$writer->startElement('nmo:hasReverse');
					$writer->startElement('rdf:Description');
						$writer->startElement('foaf:thumbnail');
							$writer->writeAttribute('rdf:resource', "http://ww2.smb.museum/mk_edit/images/{$image_id}/rs_thumb.jpg");
						$writer->endElement();
						$writer->startElement('foaf:depiction');
							$writer->writeAttribute('rdf:resource', "http://ww2.smb.museum/mk_edit/images/{$image_id}/rs_opt.jpg");
						$writer->endElement();
					$writer->endElement();
				$writer->endElement();
			}
			
			//findspots
			$places = $xpath->query("descendant::lido:place[@lido:politicalEntity='finding_place']");
			
			$geonameId = '';
			$findspotUri = '';
			if ($places->length > 0){
				foreach ($places as $place){
					$findspots = $place->getElementsByTagNameNS('http://www.lido-schema.org', 'placeID');
						
					foreach ($findspots as $findspot){
						$findspotUri = $findspot->nodeValue;
						if (strstr($findspotUri, 'geonames') != FALSE) {
							$ffrags = explode('/', $findspotUri);
							$geonameId = $ffrags[3];
								
							//if the id is valid
							if ($geonameId != '0'){
								echo "Found {$findspotUri}\n";
								$writer->startElement('nmo:hasFindspot');
									$writer->writeAttribute('rdf:resource', $findspotUri);
								$writer->endElement();
								break;
							}
						} elseif (strstr($findspotUri, 'nomisma') !== FALSE){
							echo "Found {$findspotUri}\n";
							$writer->startElement('nmo:hasFindspot');
								$writer->writeAttribute('rdf:resource', $findspotUri . '#this');
							$writer->endElement();
						}
					}
				}	
			}
			
			//void:inDataset
			$writer->startElement('void:inDataset');
				if ($project == 'berlin'){
					$writer->writeAttribute('rdf:resource', 'http://ww2.smb.museum/ikmk/');
				} else if ($project == 'priene'){
					$writer->writeAttribute('rdf:resource', 'http://ww2.smb.museum/mk_priene/');
				}				
			$writer->endElement();
			
		//end nmo:NumismaticObject
		$writer->endElement();
		
		//if there is a geonameID, create findspot SpatialThing
		if (strlen($geonameId) > 0 && $geonameId != '0'){
			$service = 'http://api.geonames.org/get?geonameId=' . $geonameId . '&username=anscoins&style=full';
			$coords = query_geonames($service);
		
			$writer->startElement('geo:SpatialThing');
				$writer->writeAttribute('rdf:about', $findspotUri);
				$writer->writeElement('foaf:name', $coords['name']);
				$writer->startElement('geo:lat');
					$writer->writeAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#decimal');
					$writer->text($coords['lat']);
				$writer->endElement();
				$writer->startElement('geo:long');
					$writer->writeAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#decimal');
					$writer->text($coords['long']);
				$writer->endElement();
			$writer->endElement();
		}
	}	
}

function query_geonames($service){
	$dom = new DOMDocument('1.0', 'UTF-8');
	if ($dom->load($service) === FALSE){
		echo "{$service} failed to load.\n";
	} else {
		$xpath = new DOMXpath($dom);

		$coords = array();
		$name = $xpath->query('descendant::name')->item(0)->nodeValue . ' (' . $xpath->query('descendant::countryName')->item(0)->nodeValue . ')';
		$coords['name'] = $name;
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