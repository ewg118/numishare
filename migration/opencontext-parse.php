<?php 

$page = 1;
$records = array();
$findspots = array();

$query = 'http://opencontext.org/subjects-search/.json?prop=oc-gen-cat-object---oc-gen-cat-coin&prop=1-comparanda---RIC';

parse_page($page, $query);

//after the process is complete, write CSV file
$file = fopen('coins.csv', 'w');
//insert heading
$headings = array('uri','title','findspot','dataset','diameter','weight','thickness','ref','ocre_uri','obv_thumb','rev_thumb');
array_unshift($records, $headings);
foreach ($records as $record) {
	fputcsv($file, $record);
}
fclose($file);

//construct RDF
construct_rdf($records, $findspots);

function parse_page($page, $query){
	GLOBAL $findspots;
	
	echo "Page {$page}\n";
	
	$json = file_get_contents($query);
	$data = json_decode($json);
	
	foreach ($data->features as $record){
		if ($record->category == 'oc-api:geo-record'){
			$uri = $record->properties->uri;
			$findspot = $record->properties->{'project href'};
			echo "Processing {$uri}: ";
			
			if (!array_key_exists($findspot, $findspots)){
				parse_project($findspot);
			}
			
			parse_record($uri, $findspot);
		}
	}
	
	//recurse through pages
	if (isset($data->{'next-json'})){
		$query = $data->{'next-json'};
		$page++;
		parse_page($page, $query);
	}
}

function parse_project($uri){
	GLOBAL $findspots;
	
	$data = json_decode(file_get_contents($uri . '.json'));
	$coords = $data->features[0]->geometry->coordinates;		
	
	$findspot = array('name'=>$data->label, 'lat'=>$coords[1], 'long'=>$coords[0]);
	$findspots[$uri] = $findspot;	
}

function parse_record($uri, $findspot){
	GLOBAL $records;	
	$record = array();
	
	//load record data
	$data = json_decode(file_get_contents($uri . '.json'));	
	
	$record['uri'] = $uri;
	$record['title'] = $data->label;
	$record['findspot'] = $findspot;
	$record['dataset'] = 'http://opencontext.org/';
	$record['diameter'] = '';
	$record['weight'] = '';
	$record['thickness'] = '';
	$record['ref'];
	$record['ocre_uri'];
	$record['obv_thumb'] = '';
	$record['rev_thumb'] = '';
	
	echo "{$data->label}\n";
	
	$metadata = $data->{'oc-gen:has-obs'};
	
	foreach ($data->{'oc-gen:has-obs'} as $prop){
		if (isset($prop->{'oc-pred:1-diameter-1'})){
			$record['diameter'] = $prop->{'oc-pred:1-diameter-1'}[0];
		}
		if (isset($prop->{'oc-pred:1-weight-2'})){
			$record['weight'] = $prop->{'oc-pred:1-weight-2'}[0];
		}
		if (isset($prop->{'oc-pred:1-thickness'})){
			$record['thickness'] = $prop->{'oc-pred:1-thickness'}[0];
		}
		if (isset($prop->{'oc-pred:1-comparanda'})){
			$ref = $prop->{'oc-pred:1-comparanda'}[0]->{'xsd:string'};
			$record['ref'] = $ref;
			$record['ocre_uri'] = parse_ref($ref);
		}
		
		//attempt to parse the first images that contain obv and rev
		if (isset($prop->{'oc-pred:link'})){
			//get first obv and break
			foreach ($prop->{'oc-pred:link'} as $img){
				if ($img->type == 'oc-gen:image'){
					if (strpos($img->slug, 'obv')){
						$record['obv_thumb'] = $img->{'oc-gen:thumbnail-uri'};
						break;
					}
				}
			}
			
			//get first rev and break
			foreach ($prop->{'oc-pred:link'} as $img){
				if ($img->type == 'oc-gen:image'){
					if (strpos($img->slug, 'rev')){
						$record['rev_thumb'] = $img->{'oc-gen:thumbnail-uri'};
						break;
					}
				}
			}
		}	
	}
	
	$records[] = $record;
	//var_dump($record);
}

