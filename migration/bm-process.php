<?php

require_once( "sparqllib.php" );
error_reporting(0);

$ric1 = generate_json('/home/komet/ans_migration/ocre/bm-data/ric1.csv', false);
$ric2_1 = generate_json('/home/komet/ans_migration/ocre/bm-data/ric2.1.csv', false);
$ric2 = generate_json('/home/komet/ans_migration/ocre/bm-data/ric2.csv', false);
$ric3 = generate_json('/home/komet/ans_migration/ocre/bm-data/ric3.csv', false);
$ric4 = generate_json('/home/komet/ans_migration/ocre/bm-data/ric4.csv', false);
$data = array_merge($ric1, $ric2_1, $ric2, $ric3, $ric4);
$lookup = generate_json('/home/komet/ans_migration/ocre/bm-data/concordances.csv', false);

$open = '<rdf:RDF xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:nm="http://nomisma.org/id/"
         xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" 
         xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">';

file_put_contents('bm-ric.rdf', $open);

$count = 1;
foreach ($data as $row){
	process_csv($row, $count);
	$count++;
}

file_put_contents('bm-ric.rdf', '</rdf:RDF>', FILE_APPEND);

function process_csv($row, $count){
	GLOBAL $lookup;
	$id = $row['PRN'];
	echo "Processing {$count}: {$id}\n";
	$about = 'http://collection.britishmuseum.org/id/object/' . $id;
	$accessions = explode('~', $row['expr sortexpr bm_reg_no_expr']);
	
	//get nomisma RRC coin type URI
	$coinType = '';
	foreach ($lookup as $line){
		if ($line['key'] == $about){
			$coinType = $line['nomisma_id'];
		}
	}
	$rdf = '';
	if (strlen($coinType) > 0){
		$rdf .= '<nm:coin rdf:about="' . $about . '">';
		$rdf .= '<dcterms:title xml:lang="en">British Museum: ' . $accessions[0] . '</dcterms:title>';
		$rdf .= '<dcterms:identifier>' . $accessions[0] . '</dcterms:identifier>';
		$rdf .= '<dcterms:publisher rdf:resource="http://nomisma.org/id/bm"/>';
		$rdf .= '<nm:collection rdf:resource="http://nomisma.org/id/bm"/>';
		$rdf .= '<nm:type_series_item rdf:resource="' . $coinType . '"/>';
		$rdf .= query_bm($id);
		$rdf .= '</nm:coin>';
	}
	file_put_contents('bm-ric.rdf', $rdf, FILE_APPEND);
}

function query_bm($id){
	$db = sparql_connect( "http://collection.britishmuseum.org/sparql" );
	if( !$db ) {
		print sparql_errno() . ": " . sparql_error(). "\n"; exit;
	}
	sparql_ns( "thesDimension","http://collection.britishmuseum.org/id/thesauri/dimension/" );
	sparql_ns( "bmo","http://collection.britishmuseum.org/id/ontology/" );
	sparql_ns( "ecrm","http://erlangen-crm.org/current/" );
	sparql_ns( "object","http://collection.britishmuseum.org/id/object/" );
	
	$sparql = "SELECT ?image ?weight ?axis ?diameter ?objectId WHERE {
  OPTIONAL {object:OBJECT bmo:PX_has_main_representation ?image }
  OPTIONAL { object:OBJECT ecrm:P43_has_dimension ?wDim .
           ?wDim ecrm:P2_has_type thesDimension:weight .
           ?wDim ecrm:P90_has_value ?weight}
  OPTIONAL {
     object:OBJECT ecrm:P43_has_dimension ?wAxis .
           ?wAxis ecrm:P2_has_type thesDimension:die-axis .
           ?wAxis ecrm:P90_has_value ?axis
    }
  OPTIONAL {
     object:OBJECT ecrm:P43_has_dimension ?wDiameter .
           ?wDiameter ecrm:P2_has_type thesDimension:diameter .
           ?wDiameter ecrm:P90_has_value ?diameter
    }
  OPTIONAL {
     object:CGR279727 ecrm:P1_is_identified_by ?identifier.
     ?identifier ecrm:P2_has_type <http://collection.britishmuseum.org/id/thesauri/identifier/codexid> ;
        rdfs:label ?objectId
    }
  }";
	
	$result = sparql_query(str_replace('OBJECT',$id,$sparql));
	if( !$result ) {
		print sparql_errno() . ": " . sparql_error(). "\n"; exit;
	}
	
	$xml = '';
	$fields = sparql_field_array($result);
	while( $row = sparql_fetch_array( $result ) )
	{
		foreach( $fields as $field )
		{
			if (strlen($row[$field]) > 0) {
				switch ($field) {
					case 'image':
						$xml .= '<foaf:depiction rdf:resource="' . $row[$field] . '"/>';
						break;
					case 'objectId':
						$xml .= '<foaf:homepage rdf:resource="http://www.britishmuseum.org/research/collection_online/collection_object_details.aspx?objectId=' . $row[$field] . '&amp;partId=1"/>';
						break;
					case 'axis':
						$xml .= '<nm:' . $field . ' rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">' . $row[$field] . '</nm:' . $field . '>';
						break;
					default:
						$xml .= '<nm:' . $field . ' rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">' . $row[$field] . '</nm:' . $field . '>';
				}
			}
		}
	}
	return $xml;
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
