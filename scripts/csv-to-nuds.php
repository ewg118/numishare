<?php 

$data = generate_json('/home/komet/ans_migration/rrc/rrc-processed.csv');
$deities_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdHk2ZXBuX0RYMEZzUlNJUkZOLXRUTmc&single=true&gid=0&output=csv');
$nomismaUris = array();
$errors = array();
$records = array();
$processed = array();

$count = 0;
foreach ($data as $row){
	$id =  substr(strstr(trim($row['id']), 'id/'), 3);	
	$records[] = $id;
	
	//ignore types where the ID is a full integer and the following row is ID.1
	$num = str_replace('rrc-', '', $id);
	$next =  str_replace('rrc-', '', substr(strstr(trim($data[$count+1]['id']), 'id/'), 3));
	if (is_numeric($num) && $num == round($num)){
		//ignore lone integer values
		echo "Ignoring {$id}\n";
	} else {
		$xml = generate_nuds($row, $id);
		//write file
		write_file($xml, $id);
	}
	
	$count++;
}

if (count($errors) > 0){
	$text = '';
	foreach ($errors as $error){
		$text .= "{$error}\n";
	}
	$handle = fopen('error.log', 'w');
	fwrite($handle, $text);
	fclose($handle);
}

echo count($records) . " records\n";
echo count($processed) . " processed\n";
echo count($errors) . " errors\n";

foreach ($errors as $error){
	echo "Error: {$error}\n";
}
//$fileName = '/tmp/' . $nudsid . '.xml';



