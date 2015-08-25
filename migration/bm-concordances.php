<?php
//error_reporting(0);
$data = generate_json('/home/komet/ans_migration/ocre/bm-data/ric5.csv', false);
$ref_array = array();
$num_array = array();
$type_array = array();
$vol = 'RIC5';

//generate concordance list
$count = 0;
foreach ($data as $row){	
	//if ($count < 10){
		$about = 'http://collection.britishmuseum.org/id/object/' . $row['PRN'];
		$refs = explode('~', $row['Bib Xref']);
		$nums = explode('~', $row['Bib Spec']);		
		$authority = parse_authority($row['Authority'], $row['Authority Comment']);
		//calculating the authority for Volume 4
		$key = array_search($vol, $refs);
		if ($authority == 'RECALCULATE') {		
			preg_match('/p\.([0-9]+)/', $nums[$key], $matches);
			if (is_numeric($matches[1])){
				if ($matches[1] >= 92 && $matches[1] <= 211){
					$authority = 'ss';
				} else if ($matches[1] >= 212 && $matches[1] <= 313){
					$authority = 'crl';
				} else if ($matches[1] >= 314 && $matches[1] <= 343){
					$authority = 'ge';
				}
			} else {
				$authority = '';
			}
		} else if ($authority == 'RECALCULATE-VAL'){
			preg_match('/p\.([0-9]+)/', $nums[$key], $matches);
			if (is_numeric($matches[1])){
				if ($matches[1] >= 37 && $matches[1] <= 60){
					$authority = 'val_i';
				} else if ($matches[1] >= 61 && $matches[1] <= 62){
					$authority = 'val_i-gall';
				} else if ($matches[1] == 63){
					$authority = 'val_i-gall-val_ii-sala';
				} else if ($matches[1] >= 64 && $matches[1] <= 65){
					$authority = 'mar';
				} else if ($matches[1] >= 66 && $matches[1] <= 104){
					$authority = 'gall(1)';
				} else if ($matches[1] == 105){
					$authority = 'gall_sala(1)';
				} else if ($matches[1] == 106){
					$authority = 'gall_sals';
				} else if ($matches[1] >= 107 && $matches[1] <= 115){
					$authority = 'sala(1)';
				} else if ($matches[1] >= 116 && $matches[1] <= 122){
					$authority = 'val_ii';
				} else if ($matches[1] >= 123 && $matches[1] <= 127){
					$authority = 'sals';
				} else if ($matches[1] == 128){
					$authority = 'qjg';
				} else if ($matches[1] >= 129 && $matches[1] <= 190){
					$authority = 'gall(2)';
				} else if ($matches[1] == 191){
					$authority = 'gall_sala(2)';
				} else if ($matches[1] >= 192 && $matches[1] <= 200){
					$authority = 'sala(2)';
				}
			} else {
				$authority = '';
			}
		}
		
		foreach ($refs as $ref){
			if (!in_array($ref, $ref_array)){
				$ref_array[] = $ref;
			}
		}
		$tarray = array();
		foreach ($nums as $k=>$v){
			$tarray[$refs[$k]] = $v;
		}
		$num_array[$about] = array($authority, $tarray);
	
		
	//}	
	$count++;
}

//parse ids
//var_dump($num_array);
foreach ($num_array as $array){
	$authority = $array[0];
	$nums = $array[1];
	if (strlen($nums[$vol]) > 0){			
		if (!array_key_exists($nums[$vol], $type_array) && strlen($authority) > 0){
			$type_array[$nums[$vol]] = parse_ref($nums[$vol], $vol, $authority);
		}
	}
	
}

/********* CSV OUTPUT **********/
//create CSV labels
$csv = '"key","nomisma_id",';
foreach ($ref_array as $ref){
	$csv .= '"' . $ref . '",';
}
$csv .= "\n";