function parse_ref($ref){
	$uri = '';
	
	if (strpos($ref, ';') === FALSE && strpos($ref, ',') === FALSE){
		echo "{$ref}: ";
	
		$pieces = explode(' ', $ref);
	
		if (count($pieces) == 4){
			switch ($pieces[1]){
				case 'VII':
					$vol = '7';
					break;
				case 'VIII':
					$vol = '8';
					break;
				default:
					$vol = null;
			}
				
			switch($pieces[2]){
				case 'Alexandria':
					$mint = 'alex';
					break;
				case 'Antioch':
				case 'Antoch':
					$mint = 'anch';
					break;
				case 'Aquilea':
					$mint = 'aq';
					break;
				case 'Arles':
					$mint = 'ar';
					break;
				case 'Constantinople':
					$mint = 'cnp';
					break;
				case 'Cyzicus':
					$mint = 'cyz';
					break;
				case 'Heraclea':
					$mint = 'her';
					break;
				case 'Lyons':
					$mint = 'lug';
					break;
				case 'Nicomedia':
					$mint = 'nic';
					break;
				case 'Ostia':
					$mint = 'ost';
					break;
				case 'Rome':
					$mint = 'rom';
					break;
				case 'Siscia':
					$mint = 'sis';
					break;
				case 'Thessalonica':
					$mint = 'thes';
					break;
				default:
					$mint = null;
			}
				
			//if the volume and mint are matched
			if ($vol != null && $mint != null){
				$id = array('ric', $vol, $mint, $pieces[3]);
				$test = 'http://numismatics.org/ocre/id/' . implode('.', $id);
	
				$file_headers = @get_headers($test . '.xml');
				if ($file_headers[0] == 'HTTP/1.1 200 OK'){
					$uri = $test;
					echo "{$uri}\n";
				}
			}
		} else {
			echo "Invalid\n";
		}
	}
	
	return $uri;
}

function construct_rdf($records, $findspots){
	$heading = array_shift($records);
	
	//start RDF/XML file
	//use XML writer to generate RDF
	$writer = new XMLWriter();
	$writer->openURI("opencontext.rdf");
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
	
	//process findspots
	foreach ($findspots as $findspot){
		$writer->startElement('geo:SpatialThing');
			$writer->writeElement('foaf:name', $findspot['name']);
			$writer->startElement('geo:lat');
				$writer->writeAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#decimal');
				$writer->text($findspot['lat']);
			$writer->endElement();
			$writer->startElement('geo:long');
				$writer->writeAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#decimal');
				$writer->text($findspot['long']);
			$writer->endElement();
		$writer->endElement();
	}
	
	//processs records that have OCRE URIs
	foreach ($records as $record){
		if (strlen($record['ocre_uri']) > 0){
			$writer->startElement('nmo:NumismaticObject');
				$writer->writeAttribute('rdf:about', $record['uri']);
				$writer->startElement('dcterms:title');
					$writer->writeAttribute('xml:lang', 'en');
					$writer->text($record['title']);
				$writer->endElement();
				$writer->writeElement('dcterms:identifier', $record['title']);
				$writer->startElement('nmo:hasTypeSeriesItem');
					$writer->writeAttribute('rdf:resource', $record['ocre_uri']);
				$writer->endElement();
				$writer->startElement('nmo:hasFindspot');
					$writer->writeAttribute('rdf:resource', $record['findspot']);
				$writer->endElement();
				
				//measurements
				if (is_numeric($record['diameter'])){
					$writer->startElement('nmo:hasDiameter');
						$writer->writeAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#decimal');
						$writer->text($record['diameter']);
					$writer->endElement();
				}
				if (is_numeric($record['weight'])){
					$writer->startElement('nmo:hasWeight');
						$writer->writeAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#decimal');
						$writer->text($record['weight']);
					$writer->endElement();
				}
				if (is_numeric($record['thickness'])){
					$writer->startElement('nmo:hasDepth');
						$writer->writeAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#decimal');
						$writer->text($record['thickness']);
					$writer->endElement();
				}
				
				//images
				if (strlen($record['obv_thumb']) > 0){
					$writer->startElement('nmo:hasObverse');
						$writer->startElement('rdf:Description');
							$writer->startElement('foaf:thumbnail');
								$writer->writeAttribute('rdf:resource', $record['obv_thumb']);
							$writer->endElement();
						$writer->endElement();
					$writer->endElement();
				}
				if (strlen($record['rev_thumb']) > 0){
					$writer->startElement('nmo:hasReverse');
						$writer->startElement('rdf:Description');
							$writer->startElement('foaf:thumbnail');
								$writer->writeAttribute('rdf:resource', $record['rev_thumb']);
							$writer->endElement();
						$writer->endElement();
					$writer->endElement();
				}
				
				//void
				$writer->startElement('void:inDataset');
					$writer->writeAttribute('rdf:resource', $record['dataset']);
				$writer->endElement();
			$writer->endElement();
		}
	}
	
	//end document
	$writer->endElement();
	$writer->flush();
}

?>