/****** GENERATE NUDS ******/
function generate_nuds($row, $nudsid){
	GLOBAL $deities_array;
	//develop date	
	if (strlen($row['fromDate']) > 0 || strlen($row['toDate']) > 0){
			$date = get_date($row['fromDate'], $row['toDate']);
	}

	//control
	$xml = '<?xml version="1.0" encoding="UTF-8"?><nuds xmlns="http://nomisma.org/nuds" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" recordType="conceptual">';
	$xml .= "<control><recordId>{$nudsid}</recordId>";
	$xml .= '<publicationStatus>approved</publicationStatus>';
	$xml .= '<maintenanceAgency><agencyName>American Numismatic Society</agencyName></maintenanceAgency>';
	$xml .= '<maintenanceStatus>derived</maintenanceStatus>';
	$xml .= '<maintenanceHistory><maintenanceEvent>';
	$xml .= '<eventType>derived</eventType><eventDateTime standardDateTime="' . date(DATE_W3C) . '">' . date(DATE_RFC2822) . '</eventDateTime><agentType>machine</agentType><agent>PHP</agent><eventDescription>Generated from OCRE CSV.</eventDescription>';
	$xml .= '</maintenanceEvent></maintenanceHistory>';
	$xml .= '<rightsStmt><copyrightHolder>British Museum</copyrightHolder><license xlink:type="simple" xlink:href="http://opendatacommons.org/licenses/odbl/"/></rightsStmt>';
	$xml .= '<semanticDeclaration><prefix>dcterms</prefix><namespace>http://purl.org/dc/terms/</namespace></semanticDeclaration>';
	$xml .= '<semanticDeclaration><prefix>skos</prefix><namespace>http://www.w3.org/2004/02/skos/core#</namespace></semanticDeclaration>';
	$xml .= "</control>";
	$xml .= '<descMeta>';
	
	/***** TITLE *****/
	$xml .= '<title xml:lang="en">' . $row['label'] . '</title>';
	$xml .= '<typeDesc>';	
	//date
	$xml .= $date;
	//objectType
	if (strlen($row['object_type']) > 0){
		$vals = explode('|', $row['object_type']);
		foreach ($vals as $val){
			if (substr($val, -1) == '?'){
				$uri = substr($val, 0, -1);	
				$xml .= processUri($uri, 'objectType', true);
			} else {
				$uri = $val;
				$xml .= processUri($uri, 'objectType', false);
			}		
		}
	}
	$xml .= '<manufacture xlink:type="simple" xlink:href="http://nomisma.org/id/struck">Struck</manufacture>';
	//denomination
	if (strlen($row['denomination']) > 0){
		$vals = explode('|', $row['denomination']);
		foreach ($vals as $val){
			if (strstr($val, 'http') == true){
				if (substr($val, -1) == '?'){
					$uri = substr($val, 0, -1);
					$xml .= processUri($uri, 'denomination', true);
				} else {
					$uri = $val;
					$xml .= processUri($uri, 'denomination', false);
				}
			} else {
				$xml .= '<denomination>' . $val . '</denomination>';
			}
				
		}
	}
	//material
	if (strlen($row['material']) > 0){
		$vals = explode('|', $row['material']);
		foreach ($vals as $val){
			if (substr($val, -1) == '?'){
				$uri = substr($val, 0, -1);
				$xml .= processUri($uri, 'material', true);
			} else {
				$uri = $val;
				$xml .= processUri($uri, 'material', false);
			}
		}
	}
	//authority
	$xml .= '<authority>';
	if (strlen($row['issuers']) > 0){
		$vals = explode('|', $row['issuers']);
		foreach ($vals as $val){
			if (strstr($val, 'http') == true){
				if (substr($val, -1) == '?'){
					$uri = substr($val, 0, -1);
					$xml .= processUri($uri, 'issuer', true);
				} else {
					$uri = $val;
					$xml .= processUri($uri, 'issuer', false);
				}
			} else {
				if (substr($val, -1) == '?'){
					$val = substr($val, 0, -1);
					$xml .= '<persname xlink:type="simple" xlink:role="issuer" certainty="uncertain">' . $val . '</persname>';
				} else {
					$xml .= '<persname xlink:type="simple" xlink:role="issuer">' . $val . '</persname>';
				}
			}
			
		}
	}
	$xml .= '</authority>';
	
	//geography
	if (strlen($row['mint']) > 0){
		if (strlen($row['mint_uncertainty']) > 0){
			$uncertain = true;
		} else {
			$uncertain = false;
		}
		$xml .= '<geographic>';
		if (strlen($row['mint']) > 0){
			$vals = explode('|', $row['mint']);
			foreach ($vals as $val){
				if (substr($val, -1) == '?'){
					$uri = substr($val, 0, -1);
					$xml .= processUri($uri, 'mint', true);
				} else {
					$uri = $val;
					$xml .= processUri($uri, 'mint', $uncertain);
				}
			}
		}
		$xml .= '</geographic>';
	}
	
	//obverse
	if (strlen($row['obvLegend']) > 0 || strlen($row['obvType']) > 0){
		$xml .= '<obverse>';
		if (strlen($row['obvLegend']) > 0){
			$xml .= '<legend scriptCode="Latn">' . trim($row['obvLegend']) . '</legend>';
		}
		if (strlen($row['obvType']) > 0){
			$xml .= '<type><description xml:lang="en">' . trim($row['obvType']) . '</description></type>';
			//deity
			foreach($deities_array as $deity){
				if (strstr($deity['name'], ' ') !== FALSE){
					//haystack is string when the deity is multiple words
					$haystack = strtolower(trim($row['obvType']));
					if (strstr($haystack, strtolower($deity['matches'])) !== FALSE) {
						$bm_uri = strlen($deity['bm_uri']) > 0 ? ' xlink:href="' . $deity['bm_uri'] . '"' : '';
						$xml .= '<persname xlink:type="simple" xlink:role="deity"' . $bm_uri . '>' . $deity['name'] . '</persname>';
					}
				} else {
					//haystack is array
					$desc = preg_replace('/[^a-z]+/i', ' ', trim($row['obvType']));
					$haystack = explode(' ', $desc);
					if (in_array($deity['matches'], $haystack)){
						$bm_uri = strlen($deity['bm_uri']) > 0 ? ' xlink:href="' . $deity['bm_uri'] . '"' : '';
						$xml .= '<persname xlink:type="simple" xlink:role="deity"' . $bm_uri . '>' . $deity['name'] . '</persname>';
					}
				}
			}
		}
		$xml .= '</obverse>';
	}
	//reverse
	if (strlen($row['revLegend']) > 0 || strlen($row['revType']) > 0){
		$xml .= '<reverse>';
		if (strlen($row['revLegend']) > 0){
			$xml .= '<legend scriptCode="Latn">' . trim($row['revLegend']) . '</legend>';
		}
		if (strlen($row['revType']) > 0){
			$xml .= '<type><description xml:lang="en">' . trim($row['revType']) . '</description></type>';
			//deity
			foreach($deities_array as $deity){
				if (strstr($deity['name'], ' ') !== FALSE){
					//haystack is string when the deity is multiple words
					$haystack = strtolower(trim($row['revType']));
					if (strstr($haystack, strtolower($deity['matches'])) !== FALSE) {
						$bm_uri = strlen($deity['bm_uri']) > 0 ? ' xlink:href="' . $deity['bm_uri'] . '"' : '';
						$xml .= '<persname xlink:type="simple" xlink:role="deity"' . $bm_uri . '>' . $deity['name'] . '</persname>';
					}
				} else {
					//haystack is array
					$desc = preg_replace('/[^a-z]+/i', ' ', trim($row['revType']));
					$haystack = explode(' ', $desc);
					if (in_array($deity['matches'], $haystack)){
						$bm_uri = strlen($deity['bm_uri']) > 0 ? ' xlink:href="' . $deity['bm_uri'] . '"' : '';
						$xml .= '<persname xlink:type="simple" xlink:role="deity"' . $bm_uri . '>' . $deity['name'] . '</persname>';
					}
				}
			}
		}
		$xml .= '</reverse>';
	}
	
	$xml .= '</typeDesc></descMeta></nuds>';
	
	return $xml;
	
}