//process arrays
foreach($num_array as $k=>$array){
	$refs = $array[1];
	$csv .= '"' . $k . '",';
	if (strlen($refs[$vol]) > 0){
		$csv .= '"' . $type_array[$refs[$vol]] . '",';
	} else {
		$csv .= '"",';
	}
	foreach ($ref_array as $ref){
		$csv .= '"' . $refs[$ref] . '",';
	}
	$csv .= "\n";	
}
//var_dump($type_array);
file_put_contents($vol . '-con-new.csv', $csv);

function parse_ref($ref, $vol, $authority){
	switch ($vol){
		case 'RIC1':
			$prefix = 'ric.1(2).' . $authority . '.';
			break;
		case 'RIC2.1':
			$prefix = 'ric.2_1(2).' . $authority . '.';
			break;
		case 'RIC2':
			$prefix = 'ric.2.' . $authority . '.';
			break;
		case 'RIC3':
			$prefix = 'ric.3.' . $authority . '.';
			break;
		case 'RIC4':
			$prefix = 'ric.4.' . $authority . '.';
			break;
		case 'RIC5':
			$prefix = 'ric.5.' . $authority . '.';
			break;
	}
	
	$pieces = explode(',', $ref);
	foreach ($pieces as $piece){
		if (strpos(trim($piece), '-') === FALSE && strpos(trim($piece), '.') === FALSE){
			$num = trim($piece);
		}
	}
	
	//only process when the num is a string
	if (strlen($num) > 0){
		if (preg_match('/[a-zA-Z]/', $num)){
			//try uppercase first
			$upper = strtoupper($num);
			$url = "http://numismatics.org/ocre/id/{$prefix}" . urlencode($upper);
			$file_headers = @get_headers($url);
			if ($file_headers[0] == 'HTTP/1.1 200 OK'){
				echo "Pass: {$url}\n";
				return $url;
			} else {
				//then try lower
				$url = "http://numismatics.org/ocre/id/{$prefix}" . urlencode($num);
				$file_headers = @get_headers($url);
				if ($file_headers[0] == 'HTTP/1.1 200 OK'){
					echo "Pass: {$url}\n";
					return $url;
				} else {
					return '';
				}
			}
		} else {
			$url = "http://numismatics.org/ocre/id/{$prefix}" . urlencode($num); 
			$file_headers = @get_headers($url);
			if ($file_headers[0] == 'HTTP/1.1 200 OK'){
				echo "Pass: {$url}\n";
				return $url;
			} else {
				return '';
			}
		}
	}
}

