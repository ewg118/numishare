<?php
error_reporting(0);
$data = generate_json('bm.csv', false);
$ref_array = array();
$num_array = array();
$rrc_array = array();

//generate concordance list
foreach ($data as $row){
	$about = 'http://collection.britishmuseum.org/id/object/' . $row['PRN'];
	$refs = explode('~', $row['Bib Xref']);
	$nums = explode('~', $row['Bib Spec']);
	
	foreach ($refs as $ref){
		if (!in_array($ref, $ref_array)){
			$ref_array[] = $ref;
		}
	}
	$tarray = array();
	foreach ($nums as $k=>$v){		
		$tarray[$refs[$k]] = $v;		
	}
	$num_array[] = $tarray;	
}

//parse RRC ids
foreach ($num_array as $num){
	if (strlen($num['RRC']) > 0){
		if (!array_key_exists($num['RRC'], $rrc_array)){
			$rrc_array[$num['RRC']] = parse_rrc($num['RRC']);
		}
	}
}

/********* CSV OUTPUT **********/
//create CSV labels
$csv = '"key","nomisma_id",';
foreach ($ref_array as $ref){
	$csv .= '"' . $ref . '",';
}
$csv .= "\n";

//process arrays
foreach($num_array as $num){
	$csv .= '"' . '",';
	if (strlen($num['RRC']) > 0){
		$csv .= '"' . $rrc_array[$num['RRC']] . '",';
	} else {
		$csv .= '"",';
	}
	foreach ($ref_array as $ref){
		$csv .= '"' . $num[$ref] . '",';
	}
	$csv .= "\n";
}
//var_dump($rrc_array);
file_put_contents('concordances.csv', $csv);

function parse_rrc($num){
	$url = 'http://nomisma.org/id/rrc-' . str_replace('/', '.', $num);
	$file_headers = @get_headers($url);
	$rdf_headers = @get_headers($url . '.rdf');
	if ($file_headers[0] == 'HTTP/1.1 200 OK' && $rdf_headers[0] == 'HTTP/1.1 200 OK'){
		return $url;
	} else {
		return '';
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