function get_date_textual($year){
	$textual_date = '';
	//display start date
	if($year <= 0){
		$textual_date .= abs($year) . ' B.C.';
	} else {
		if ($year <= 600){
			$textual_date .= 'A.D. ';
		}
		$textual_date .= $year;
	}
	return $textual_date;
}

function get_date($fromDate, $toDate){
	//validate dates, compliant to ISO
	$start_gYear = number_pad($fromDate, 4);
	$end_gYear = number_pad($toDate, 4);

	if ($fromDate == $toDate){
		$node = '<date standardDate="' . $start_gYear . '">' . get_date_textual($fromDate) . '</date>';
	} else {
		$node = '<dateRange><fromDate standardDate="' . $start_gYear . '">' . get_date_textual($fromDate) . '</fromDate><toDate standardDate="' . $end_gYear . '">' . get_date_textual($toDate) . '</toDate></dateRange>';
	}
	return $node;
}

//pad integer value from Filemaker to create a year that meets the xs:gYear specification
function number_pad($number,$n) {
	if ($number > 0){
		$gYear = str_pad((int) $number,$n,"0",STR_PAD_LEFT);
	} elseif ($number < 0) {
		$gYear = '-' . str_pad((int) abs($number),$n,"0",STR_PAD_LEFT);
	}
	return $gYear;
}

//write file
function write_file($xml, $nudsid){
	GLOBAL $errors;
	GLOBAL $processed;
	//load DOMDocument
	$dom = new DOMDocument('1.0', 'UTF-8');
	if ($dom->loadXML($xml) === FALSE){
		echo "{$nudsid} failed to validate.\n";
		$errors[] = $nudsid . ' failed to validate.';
	} else {
		if (!array_search($nudsid, $processed)){
			$processed[] = $nudsid;
		} else {
			$errors[] = $nudsid . ': a duplicate row.';
		}		
		$dom->preserveWhiteSpace = FALSE;
		$dom->formatOutput = TRUE;
		//echo $dom->saveXML() . "\n";
	 		
		$filename = '/home/komet/ans_migration/rrc/nuds/' . $nudsid . '.xml';
		$dom->save($filename);
	
		//put_to_exist($filename, $nudsid);
	}
}