function parse_authority($authority, $comment){
	$auth = '';
	if ($comment == 'Civil Wars'){
		$auth = 'cw';
	}  
	/*else if (strpos($authority, 'Septimius') >= 0 || strpos($authority, 'Caracalla') >= 0 || strpos($authority, 'Geta') >= 0){
		$auth = 'RECALCULATE';
	}*/
	else {
		switch (true) {
			case stristr($authority, 'Augustus'):
				$auth = 'aug';
				break;
			case stristr($authority, 'Tiberius'):
				$auth = 'tib';
				break;
			case stristr($authority, 'Gaius'):
				$auth = 'gai';
				break;
			case stristr($authority, 'Claudius'):
				$auth = 'cl';
				break;
			case stristr($authority, 'Nero'):
				$auth = 'ner';
				break;
			case stristr($authority, 'Macer'):
				$auth = 'clm';
				break;
			case stristr($authority, 'Galba'):
				$auth = 'gal';
				break;
			case stristr($authority, 'Otho'):
				$auth = 'ot';
				break;
			case stristr($authority, 'Vitellius'):
				$auth = 'vit';
				break;
			case stristr($authority, 'Vespasian'):
				$auth = 'ves';
				break;
			case stristr($authority, 'Titus'):
				$auth = 'tit';
				break;
			case stristr($authority, 'Domitian'):
				$auth = 'dom';
				break;
			case stristr($authority, 'Anonymous'):
				$auth = 'anys';
				break;
			case stristr($authority, 'Nerva'):
				$auth = 'ner';
				break;
			case stristr($authority, 'Trajan'):
				$auth = 'tr';
				break;
			case stristr($authority, 'Hadrian'):
				$auth = 'hdn';
				break;
			case stristr($authority, 'Antoninus Pius'):
				$auth = 'ant';
				break;
			case stristr($authority, 'Marcus Aurelius'):
				$auth = 'm_aur';
				break;
			case stristr($authority, 'Commodus'):
				$auth = 'com';
				break;
			case stristr($authority, 'Pertinax'):
				$auth = 'pert';
				break;
			case stristr($authority, 'Didius Julianus'):
				$auth = 'dj';			
				break;
			case stristr($authority, 'Pescennius Niger'):
				$auth = 'pn';
				break;
			case stristr($authority, 'Clodius Albinus'):
				$auth = 'ca';
				break;
			case stristr($authority, 'Macrinus'):
				$auth = 'mcs';
				break;
			case stristr($authority, 'Septimius'):
				$auth = 'RECALCULATE';
				break;
			case stristr($authority, 'Caracalla'):
				$auth = 'RECALCULATE';
				break;
			case stristr($authority, 'Geta'):
				$auth = 'RECALCULATE';
				break;
			case stristr($authority, 'Elagabalus'):
				$auth = 'el';
				break;
			case $authority == 'Severus Alexander':
				$auth = 'sa';
				break;
			case $authority == 'Maximinus I':
				$auth = 'max_i';
				break;
			case $authority == 'Paulina':
				$auth = 'pa';
				break;
			case $authority == 'Maximus':
				$auth = 'mxs';
				break;
			case $authority == 'Gordian I':
				$auth = 'gor_i';
				break;
			case $authority == 'Gordian II':
				$auth = 'gor_ii';
				break;
			case $authority == 'Balbinus':
				$auth = 'balb';
				break;
			case $authority == 'Pupienus':
				$auth = 'pup';
				break;
			case $authority == 'Balbinus~Pupienus':
				$auth = 'gor_iii_caes';
				break;	
			case $authority == 'Gordian III':
				$auth = 'gor_iii';
				break;
			case stristr($authority, 'Philip I'):
				$auth = 'ph_i';
				break;
			case stristr($authority, 'Otacilia'):
				$auth = 'ph_i';
				break;
			case $authority == 'Pacatian':
				$auth = 'pac';
				break;
			case $authority == 'Jotapian':
				$auth = 'jot';
				break;
			case $authority == 'Trajan Decius':
				$auth = 'tr_d';
				break;
			case $authority == 'Hostilian':
				$auth = 'tr_d';
				break;
			case $authority == 'Herennia Etruscilla':
				$auth = 'tr_d';
				break;
			case $authority == 'Herennius Etruscus':
				$auth = 'tr_d';
				break;
			case stristr($authority, 'Trebonianus Gallus'):
				$auth = 'tr_g';
				break;
			case $authority == 'Volusian':
				$auth = 'vo';
				break;
			case $authority == 'Aemilian':
				$auth = 'aem';
				break;
			case $authority == 'Uranius Antoninus':
				$auth = 'uran_an';
				break;
			case stristr($authority, 'Valerian'):
				$auth = 'RECALCULATE-VAL';
				break;
			case stristr($authority, 'Gallienus'):
				$auth = 'RECALCULATE-VAL';
				break;
			case stristr($authority, 'Salonina'):
				$auth = 'RECALCULATE-VAL';
				break;
			case stristr($authority, 'Saloninus'):
				$auth = 'RECALCULATE-VAL';
				break;
			case stristr($authority, 'Mariniana'):
				$auth = 'RECALCULATE-VAL';
				break;
			case $authority == 'Claudius II':
				$auth = 'cg';
				break;
			case $authority == 'Quintillus':
				$auth = 'qu';
				break;
		}		
	}
	return $auth;
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
