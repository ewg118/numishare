<?php 

//load the RIC 10 pairs and generate a k=>v list

//$data = generate_json('ric10-pairs.csv');

//only include authorities that are individually parseable by name
$ric5_authorities = array('RIC5.1'=>array('Aurelian','Severina','Gallienus','Saloninus','Valerian','Salonina','salonina','Claudius II','Quintillus','Tacitus','Florian'), 'RIC5.2'=>array('Probus','Carus','Carinus','Diocletian','Constantius I','Galerius','Maximian','Postumus','Laelian','Marius','Victorinus','Tetricus I','Tetricus II', 'Carausius', 'Allectus', 'Macrian II','Quietus','Vabalathus','Regalian','Julian of Pannonia'));

/*$pairs = array();
foreach ($data as $row){
	$pairs[$row['key']] = $row['val'];
}*/

//var_dump($pairs);

$doc = new DOMDocument();
$doc->load('ric2_1(2).xml'); 

$results = $doc->getElementsByTagName("result");
$types = array();
$con = array();

$position = 1;
foreach ($results as $result){
	$row = array();
	$mint = null;
	$auth = null;
	
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
			} elseif ($prop == 'auth'){
				$auth = $val;
			} elseif ($prop == 'ref'){
				$row['ref'] = $val;				
			}		
		}		
	}
	
	$typeURI = parse_ref($row['ref'], $mint, $auth);
	//echo the process, set $row['type'] as blank if no match is made
	if (isset($typeURI)){
		$row['type'] = $typeURI;
		echo "{$position} - {$row['uri']}: {$typeURI}\n";
	} else {
		$row['type'] = '';
		echo "{$position} - {$row['uri']}: no match\n";
	}
	
	$con[] = $row;
	$position++;
}

$csv = "uri,regno,type,ref\n";

foreach ($con as $row){
	//ignore the objects with RIC9 references
	$csv .= "{$row['uri']}," . '"' . $row['regno'] . '",' . "{$row['type']}," . '"' . $row['ref'] . '"' . "\n";
}

file_put_contents('ric2_1(2)-con.csv', $csv);

