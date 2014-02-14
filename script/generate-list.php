<?php
/************************
 AUTHOR: Ethan Gruber
MODIFIED: August, 2012
DESCRIPTION: Convert Egyptian National Collection spreadsheet to NUDS
REQUIRED LIBRARIES: php5, php5-curl, php5-cgi
************************/
//create an array with pre-defined labels and values passed from the Filemaker POST
$data = generate_json('/home/komet/ans_migration/egypt/data.csv');

$rulers = array();
$dynasties = array();

foreach ($data as $row){
	if (strlen(trim($row['Dynasty or Country'])) > 0){
		if (!array_key_exists(trim($row['Dynasty or Country']), $dynasties)){
			$dynasties[trim($row['Dynasty or Country'])] = array(trim($row['Dynasty or Country']), trim($row['Country or Dynasty: Arabic']));
		}
	}
	if (strlen(trim($row['Ruler'])) > 0){
		if (!array_key_exists(trim($row['Ruler']), $rulers)){
			$rulers[trim($row['Ruler'])] = array(trim($row['Ruler']), trim($row['Ruler: Arabic']));
		}
	}
}

$dcsv = '"en","ar","nomisma"' . "\n";
foreach ($dynasties as $dynasty){
	$dcsv .= '"' . $dynasty[0] . '","' . $dynasty[1] .'",""' . "\n";
}

$rcsv = '"en","ar","viaf","nomisma"' . "\n";
foreach ($rulers as $ruler){
	$rcsv .= '"' . $ruler[0] . '","' . $ruler[1] .'","",""' . "\n";
}

file_put_contents('dynasties.csv', $dcsv);
file_put_contents('rulers.csv', $rcsv);

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
