<?php 

//load the RIC 10 pairs and generate a k=>v list

$data = generate_json('ric10-pairs.csv');
$pairs = array();
foreach ($data as $row){
	$pairs[$row['key']] = $row['val'];
}

//var_dump($pairs);

$doc = new DOMDocument();
$doc->load('ric6-10.xml'); 

$results = $doc->getElementsByTagName("result");

$types = array();
$con = array();

$position = 1;
foreach ($results as $result){
	$row = array();
	
	//reset mint
	$mint = null;
	foreach ($result->childNodes as $node){
		if ($node->nodeName == 'binding'){
			$prop = $node->getAttribute('name');
			$val = trim($node->nodeValue);			
			
			if ($prop == 's'){
				$row['uri'] = $val;
			} elseif ($prop == 'regno') {
				$row['regno'] = $val;
			} elseif ($prop == 'mint'){ 
				$mint = $val;
			} elseif ($prop == 'text'){
				$row['ref'] = $val;
				preg_match('/(RIC.*)\s::/', $val, $matches);
				
				//if a regex is made
				if (isset($matches[1])){
					$ref = $matches[1];
					
					preg_match('/p\.?(\d+)/', $ref, $m);
					if (isset($m[1])){
						$page = $m[1];
						$ref = preg_replace('/p\.?\d+/', '', $ref);
					} else {
						//reset the $page as null to prevent the value from being carried over through the loop
						$page = null;
					}
					
					//strip uncertain page number
					$ref = preg_replace('/p\.?\?/', '', $ref);
					//strip extraneous punctuation
					$ref = trim(str_replace('.', '' , str_replace(',', '', $ref)));
					//isolate RIC volume and number
					preg_match('/(RIC[1-9]0?)\s(\d+[a-z]?)/', $ref, $m);
					
					switch ($m[1]){
						case 'RIC6':
							$vol = 'ric.6';
							break;
						case 'RIC7':
							$vol = 'ric.7';
							break;
						case 'RIC8':
							$vol = 'ric.8';
							break;
						case 'RIC10':
							$vol = 'ric.10';
							break;
						default:
							$vol = null;
					}
					
					$num = $m[2];
					
					//if the volume is valid
					if (isset($vol)){
						//if the page is valid, then derive the authority by page number
						if (isset($page)) {
							if ($vol == 'ric.10'){
								//don't factor in the page in RIC 10
								if (array_key_exists($num, $pairs)){
									$auth = $pairs[$num];
									if (isset($auth)){
										$id = $vol . '.' . $auth . '.' . $num;
										$uri = "http://numismatics.org/ocre/id/{$id}";
											
										if (in_array($uri, $types)){
											$row['type'] = $uri;
										} else {
											$file_headers = @get_headers($uri . '.xml');
											if ($file_headers[0] == 'HTTP/1.1 200 OK'){
												$types[] = $uri;
												$row['type'] = $uri;
											}
										}
									}
								}
							} else {
								$auth = parse_auth($vol, $page);
								if (isset($auth)){
									$id = $vol . '.' . $auth . '.' . $num;
									$uri = "http://numismatics.org/ocre/id/{$id}";
										
									if (in_array($uri, $types)){
										$row['type'] = $uri;
									} else {
										$file_headers = @get_headers($uri . '.xml');
										if ($file_headers[0] == 'HTTP/1.1 200 OK'){
											$types[] = $uri;
											$row['type'] = $uri;
										}
									}
								}
							}
						} else {
							//parse auth using start and end numbers
							if ($vol == 'ric.10'){
								if (array_key_exists($num, $pairs)){
									$auth = $pairs[$num];
									if (isset($auth)){
										$id = $vol . '.' . $auth . '.' . $num;
										$uri = "http://numismatics.org/ocre/id/{$id}";
											
										if (in_array($uri, $types)){
											$row['type'] = $uri;
										} else {
											$file_headers = @get_headers($uri . '.xml');
											if ($file_headers[0] == 'HTTP/1.1 200 OK'){
												$types[] = $uri;
												$row['type'] = $uri;
											}
										}
									}
								}
							} else {
								if (isset($mint)){
									//otherwise, attempt to derive the authority from the mint
									echo "No page number, using {$mint}\n";
									
									$auth = parse_mint($mint);
									if (isset($auth)){
										$id = $vol . '.' . $auth . '.' . $num;
										$uri = "http://numismatics.org/ocre/id/{$id}";
											
										if (in_array($uri, $types)){
											$row['type'] = $uri;
										} else {
											$file_headers = @get_headers($uri . '.xml');
											if ($file_headers[0] == 'HTTP/1.1 200 OK'){
												$types[] = $uri;
												$row['type'] = $uri;
											}
										}
									}
								}
							}														
						}
					}
					
					//echo the process, set $row['type'] as blank if no match is made
					if (isset($row['type'])){
						echo "{$position} - {$row['uri']}: {$row['type']}\n";
					} else {
						$row['type'] = '';
						echo "{$position} - {$row['uri']}: no match\n";
					}
				}				
			}		
		}		
	}
	$con[] = $row;
	$position++;
}