function parse_ref($referenceText, $mint, $auth){
	GLOBAL $types;
	preg_match('/(RIC[^\s]+)(.*)\s::/', $referenceText, $matches);
	
	//if a regex is made
	if (isset($matches[1])){
		$unparsedVol = $matches[1];
		$ref = $matches[2];
		
		preg_match('/p\.?\s?(\d+)/', $ref, $m);
		if (isset($m[1])){
			//isolate and strip page
			$page = $m[1];
			$ref = preg_replace('/p\.?\s?\d+/', '', $ref);
		} else {
			//reset the $page as null to prevent the value from being carried over through the loop
			$page = null;
		}
		
		//strip uncertain page number
		$ref = preg_replace('/p\.?\?/', '', $ref);
		//strip extraneous punctuation
		$ref = trim(str_replace('.', '' , str_replace(',', '', $ref)));
		//isolate type number
		preg_match('/(\d+[a-z]?)/', $ref, $m);
		
		if (isset($m[1])){
			$num = $m[1];
			//$unparsedVol = $m[1];
				
			//evaluate RIC 5 part by authority
			if ($unparsedVol == 'RIC5'){
				$unparsedVol = parse_ric5($auth);
			}
				
			switch ($unparsedVol){
				case 'RIC2.1':
					$vol = 'ric.2_1(2)';
					break;
				case 'RIC5.1':
				case 'RIC5.2':
					$vol = 'ric.5';
					break;
				case 'RIC6':
					$vol = 'ric.6';
					break;
				case 'RIC7':
					$vol = 'ric.7';
					break;
				case 'RIC8':
					$vol = 'ric.8';
					break;
				case 'RIC9':
					$vol = 'ric.9';
					break;
				case 'RIC10':
					$vol = 'ric.10';
					break;
				default:
					$vol = null;
			}
				
			//$num = $m[2];
				
			//if the volume is valid
			if (isset($vol)){
				//if the page is valid, then derive the authority by page number
				if (isset($page)) {
					if ($vol == 'ric.10'){
						//don't factor in the page in RIC 10
						if (array_key_exists($num, $pairs)){
							$authCode = $pairs[$num];
							if (isset($authCode)){
								$id = $vol . '.' . $authCode . '.' . $num;
								$uri = "http://numismatics.org/ocre/id/{$id}";
	
								if (in_array($uri, $types)){
									return $uri;
								} else {
									$file_headers = @get_headers($uri . '.xml');
									if ($file_headers[0] == 'HTTP/1.1 200 OK'){
										$types[] = $uri;
										return $uri;
									}
								}
							}
						}
					} else {						
						$authCode = parse_auth_by_page($unparsedVol, $page);
						//echo "{$unparsedVol} {$authCode}: Page {$page}, number {$num}\n";
						if (isset($authCode)){
							
							$Uuri = "http://numismatics.org/ocre/id/{$vol}.{$authCode}.{strtoupper($num)}";
							$Luri = "http://numismatics.org/ocre/id/{$vol}.{$authCode}.{$num}";
							
							//try uppercase first, then lowercase
							if (in_array($Uuri, $types)){
								return $Uuri;
							} elseif (in_array($Luri, $types)){
								return $Luri;
							} else {
								$file_headers = @get_headers($Uuri . '.xml');
								if ($file_headers[0] == 'HTTP/1.1 200 OK'){
									$types[] = $Uuri;
									return $Uuri;
								} else {
									$file_headers = @get_headers($Luri . '.xml');
									if ($file_headers[0] == 'HTTP/1.1 200 OK'){
										$types[] = $Luri;
										return $Luri;
									}
								}
								
							}
						}
					}
				} else {
					//parse auth using start and end numbers
					if ($vol == 'ric.10'){
						if (array_key_exists($num, $pairs)){
							$authCode = $pairs[$num];
							if (isset($authCode)){
								$id = $vol . '.' . $authCode . '.' . $num;
								$uri = "http://numismatics.org/ocre/id/{$id}";
	
								if (in_array($uri, $types)){
									return $uri;
								} else {
									$file_headers = @get_headers($uri . '.xml');
									if ($file_headers[0] == 'HTTP/1.1 200 OK'){
										$types[] = $uri;
										return $uri;
									}
								}
							}
						}
					} else {
						if (isset($mint) || isset($auth)){
							//otherwise, attempt to derive the authority from the mint or the authority
	
							if ($vol == 'ric.6' || $vol == 'ric.7' || $vol == 'ric.8'){
								echo "No page number, using {$mint}\n";
								$authCode = parse_mint($mint);
							} else {
								echo "No page number, using {$auth}\n";
								$authCode = parse_authority($auth);
							}
	
							if (isset($authCode)){
								$Uuri = "http://numismatics.org/ocre/id/{$vol}.{$authCode}.{strtoupper($num)}";
								$Luri = "http://numismatics.org/ocre/id/{$vol}.{$authCode}.{$num}";
									
								//try uppercase first, then lowercase
								if (in_array($Uuri, $types)){
									return $Uuri;
								} elseif (in_array($Luri, $types)){
									return $Luri;
								} else {
									$file_headers = @get_headers($Uuri . '.xml');
									if ($file_headers[0] == 'HTTP/1.1 200 OK'){
										$types[] = $Uuri;
										return $Uuri;
									} else {
										$file_headers = @get_headers($Luri . '.xml');
										if ($file_headers[0] == 'HTTP/1.1 200 OK'){
											$types[] = $Luri;
											return $Luri;
										}
									}
								
								}
							}
						}
					}
				}
			}
		}
	}
}

