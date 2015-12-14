<?php 

$data = generate_json("pas-concordances.csv");

$records = array();
$records[] = array('object','match1','score1','match2','score2','match3','score3','match4','match4');
foreach ($data as $row){
	if (strlen($row['match2']) > 0 && strlen($row['match5']) == 0){
		$records[] = array($row['object'], "http://numismatics.org/ocre/id/{$row['match1']}",$row['score1'], "http://numismatics.org/ocre/id/{$row['match2']}",$row['score2'], (strlen($row['match3']) > 0 ? "http://numismatics.org/ocre/id/{$row['match3']}" : ''),$row['score3'], (strlen($row['match4']) > 0 ? "http://numismatics.org/ocre/id/{$row['match4']}" : ''),$row['score4']);
	}
}

$fp = fopen("pas-moderate.csv", 'w');
foreach ($records as $record) {
	fputcsv($fp, $record);
}
fclose($fp);

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
		$keys[] = trim($label);
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

?>