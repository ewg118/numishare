<?php 

/* Date: April 27, 2017
 * Function: This script parses the new canonical format for the portraits spreadsheet
 * which already includes direct links to jpg files on various databases
 */

$portraits = generate_json('portrait-images-new.csv');
$dynasties = array();

//extract dynasties in chronological order
foreach($portraits as $row){
	if (!in_array($row['dynasty'], $dynasties)){
		$dynasties[] = $row['dynasty'];
	}
}

$writer = new XMLWriter();
$writer->openURI('portraits.xml');
//$writer->openURI('php://output');
$writer->startDocument('1.0','UTF-8');
$writer->setIndent(true);
$writer->setIndentString("    ");
$writer->startElement('portraits');

//process each row, organized by dynasty
foreach($dynasties as $dynasty){
	$writer->startElement('period');
	$writer->writeAttribute('label', $dynasty);
	foreach($portraits as $row){
		if ($row['dynasty'] == $dynasty){			
			//create portrait elements
			$writer->startElement('portrait');
				$writer->writeAttribute('uri', $row['uri']);			
				
				//process columns for coin images in various materials
				if (strlen(trim($row['AV'])) > 0){
					$writer->startElement('material');
						$writer->writeAttribute('uri', 'http://nomisma.org/id/av');
						
						$images = explode('|', trim($row['AV']));			
						if (count($images) > 0){
							foreach ($images as $coinURL){
								$writer->writeElement('image', $coinURL);
							}
						}
					$writer->endElement();
				}
				if (strlen(trim($row['AR'])) > 0){
					$writer->startElement('material');
						$writer->writeAttribute('uri', 'http://nomisma.org/id/ar');						
						
						$images = explode('|', trim($row['AR']));			
						if (count($images) > 0){
							foreach ($images as $coinURL){
								$writer->writeElement('image', $coinURL);
							}
						}
					$writer->endElement();
				}
				if (strlen(trim($row['AE'])) > 0){
					$writer->startElement('material');
						$writer->writeAttribute('uri', 'http://nomisma.org/id/ae');
						
						$images = explode('|', trim($row['AE']));			
						if (count($images) > 0){
							foreach ($images as $coinURL){
								$writer->writeElement('image', $coinURL);
							}
						}
					$writer->endElement();
				}
				if (strlen(trim($row['worn'])) > 0){
					$writer->startElement('worn');
					
					$images = explode('|', trim($row['worn']));					
					if (count($images) > 0){
						foreach ($images as $coinURL){
							$writer->writeElement('image', $coinURL);
						}
					}
					$writer->endElement();
				}
			
			//end portrait
			$writer->endElement();
		}
	}
	//end period
	$writer->endElement();
}
//end file
$writer->endElement();
$writer->flush();

//write CSV into an array
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