function parse_ric5($auth){
	GLOBAL $ric5_authorities;
	
	if (in_array($auth, $ric5_authorities['RIC5.1'])){
		return 'RIC5.1';
	} elseif (in_array($auth, $ric5_authorities['RIC5.2'])){
		return 'RIC5.2';
	}
}

function parse_authority($authority){
	$authCode = null;
	
	switch ($authority){
		case $authority == 'Vespasian':
			$authCode = 'ves';
			break;
		case $authority == 'Titus':
			$authCode = 'tit';
			break;
		case $authority == 'Domitian':
			$authCode = 'dom';
			break;
		case $authority == 'Claudius II':
			$authCode = 'cg';
			break;
		case $authority == 'Quintillus':
			$authCode = 'qu';
			break;
		case $authority == 'Tacitus':
			$authCode = 'tac';
			break;
		case $authority == 'Florian':
			$authCode = 'fl';
			break;
		case $authority == 'Probus':
			$authCode = 'pro';
			break;
		case $authority == 'Carus':
		case $authority == 'Carinus':
			$authCode = 'car';
			break;
		case $authority == 'Diocletian':
		case $authority == 'Maximian':
		case $authority == 'Constantius I':
		case $authority == 'Galerius':
			$authCode = 'dio';
			break;
		case $authority == 'Postumus':
			$authCode = 'post';
			break;
		case $authority == 'Laelian':
			$authCode = 'lae';
			break;
		case $authority == 'Marius':
			$authCode = 'mar';
			break;
		case $authority == 'Victorinus':
			$authCode = 'vict';
			break;
		case $authority == 'Tetricus I':
		case $authority == 'Tetricus II':
			$authCode = 'tet_i';
			break;
		case $authority == 'Allectus':
			$authCode = 'all';
			break;
		case $authority == 'Macrian II':
			$authCode = 'mac_ii';
			break;
		case $authority == 'Quietus':
			$authCode = 'quit';
			break;
		case $authority == 'Vabalathus':
			$authCode = 'vab';
			break;
		case $authority == 'Regalian':
			$authCode = 'reg';
			break;
		case $authority == 'Julian of Pannonia':
			$authCode = 'jul_i';
			break;
		default: 
			$authCode = null;
	}
	
	return $authCode;
}

