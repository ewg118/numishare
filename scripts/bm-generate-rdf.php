<?php

require_once( "sparqllib.php" );
error_reporting(0);

$data = generate_json('bm.csv', false);
$lookup = generate_json('concordances.csv', false);

$rdf = '<rdf:RDF xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nm="http://nomisma.org/id/"
         xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" 
         xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">';
$count = 1;
foreach ($data as $row){
	$id = $row['PRN'];
	echo "Processing {$count}: {$id}\n";
	$about = 'http://collection.britishmuseum.org/id/object/' . $id;
	$refs = explode('~', $row['Bib Xref']);
	$nums = explode('~', $row['Bib Spec']);
	$accessions = explode('~', $row['Registration Number']);
	
	//get nomisma RRC coin type URI
	$coinType = '';
	foreach ($refs as $k=>$v){
		if ($v == 'RRC'){
			$rrc = $nums[$k];
			foreach ($lookup as $line){
				if ($line['RRC'] == $rrc){
					$coinType = $line['nomisma_id'];
				}
			}
		}
	}
	
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
	$count++;
	//echo $rdf;
}
$rdf .= '</rdf:RDF>';
file_put_contents('bm.rdf', $rdf);

function query_bm($id){
	$db = sparql_connect( "http://collection.britishmuseum.org/sparql" );
	if( !$db ) {
		print sparql_errno() . ": " . sparql_error(). "\n"; exit;
	}
	sparql_ns( "thesDimension","http://collection.britishmuseum.org/id/thesauri/dimension/" );
	sparql_ns( "bmo","http://collection.britishmuseum.org/id/ontology/" );
	sparql_ns( "ecrm","http://erlangen-crm.org/current/" );
	sparql_ns( "object","http://collection.britishmuseum.org/id/object/" );
	
	$sparql = "SELECT ?image ?weight ?axis ?diameter WHERE {
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
					case 'axis':
						$xml .= '<nm:' . $field . ' rdf:datatype="xs:ingeger">' . $row[$field] . '</nm:' . $field . '>';
						break;
					default:
						$xml .= '<nm:' . $field . ' rdf:datatype="xs:decimal">' . $row[$field] . '</nm:' . $field . '>';
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
