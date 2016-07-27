<?php

require_once( "sparqllib.php" );
error_reporting(0);

$data = generate_json('/home/komet/ans_migration/ocre/bm-data/ric6-10-con.csv', false);

//use XML writer to generate RDF
$writer = new XMLWriter();
$writer->openURI("bm6-10.rdf");
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
$writer->writeAttribute('xmlns:rdf', "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
$writer->writeAttribute('xmlns:void', "http://rdfs.org/ns/void#");

$count = 1;
foreach ($data as $row){	
	
	//reprocess entire spreadsheet
	process_csv($writer, $row, $count);
	$count++;
}

$writer->endElement();
$writer->flush();

function process_csv($writer, $row, $count){	
	
	
	//get coin type URI
	$coinType = $row['type'];
	
	if (strlen($coinType) > 0){
		//exclude variants, cf. or uncertainty
		$ref = $row['ref'];
		if (strpos($ref, 'var') === FALSE && strpos($ref, 'cf') === FALSE && strpos($ref, ' or ') === FALSE){
			echo "Processing {$count}: {$row['uri']}\n";
			
			$writer->startElement('nmo:NumismaticObject');
				$writer->writeAttribute('rdf:about', $row['uri']);
				$writer->startElement('dcterms:title');
					$writer->writeAttribute('xml:lang', 'en');
					$writer->text("British Museum: " . $row['regno']);
				$writer->endElement();
				$writer->writeElement('dcterms:identifier', $row['regno']);
				$writer->startElement('nmo:hasCollection');
					$writer->writeAttribute('rdf:resource', 'http://nomisma.org/id/bm');
				$writer->endElement();
					$writer->startElement('nmo:hasTypeSeriesItem');
				$writer->writeAttribute('rdf:resource', $coinType);
				$writer->endElement();
			
				query_bm($writer, $row['uri']);
				
				//void:inDataset
				$writer->startElement('void:inDataset');
					$writer->writeAttribute('rdf:resource', 'http://www.britishmuseum.org/');
				$writer->endElement();
				
			//end nmo:NumismaticObject
			$writer->endElement();
		}
	}
}

function query_bm($writer, $uri){
	$db = sparql_connect( "http://collection.britishmuseum.org/sparql" );
	if( !$db ) {
		print sparql_errno() . ": " . sparql_error(). "\n"; exit;
	}
	sparql_ns( "thesDimension","http://collection.britishmuseum.org/id/thesauri/dimension/" );
	sparql_ns( "bmo","http://collection.britishmuseum.org/id/ontology/" );
	sparql_ns( "ecrm","http://erlangen-crm.org/current/" );
	sparql_ns( "object","http://collection.britishmuseum.org/id/object/" );
	
	$sparql = "SELECT ?image ?weight ?axis ?diameter ?objectId WHERE {
  OPTIONAL {<OBJECT> bmo:PX_has_main_representation ?image }
  OPTIONAL { <OBJECT> ecrm:P43_has_dimension ?wDim .
           ?wDim ecrm:P2_has_type thesDimension:weight .
           ?wDim ecrm:P90_has_value ?weight}
  OPTIONAL {
     <OBJECT> ecrm:P43_has_dimension ?wAxis .
           ?wAxis ecrm:P2_has_type thesDimension:die-axis .
           ?wAxis ecrm:P90_has_value ?axis
    }
  OPTIONAL {
     <OBJECT> ecrm:P43_has_dimension ?wDiameter .
           ?wDiameter ecrm:P2_has_type thesDimension:diameter .
           ?wDiameter ecrm:P90_has_value ?diameter
    }
  OPTIONAL {
     <OBJECT> ecrm:P1_is_identified_by ?identifier.
     ?identifier ecrm:P2_has_type <http://collection.britishmuseum.org/id/thesauri/identifier/codexid> ;
        rdfs:label ?objectId
    }
  }";
	
	$result = sparql_query(str_replace('OBJECT', $uri, $sparql));
	if( !$result ) {
		print sparql_errno() . ": " . sparql_error(). "\n"; exit;
	}
	
	$fields = sparql_field_array($result);
	while( $row = sparql_fetch_array( $result ) )
	{
		foreach( $fields as $field )
		{
			if (strlen($row[$field]) > 0) {
				switch ($field) {
					case 'image':
						$writer->startElement('foaf:depiction');
							$writer->writeAttribute('rdf:resource', $row[$field]);
						$writer->endElement();
						break;
					case 'objectId':
						$writer->startElement('foaf:homepage');
							$writer->writeAttribute('rdf:resource', "http://www.britishmuseum.org/research/collection_online/collection_object_details.aspx?objectId={$row[$field]}&partId=1");
						$writer->endElement();
						break;
					case 'axis':
						$writer->startElement('nmo:hasAxis');
							$writer->writeAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#integer');
							$writer->text($row[$field]);
						$writer->endElement();						
						break;
					case 'weight':
						$writer->startElement('nmo:hasWeight');
							$writer->writeAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#decimal');
							$writer->text($row[$field]);
						$writer->endElement();
						break;
					case 'diameter':
						$writer->startElement('nmo:hasDiameter');
							$writer->writeAttribute('rdf:datatype', 'http://www.w3.org/2001/XMLSchema#decimal');
							$writer->text($row[$field]);
						$writer->endElement();
						break;
				}
			}
		}
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
