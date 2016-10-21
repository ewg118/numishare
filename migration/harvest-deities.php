<?php 

ini_set("user_agent","EthanGruber");

$data = generate_json('bm-deities.csv');

$writer = new XMLWriter();
$writer->openURI("deities.rdf");
//$writer->openURI('php://output');
$writer->startDocument('1.0','UTF-8');
$writer->setIndent(true);
//now we need to define our Indent string,which is basically how many blank spaces we want to have for the indent
$writer->setIndentString("    ");

$writer->startElement('rdf:RDF');
$writer->writeAttribute('xmlns:xsd', 'http://www.w3.org/2001/XMLSchema#');
$writer->writeAttribute('xmlns:bmo', "http://collection.britishmuseum.org/id/ontology/");
$writer->writeAttribute('xmlns:nm', "http://nomisma.org/id/");
$writer->writeAttribute('xmlns:nmo', "http://nomisma.org/ontology#");
$writer->writeAttribute('xmlns:dcterms', "http://purl.org/dc/terms/");
$writer->writeAttribute('xmlns:foaf', "http://xmlns.com/foaf/0.1/");
$writer->writeAttribute('xmlns:geo', "http://www.w3.org/2003/01/geo/wgs84_pos#");
$writer->writeAttribute('xmlns:rdf', "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
$writer->writeAttribute('xmlns:skos', "http://www.w3.org/2004/02/skos/core#");
$writer->writeAttribute('xmlns:void', "http://rdfs.org/ns/void#");
$writer->writeAttribute('xmlns:wordnet', "http://ontologi.es/WordNet/class/");

foreach ($data as $row){
	$deity = $row['deity'];
	echo "Processing {$deity}\n";
	$url = "http://collection.britishmuseum.org/resource?uri=" . urlencode($deity) . "&format=rdf";
	$ch = curl_init();
	
	// set url
	curl_setopt($ch, CURLOPT_URL, $url);
	
	//return the transfer as a string
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	
	// $output contains the output string
	$file = curl_exec($ch);
	
	$dom = new DOMDocument('1.0', 'UTF-8');
	if ($dom->loadXML($file) === FALSE){
		echo "{$url} failed to load.\n";
	} else {		
		$xpath = new DOMXpath($dom);
		$xpath->registerNamespace("skos", "http://www.w3.org/2004/02/skos/core#");
		$xpath->registerNamespace("crm", "http://erlangen-crm.org/current/");		
		$xpath->registerNamespace("bmo", "http://collection.britishmuseum.org/id/ontology/");
		
		$prefLabel = $xpath->query("descendant::skos:prefLabel")->item(0)->nodeValue;
		$definition = preg_replace('/\s+/', ' ', trim($xpath->query("descendant::crm:P3_has_note")->item(0)->nodeValue));
		
		$writer->startElement('wordnet:Deity');
			$writer->writeAttribute('rdf:about', $deity);
			$writer->startElement('rdf:type');
				$writer->writeAttribute('rdf:resource', 'http://www.w3.org/2004/02/skos/core#Concept');
			$writer->endElement();
			$writer->startElement('skos:prefLabel');
				$writer->writeAttribute('xml:lang', 'en');
				$writer->text(trim($prefLabel));
			$writer->endElement();
			$writer->startElement('skos:definition');
				$writer->writeAttribute('xml:lang', 'en');
				$writer->text($definition);
			$writer->endElement();			
			//nationality
			foreach ($xpath->query("descendant::bmo:PX_nationality") as $culture){
				$writer->startElement('bmo:PX_nationality');
					$writer->writeAttribute('rdf:resource', $culture->getAttribute('rdf:resource'));
				$writer->endElement();
			}			
			$writer->startElement('void:inDataset');
				$writer->writeAttribute('rdf:resource', 'http://collection.britishmuseum.org/id/person-institution');
			$writer->endElement();
		$writer->endElement();
		
	}
	
	// close curl resource to free up system resources
	curl_close($ch);
}

$writer->endElement();
$writer->flush();

//functions
function generate_json($doc){
	$keys = array();
	$array = array();

	$csv = csvToArray($doc, ',');

	// Set number of elements (minus 1 because we shift off the first row)
	$count = count($csv) - 1;

	//Use first row for names
	$labels = array_shift($csv);

	foreach ($labels as $label) {
		$keys[] = $label;
	}

	// Bring it all together
	for ($j = 0; $j < $count; $j++) {
		$d = array_combine($keys, $csv[$j]);
		$array[$j] = $d;
	}
	return $array;
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

function url_exists($url) {
	if (!$fp = curl_init($url)) return false;
	return true;
}

?>