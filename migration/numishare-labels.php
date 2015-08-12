<?php 

/* This PHP script reads CSV from the Numishare Labels Google spreadsheet
 * and generates partial xsl:choose statements to be posted into Numishare's
 * functions.xsl
 */

$labels = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdFVocVZHUWpnZHMxaXZ2LWVEU25wUFE&single=true&gid=0&output=csv');

//declare dynamic array variables for each language
foreach ($labels[0] as $k=>$v){
	if ($k != 'field'){
		$$k = array();
	}
}

//populate arrays
foreach ($labels as $row){
	$key = $row['field'];
	foreach ($row as $k=>$v){
		if ($k != 'field' && strlen($row['en']) > 0){
			if (strlen($v) > 0){
				$new = array($key, $v);
				array_push($$k, $new);
			}			
			//$$k[$key] = $v;
		}
	}
}

//output arrays
foreach ($labels[0] as $k=>$v){
	if ($k != 'field'){
		$text = '<xsl:when test="$lang=\'' . $k . '\'"><xsl:choose>';
		foreach ($$k as $row){
			$text .= '<xsl:when test="$label=\'' . $row[0] . '\'">' . trim($row[1]) . '</xsl:when>' . "\n";
		}
		$text .= '</xsl:choose></xsl:when>';
		file_put_contents($k . '.txt', $text);
	}
	
}



//var_dump($en);

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