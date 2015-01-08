<?php 

$data = generate_json('rrc.csv', false);
$ids = array();

foreach ($data as $row){
	if (!in_array($row['type'], $ids)){
		$ids[] = $row['type'];
	}
}
asort($ids);
$lowerids = array_map('strtolower', $ids);
$vals = array_count_values($lowerids);

$csv = '"id","note","label","material","denomination","issuers","fromDate","toDate","mint","mintLabel","mint_uncertainty","obvLegend","obvType","revLegend","revType"' . "\n";
foreach ($ids as $k=>$id){	
	$type = array();
	foreach($data as $row){
		if ($row['type'] == $id){
			$type['id'] = $row['type'];
			$type['note'] = ($vals[strtolower($id)] > 1  ? '*' : '');
			$type['label'] = $row['label'];
			$type['material'] = $row['material'];		
			$type['denomination'] = $row['denomination'];
			$type['issuers'] .= $row['moneyer'] . '|';
			$type['fromDate'] = $row['fromDate'];
			$type['toDate'] = $row['toDate'];		
			$type['mint'] = $row['mint'];
			$type['mintLabel'] = $row['mintLabel'];
			$type['mint_uncertainty'] = (strlen($row['unc']) > 0 ? 'true' : '');
			$type['obvLegend'] = $row['obvLegend'];
			$type['obvType'] = $row['obvType'];
			$type['revLegend'] = $row['revLegend'];
			$type['revType'] = $row['revType'];
		}
	}
	$type['issuers'] = substr($type['issuers'], 0, -1);
	foreach ($type as $k=>$v){
		$csv .= '"' . $v .'"';
		if ($k != 'revType'){
			$csv .= ',';
		} else {
			$csv .= "\n";
		}
	}
	//var_dump($type);
}
file_put_contents('rrc-new.csv', $csv);


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