$csv = "key,regno,nomisma_id,ref\n";

foreach ($con as $row){
	//ignore the objects with RIC9 references
	if (strpos($row['ref'], 'RIC9') === FALSE){
		$csv .= "{$row['uri']}," . '"' . $row['regno'] . '",' . "{$row['type']}," . '"' . $row['ref'] . '"' . "\n";
	}	
}

file_put_contents('ric6-10-con.csv', $csv);

function parse_mint($mint){
	switch($mint){	
		case 'Alexandria Egypt':
			$auth='alex';
			break;
		case 'London England':
			$auth='lon';
			break;
		case 'Rome city':
			$auth='rom';
			break;
		case 'Ticinum':
			$auth='tic';
			break;
		case 'Nicomedia':
			$auth='nic';
			break;
		case 'Antiochia ad Orontem':
		case 'Antioch':
			$auth='anch';
			break;
		case 'Cyzicus':
			$auth='cyz';
			break;
		case 'Thessaloniki Macedon':
			$auth='thes';
			break;
		case 'Serdica Thrace - city archaic':
			$auth='serd';
			break;
		case 'Thrace':
		case 'Perinthus':
		case 'Heraclea Pontica':
			$auth='her';
			break;
		case 'Siscia Pannonia - archaic':
			$auth='sis';
			break;
		case 'Aquileia':
			$auth='aq';
			break;
		case 'Ostia':
			$auth='ost';
			break;
		case 'Carthage':
			$auth='carth';
			break;
		case 'Trier':
			$auth='tri';
			break;
		case 'Lyon':
		case 'Lugdunum':
			$auth='lug';
			break;
		case 'Constantinople archaic':
			$auth='cnp';
			break;
		case 'Sirmium':
			$auth='sir';
			break;
		case 'Arles':
			$auth='ar';
			break;
		case 'Amiens':
			$auth='amb';
			break;
		case 'Milan city':
			$auth='med';
			break;
		default:
			$auth = null;
	}
	
	return $auth;
}