function parse_mint($mint){
	$auth = null;
	
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

function parse_auth_by_page ($volume, $p){	
	$authority = null;
	if ($volume == 'RIC2.1'){
		if ($p >= 58 && $p <= 180){
			$authority = 'ves';
		} elseif ($p >= 199 && $p <= 236){
			$authority = 'tit';
		} elseif ($p >= 266 && $p <= 331){
			$authority = 'dom';
		}
	} else if ($volume == 'RIC5.1'){
		if ($p >= 37 && $p <= 60){
			$authority = 'val_i';
		} else if ($p >= 61 && $p <= 62){
			$authority = 'val_i-gall';
		} else if ($p == 63){
			$authority = 'val_i-gall-val_ii-sala';
		} else if ($p >= 64 && $p <= 65){
			$authority = 'marin';
		} else if ($p >= 66 && $p <= 104){
			$authority = 'gall(1)';
		} else if ($p == 105){
			$authority = 'gall_sala(1)';
		} else if ($p == 106){
			$authority = 'gall_sals';
		} else if ($p >= 107 && $p <= 115){
			$authority = 'sala(1)';
		} else if ($p >= 116 && $p <= 122){
			$authority = 'val_ii';
		} else if ($p >= 123 && $p <= 127){
			$authority = 'sals';
		} else if ($p == 128){
			$authority = 'qjg';
		} else if ($p >= 129 && $p <= 190){
			$authority = 'gall(2)';
		} else if ($p == 191){
			$authority = 'gall_sala(2)';
		} else if ($p >= 192 && $p <= 200){
			$authority = 'sala(2)';
		} elseif ($p >= 211 && $p <= 237){
			$authority = 'cg';
		} elseif ($p >= 239 && $p <= 247){
			$authority = 'qu';
		} elseif ($p >= 263 && $p <= 312){
			$authority = 'aur';
		} elseif ($p == 313){
			$authority = 'aur_seva';
		} elseif ($p >= 314 && $p <= 318){
			$authority = 'seva';
		} elseif ($p >= 327 && $p <= 348){
			$authority = 'tac';
		} elseif ($p >= 350 && $p <= 360){
			$authority = 'fl';
		}
	} elseif ($volume == 'RIC5.2'){
		if ($p >= 20 && $p <= 121){
			$authority = 'pro';
		} elseif ($p >= 135 && $p <= 203){
			$authority = 'car';
		} elseif ($p >= 221 && $p <= 309){
			$authority = 'dio';
		} elseif ($p >= 336 && $p <= 368){
			$authority = 'post';
		} elseif ($p >= 372 && $p <= 373){
			$authority = 'lae';
		} elseif ($p >= 377 && $p <= 378){
			$authority = 'mar';
		} elseif ($p >= 387 && $p <= 398){
			$authority = 'vict';
		} elseif ($p >= 402 && $p <= 425){
			$authority = 'tet_i';
		} elseif ($p >= 463 && $p <= 549){
			$authority = 'cara';
		} elseif ($p >= 550 && $p <= 556){
			$authority = 'cara-dio-max_her';
		} elseif ($p >= 558 && $p <= 570){
			$authority = 'all';
		} elseif ($p >= 580 && $p <= 581){
			$authority = 'mac_ii';
		} elseif ($p >= 582 && $p <= 583){
			$authority = 'quit';
		} elseif ($p == 584){
			$authority = 'zen';
		} elseif ($p == 585){
			$authority = 'vab';
		} elseif ($p >= 586 && $p <= 587){
			$authority = 'reg';
		} elseif ($p == 588){
			$authority = 'dry';
		} elseif ($p == 589 ){
			$authority = 'aurl';
		} elseif ($p == 590 ){
			$authority = 'dom_g';
		} elseif ($p == 591){
			$authority = 'sat';
		} elseif ($p == 592){
			$authority = 'bon';
		} elseif ($p >= 593 && $p <= 594){
			$authority = 'jul_i';
		} elseif ($p == 595){
			$authority = 'ama';
		}
	} elseif ($volume == 'RIC6'){
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
	} elseif ($volume == 'RIC7'){
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
	} elseif ($volume == 'RIC8'){
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
	} elseif ($volume == 'RIC9'){
		if ($p == 2){
			$authority = 'lon';
		}
		elseif ($p >= 13 && $p <= 34){
			$authority = 'tri';
		}
		elseif ($p >= 42 && $p <= 53){
			$authority = 'lug';
		}
		elseif ($p >= 61 && $p <= 70){
			$authority = 'ar';
		}
		elseif ($p >= 75 && $p <= 84){
			$authority = 'med';
		}
		elseif ($p >= 94 && $p <= 107){
			$authority = 'aq';
		}
		elseif ($p >= 116 && $p <= 136){
			$authority = 'rom';
		}
		elseif ($p >= 145 && $p <= 155){
			$authority = 'sis';
		}
		elseif ($p >= 158 && $p <= 162){
			$authority = 'sir';
		}
		elseif ($p >= 173 && $p <= 188){
			$authority = 'thes';
		}
		elseif ($p >= 191 && $p <= 199){
			$authority = 'her';
		}
		elseif ($p >= 209 && $p <= 236){
			$authority = 'cnp';
		}
		elseif ($p >= 239 && $p <= 247){
			$authority = 'cyz';
		}
		elseif ($p >= 250 && $p <= 263){
			$authority = 'nic';
		}
		elseif ($p >= 272 && $p <= 295){
			$authority = 'anch';
		}
		elseif ($p >= 298 && $p <= 304){
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