<?php 

$data = generate_json('coins.csv');
$mints = array();

foreach ($data as $row){
	$ref = $row['ref'];
	
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
				$uri = 'http://numismatics.org/ocre/id/' . implode('.', $id);
				
				$file_headers = @get_headers($uri . '.xml');
				if ($file_headers[0] == 'HTTP/1.1 200 OK'){
					echo "{$uri}\n";
				}
				
				
			}
			
			
			/*if (!in_array($pieces[2], $mints)){
				$mints[] = $pieces[2];
			}*/
			
			
			
		} else {
			echo "Invalid\n";
		}
	}
}

asort($mints);
var_dump($mints);

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
?>