<?php 

//Berlin's list of LIDO XML files
$data = generate_json('berlin-concordances.csv', false);

//start RDF/XML file
$open = '<rdf:RDF xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:nm="http://nomisma.org/id/" xmlns:nmo="http://nomisma.org/ontology#"
xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:void="http://rdfs.org/ns/void#"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">';

file_put_contents('berlin-ric.rdf', $open);
$count = 1;
foreach ($data as $row){
	$rdf = process_row($row, $count);
	file_put_contents('berlin-ric.rdf', $rdf, FILE_APPEND);
	$count++;
}

file_put_contents('berlin-ric.rdf', '</rdf:RDF>', FILE_APPEND);

function process_row($row, $count){
	//only process rows with OCRE URIs
	$rdf = '';
	if (strlen($row['URI']) > 0){		
		$id = $row['object_number'];
		$file = 'http://ww2.smb.museum/mk_edit/coin_export/2/' . $id . '.xml';
		
		echo "Processing #{$count}: {$id}\n";
		
		$dom = new DOMDocument('1.0', 'UTF-8');
		if ($dom->load($file) === FALSE){
			echo "{$file} failed to load.\n";
		} else {
			$xpath = new DOMXpath($dom);
			$xpath->registerNamespace("lido", "http://www.lido-schema.org");
			$title = $xpath->query("descendant::lido:titleSet/lido:appellationValue")->item(0)->nodeValue . ', ' . $xpath->query("descendant::lido:eventDate/lido:displayDate")->item(0)->nodeValue;
			$measurements = $xpath->query("descendant::lido:measurementsSet");
			
			
			$rdf = '<nmo:NumismaticObject rdf:about="http://ww2.smb.museum/ikmk/object.php?id=' . $id . '">';
			$rdf .= '<dcterms:title xml:lang="de">' . $title . '</dcterms:title>';
			$rdf .= '<dcterms:identifier>' . $id . '</dcterms:identifier>';
			$rdf .= '<dcterms:publisher rdf:resource="http://nomisma.org/id/mk_berlin"/>';
			$rdf .= '<nmo:hasCollection rdf:resource="http://nomisma.org/id/mk_berlin"/>';
			$rdf .= '<nmo:hasTypeSeriesItem rdf:resource="' . $row['URI'] . '"/>';
			
			//measurements			
			foreach($measurements as $measurement){
				$type = $measurement->getElementsByTagNameNS('http://www.lido-schema.org', 'measurementType')->item(0)->nodeValue;
				$value = $measurement->getElementsByTagNameNS('http://www.lido-schema.org', 'measurementValue')->item(0)->nodeValue;
				
				switch ($type){
					case 'diameter':
						$rdf .= '<nmo:hasDiameter rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">' . $value . '</nmo:hasDiameter>';
						break;
					case 'weight':
						$rdf .= '<nmo:hasWeight rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">' . $value . '</nmo:hasWeight>';
						break;
					case 'orientation':
						$rdf .= '<nmo:hasAxis rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">' . $value . '</nmo:hasAxis>';
						break;
				}
				
			}
			
			//images
			$image_url = $xpath->query("descendant::lido:resourceRepresentation/lido:linkResource")->item(0)->nodeValue;
			if (strlen($image_url) > 0){
				$pieces = explode('/', $image_url);
				$image_id = $pieces[5];
				
				//obverse
				$rdf .= '<nmo:hasObverse><rdf:Description>';
				$rdf .= '<foaf:thumbnail rdf:resource="http://ww2.smb.museum/mk_edit/images/' . $image_id . '/vs_thumb.jpg"/>';
				$rdf .= '<foaf:depiction rdf:resource="http://ww2.smb.museum/mk_edit/images/' . $image_id . '/vs_opt.jpg"/>';
				$rdf .='</rdf:Description></nmo:hasObverse>';
				
				//reverse
				$rdf .= '<nmo:hasReverse><rdf:Description>';
				$rdf .= '<foaf:thumbnail rdf:resource="http://ww2.smb.museum/mk_edit/images/' . $image_id . '/rs_thumb.jpg"/>';
				$rdf .= '<foaf:depiction rdf:resource="http://ww2.smb.museum/mk_edit/images/' . $image_id . '/rs_opt.jpg"/>';
				$rdf .='</rdf:Description></nmo:hasReverse>';
			}
			$rdf .= '<void:inDataset rdf:resource="http://ww2.smb.museum/ikmk/"/>';
			$rdf .= '</nmo:NumismaticObject>';
		}			
	}
	return $rdf;
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