function put_to_exist($filename, $nudsid){
	if (($readFile = fopen($filename, 'r')) === FALSE){
		echo "Unable to read {$nudsid}.xml\n";
	} else {
		//PUT xml to eXist
		$putToExist=curl_init();
		
		//set curl opts
		curl_setopt($putToExist,CURLOPT_URL,'http://localhost:8080/exist/rest/db/ocre/objects/' . $nudsid . '.xml');
		curl_setopt($putToExist,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8"));
		curl_setopt($putToExist,CURLOPT_CONNECTTIMEOUT,2);
		curl_setopt($putToExist,CURLOPT_RETURNTRANSFER,1);
		curl_setopt($putToExist,CURLOPT_PUT,1);
		curl_setopt($putToExist,CURLOPT_INFILESIZE,filesize($filename));
		curl_setopt($putToExist,CURLOPT_INFILE,$readFile);
		curl_setopt($putToExist,CURLOPT_USERPWD,"admin:");
		$response = curl_exec($putToExist);

		$http_code = curl_getinfo($putToExist,CURLINFO_HTTP_CODE);
	
		//error and success logging
		if (curl_error($putToExist) === FALSE){
			echo "{$nudsid} failed to write to eXist.\n";
		}
		else {
			if ($http_code == '201'){
			echo "{$nudsid} written.\n";
			}
		}
		//close eXist curl
		curl_close($putToExist);
		
		//close files and delete from /tmp
		fclose($readFile);
		//unlink($filename);
	}
}

function processUri($uri, $concept, $isUncertain){
	GLOBAL $nomismaUris;
	$uri = trim($uri);
	$certainty = $isUncertain == true ? ' certainty="uncertain"' : '';

	if (in_array($uri, $nomismaUris)){
			if ($concept == 'authority' || $concept == 'deity' || $concept == 'issuer' || $concept == 'portrait'){
				$node = '<persname xlink:type="simple" xlink:role="' . $concept . '" xlink:href="' . $uri . '"' . $certainty . '>' . array_search($uri, $nomismaUris) . '</persname>';
			} elseif ($concept == 'mint' || $concept == 'region'){
				$node = '<geogname xlink:type="simple" xlink:role="' . $concept . '" xlink:href="' . $uri . '"' . $certainty . '>' . array_search($uri, $nomismaUris) . '</geogname>';
			} else {
				$node = '<' . $concept . ' xlink:type="simple" xlink:href="' . $uri . '"' . $certainty . '>' . array_search($uri, $nomismaUris) . '</' . $concept . '>';
			}
			
	} else {
		$pieces = explode('/', $uri);
		$id = $pieces[4];
		if (strlen($id) > 0){
			$xmlDoc = new DOMDocument();
			$xmlDoc->load('http://nomisma.org/id/' . $id . '.rdf');
			$xpath = new DOMXpath($xmlDoc);
			$xpath->registerNamespace('skos', 'http://www.w3.org/2004/02/skos/core#');
			$prefLabels = $xpath->query("descendant::skos:prefLabel[@xml:lang='en']");
			$nomismaUris[$prefLabels->item(0)->nodeValue] = $uri;
	
			if ($concept == 'authority' || $concept == 'deity' || $concept == 'issuer' || $concept == 'portrait'){
				$node = '<persname xlink:type="simple" xlink:role="' . $concept . '" xlink:href="' . $uri . '"' . $certainty . '>' . $prefLabels->item(0)->nodeValue . '</persname>';
			} elseif ($concept == 'mint' || $concept == 'region'){
				$node = '<geogname xlink:type="simple" xlink:role="' . $concept . '" xlink:href="' . $uri . '"' . $certainty . '>' . $prefLabels->item(0)->nodeValue . '</geogname>';
			} else {
				$node = '<' . $concept . ' xlink:type="simple" xlink:href="' . $uri . '"' . $certainty . '>' . $prefLabels->item(0)->nodeValue . '</' . $concept . '>';
			}
		}
	}
	return $node;
}

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