function parse_auth ($volume, $p){	
	if ($volume == 'ric.6'){
		if ($p >= 123 && $p <= 140){
			$authority = 'lon';
		}
		elseif ($p >= 163 && $p <= 228){
			$authority = 'tri';
		}
		elseif ($p >= 241 && $p <= 265){
			$authority = 'lug';
		}
		elseif ($p >= 279 && $p <= 298){
			$authority = 'tic';
		}
		elseif ($p >= 310 && $p <= 328){
			$authority = 'aq';
		}
		elseif ($p >= 350 && $p <= 392){
			$authority = 'rom';
		}
		elseif ($p >= 400 && $p <= 410){
			$authority = 'ost';
		}
		elseif ($p >= 422 && $p <= 435){
			$authority = 'carth';
		}
		elseif ($p >= 455 && $p <= 485){
			$authority = 'sis';
		}
		elseif ($p >= 491 && $p <= 500){
			$authority = 'serd';
		}
		elseif ($p >= 509 && $p <= 519){
			$authority = 'thes';
		}
		elseif ($p >= 529 && $p <= 542){
			$authority = 'her';
		}
		elseif ($p >= 553 && $p <= 568){
			$authority = 'nic';
		}
		elseif ($p >= 578 && $p <= 595){
			$authority = 'cyz';
		}
		elseif ($p >= 612 && $p <= 644){
			$authority = 'anch';
		}
		elseif ($p >= 660 && $p <= 686){
			$authority = 'alex';
		}
	} elseif ($volume == 'ric.7'){
		if ($p >= 97 && $p <= 116){
			$authority = 'lon';
		}
		elseif ($p >= 122 && $p <= 142){
			$authority = 'lug';
		}
		elseif ($p >= 162 && $p <= 223){
			$authority = 'tri';
		}
		elseif ($p >= 234 && $p <= 279){
			$authority = 'ar';
		}
		elseif ($p >= 296 && $p <= 347){
			$authority = 'rom';
		}
		elseif ($p >= 360 && $p <= 387){
			$authority = 'tic';
		}
		elseif ($p >= 392 && $p <= 147){
			$authority = 'aq';
		}
		elseif ($p >= 422 && $p <= 460){
			$authority = 'sis';
		}
		elseif ($p >= 467 && $p <= 477){
			$authority = 'sir';
		}
		elseif ($p >= 479 && $p <= 480){
			$authority = 'serd';
		}
		elseif ($p >= 498 && $p <= 530){
			$authority = 'thes';
		}
		elseif ($p >= 541 && $p <= 561){
			$authority = 'her';
		}
		elseif ($p >= 569 && $p <= 590){
			$authority = 'cnp';
		}
		elseif ($p >= 597 && $p <= 635){
			$authority = 'nic';
		}
		elseif ($p >= 643 && $p <= 660){
			$authority = 'cyz';
		}
		elseif ($p >= 675 && $p <= 697){
			$authority = 'anch';
		}
		elseif ($p >= 702 && $p <= 712){
			$authority = 'alex';
		}
	} elseif ($volume == 'ric.8'){
		if ($p >= 121 && $p <= 124){
			$authority = 'amb';
		}
		elseif ($p >= 138 && $p <= 169){
			$authority = 'tri';
		}
		elseif ($p >= 177 && $p <= 196){
			$authority = 'lug';
		}
		elseif ($p >= 204 && $p <= 231){
			$authority = 'ar';
		}
		elseif ($p >= 233 && $p <= 233){
			$authority = 'med';
		}
		elseif ($p >= 248 && $p <= 305){
			$authority = 'rom';
		}
		elseif ($p >= 314 && $p <= 338){
			$authority = 'aq';
		}
		elseif ($p >= 348 && $p <= 381){
			$authority = 'sis';
		}
		elseif ($p >= 384 && $p <= 394){
			$authority = 'sir';
		}
		elseif ($p >= 401 && $p <= 425){
			$authority = 'thes';
		}
		elseif ($p >= 429 && $p <= 439){
			$authority = 'her';
		}
		elseif ($p >= 446 && $p <= 465){
			$authority = 'cnp';
		}
		elseif ($p >= 470 && $p <= 485){
			$authority = 'nic';
		}
		elseif ($p >= 489 && $p <= 501){
			$authority = 'cyz';
		}
		elseif ($p >= 511 && $p <= 534){
			$authority = 'anch';
		}
		elseif ($p >= 538 && $p <= 546){
			$authority = 'alex';
		}
	}
	
	return $authority;
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