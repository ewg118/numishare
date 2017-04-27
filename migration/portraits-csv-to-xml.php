<?php 

/* Date: Feb 3, 2017
 * Function: This script parses the old spreadsheet format that includes links to records
 * in the databases, and parses source data in order to extract obverse or reverse portraits.
 * It is deprecated by portraits-csv_final-to-xml.php
 */

$portraits = generate_json('nomisma-portraits.csv');
$records = array();
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
			//recreate records to generate a new CSV export that includes only image URLs
			$record = array();
			$record['uri'] = $row['uri'];
			$record['name'] = $row['name'];
			$record['dynasty'] = $row['dynasty'];
			$record['ocre'] = $row['ocre'];
			$record['notes'] = $row['notes'];
			$record['year'] = $row['year'];
			
			//create portrait elements
			$writer->startElement('portrait');
				$writer->writeAttribute('uri', $row['uri']);
				//evaluate the note column in an attempt to parse whether the images should be a reverse instead of obverse
				$reverses = parse_note(trim($row['notes']));				
				
				//process columns for coin images in various materials
				if (strlen(trim($row['AV'])) > 0){
					$writer->startElement('material');
						$writer->writeAttribute('uri', 'http://nomisma.org/id/av');
						
						if (in_array('AV', $reverses)){
							$isReverse = true;
						} else {
							$isReverse = false;
						}
						
						$images = parse_urls(trim($row['AV']), $isReverse);
						$record['AV'] = $images;
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
						
						if (in_array('AR', $reverses)){
							$isReverse = true;
						} else {
							$isReverse = false;
						}
						
						$images = parse_urls(trim($row['AR']), $isReverse);
						$record['AR'] = $images;
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
						
						if (in_array('AE', $reverses)){
							$isReverse = true;
						} else {
							$isReverse = false;
						}
						
						$images = parse_urls(trim($row['AE']), $isReverse);
						$record['AE'] = $images;
						if (count($images) > 0){
							foreach ($images as $coinURL){
								$writer->writeElement('image', $coinURL);
							}
						}
					$writer->endElement();
				}
				if (strlen(trim($row['worn'])) > 0){
					$writer->startElement('worn');
					$images = parse_urls(trim($row['worn']), false);
					$record['worn'] = $images;
					if (count($images) > 0){
						foreach ($images as $coinURL){
							$writer->writeElement('image', $coinURL);
						}
					}
					$writer->endElement();
				}
			//add $record to $records
			$records[] = $record;
			
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


write_csv($records);
//var_dump($records);

function write_csv($records){
	$headings = array('uri','name','dynasty','ocre','AV','AR','AE','worn','notes','year');
	
	$csv = implode(',', $headings) . "\n";
	foreach ($records as $row){
		foreach ($headings as $k){
			if (isset($row[$k])){
				if (is_array($row[$k])){
					$csv .= '"' . implode('|', $row[$k]) . '"';
				} else {
					$csv .= '"' . $row[$k] . '"';
				}
			}
			//add comma if it is not the last column
			if ($k != 'year'){
				$csv .= ',';
			}
		}
		$csv .= "\n";
	}
	
	file_put_contents('portrait-images-new.csv', $csv);
}

//parse the notes to evaluate conditions for reverse images
function parse_note($note){
	$reverses = array();
	
	preg_match('/Rev.\s\((.*)\)/', $note, $matches);
	if (isset($matches[1])){
		$materials = explode(',', $matches[1]);
		foreach ($materials as $material){
			$reverses[] = trim($material);
		}
	}
	
	return $reverses;
}

//parse the URLs for coins in order to extract the image URL from the database
function parse_urls($val, $isReverse){
	$links = explode(';', $val);
	$images = array();
	
	foreach ($links as $link){
		$url = trim($link);
		
		if (strpos($url, 'numismatics.org') !== FALSE){
			$accnum = str_replace('http://numismatics.org/collection/', '', $url);
			$pieces = explode('.', $accnum);
			$accyear = $pieces[0];
			
			if ( (int)$accyear < 1900){
				$folder = '00001899';
			} elseif ( (int)$accyear >= 1900 && (int)$accyear < 1950){
				$folder = '19001949';
			} elseif ((int)$accyear >= 1950 && (int)$accyear < 2000){
				$folder = 19501999;
			} else {
				$folder = '20002049';
			}
			
			$side = $isReverse == true ? 'rev' : 'obv';
			$coinURL = "http://numismatics.org/collectionimages/{$folder}/{$accyear}/{$accnum}.{$side}.width350.jpg";
			$images[] = $coinURL;
			
		} elseif (strpos($url, 'ww2.smb.museum') !== FALSE){
			preg_match('/\?id=(\d+)/', $url, $matches);
			
			if (isset($matches[1])){
				$id = $matches[1];
				echo "Reading {$id}\n";
				$file = "http://ww2.smb.museum/ikmk/lido_export.php?id={$id}";
				
				$dom = new DOMDocument('1.0', 'UTF-8');
				if ($dom->load($file) === FALSE){
					echo "{$id} failed to load.\n";
				} else {
					$xpath = new DOMXpath($dom);
					$xpath->registerNamespace("lido", "http://www.lido-schema.org");
					
					$image_url = $xpath->query("descendant::lido:resourceRepresentation[@lido:type='image_thumb']/lido:linkResource")->item(0)->nodeValue;
					if (strlen($image_url) > 0){
						$pieces = explode('/', $image_url);
						$fname = array_pop($pieces);
						$image_path = implode('/', $pieces);
						$side = $isReverse == true ? 'rs' : 'vs';
						$coinURL = "{$image_path}/{$side}_opt.jpg";	
						$images[] = $coinURL;				
					}
				}				
			}
		} elseif (strpos($url, 'virginia') !== FALSE){
			$pieces = explode('/', $url);
			$frag = str_replace('.', '_', $pieces[4]);
			$side = $isReverse == true ? 'rev' : 'obv';
			$coinURL = "http://coins.lib.virginia.edu/images/coins/screen/n{$frag}_{$side}.jpg";
			$images[] = $coinURL;
		}
	}
	return $images;
}

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