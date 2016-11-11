<?php 

$list = generate_json('nomisma-portraits.csv');
$portraits = generate_json('portrait-images.csv');
$records = Array();

foreach($list as $row){
	$record = Array();
	$uri = $row['portrait'];
	
	$record['uri'] = $uri;
	$record['name'] = $row['label'];
	$record['ocre'] = "http://numismatics.org/ocre/results?q=portrait_facet:%22{$row['label']}%22";
	
	foreach ($portraits as $portrait){
		if ($portrait['uri'] == $uri){
			$record['Links to AU coins'] = $portrait['Links to AU coins'];
			$record['Link to AR coins'] = $portrait['Link to AR coins'];
			$record['Links to AE coins'] = $portrait['Links to AE coins'];
			$record['Worn Example'] = $portrait['Worn Example'];
			$record['Notes'] = $portrait['Notes'];
		}
	}
	
	$records[] = $record;
}

$file = fopen("portraits-new.csv","w");
fputcsv($file, Array('uri','name','ocre','AV','AR','AE','worn','notes'));
foreach ($records as $record)
{
	fputcsv($file,$record);
}

fclose($file);

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