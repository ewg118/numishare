<?php 

$data = generate_json('/home/komet/ans_migration/ocre/13.csv');
$deities_array = generate_json('deities.csv');
$nomismaUris = array();
$errors = array();
$records = array();
$processed = array();

foreach ($data as $row){
	echo "Processing {$row['Nomisma.org id']}\n";
	$records[] = trim($row['Nomisma.org id']);
	$xml = generate_nuds($row);
	//write file
	write_file($xml, trim($row['Nomisma.org id']));
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

/*foreach ($records as $record){
	if (!array_search($record, $processed)){
		echo "Not found: {$record}\n";
	}
}*/

echo count($records) . " records\n";
echo count($processed) . " processed\n";
echo count($errors) . " errors\n";

foreach ($errors as $error){
	echo "Error: {$error}\n";
}
//$fileName = '/tmp/' . $nudsid . '.xml';



/****** GENERATE NUDS ******/
function generate_nuds($row){
	GLOBAL $deities_array;
	$nudsid = trim($row['Nomisma.org id']);
	$pieces = explode('.', $nudsid);
	//develop date
	
	if (strlen($row['From Date']) > 0 && strlen($row['To Date']) > 0){
			$date = get_date($row['From Date'], $row['To Date']);
	}

	//control
	$xml = '<?xml version="1.0" encoding="UTF-8"?><nuds xmlns="http://nomisma.org/nuds" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" recordType="conceptual">';
	$xml .= "<control><recordId>{$nudsid}</recordId>";
	
	//insert otherRecordId if necessary; ignore for m_aur and com
	/*if ($pieces[2] != 'com' && $pieces[2] != 'm_aur'){
		$xml .= get_other_ids($nudsid);
	}*/
	
	//handle subtypes
	if (isset($pieces[4])){
		$new = array_slice($pieces, 0, 4);		
		$xml .= '<otherRecordId semantic="skos:broader">' . implode('.', $new) . '</otherRecordId>';
		$xml .= '<publicationStatus>appprovedSubtype</publicationStatus>';
	} else {
		$xml .= '<publicationStatus>approved</publicationStatus>';
	}
	
	$xml .= '<maintenanceAgency><agencyName>American Numismatic Society</agencyName></maintenanceAgency>';
	$xml .= '<maintenanceStatus>derived</maintenanceStatus>';
	$xml .= '<maintenanceHistory><maintenanceEvent>';
	$xml .= '<eventType>derived</eventType><eventDateTime standardDateTime="' . date(DATE_W3C) . '">' . date(DATE_RFC2822) . '</eventDateTime><agentType>machine</agentType><agent>PHP</agent><eventDescription>Generated from OCRE CSV.</eventDescription>';
	$xml .= '</maintenanceEvent></maintenanceHistory>';
	$xml .= '<rightsStmt><copyrightHolder>American Numismatic Society</copyrightHolder><license xlink:type="simple" xlink:href="http://opendatacommons.org/licenses/odbl/"/></rightsStmt>';
	$xml .= '<semanticDeclaration><prefix>dcterms</prefix><namespace>http://purl.org/dc/terms/</namespace></semanticDeclaration>';
	$xml .= '<semanticDeclaration><prefix>skos</prefix><namespace>http://www.w3.org/2004/02/skos/core#</namespace></semanticDeclaration>';
	$xml .= "</control>";
	$xml .= '<descMeta>';
	
	/***** TITLE *****/
	$title = get_title($nudsid);	
	$xml .= '<title xml:lang="en">' . $title . '</title>';
	$xml .= '<typeDesc>';	
	//date
	$xml .= $date;
	//objectType
	if (strlen($row['Object Type URI']) > 0){
		$vals = explode('|', $row['Object Type URI']);
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
	if (strlen($row['Denomination URI']) > 0){
		$vals = explode('|', $row['Denomination URI']);
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
	if (strlen($row['Material URI']) > 0){
		$vals = explode('|', $row['Material URI']);
		foreach ($vals as $val){
			if (substr($val, -1) == '?'){
				$uri = substr($val, 0, -1);
				if ($uri == 'http://nomisma.org/id/orichalcum' || $uri == 'http://nomisma.org/id/cu'){
					$uri = 'http://nomisma.org/id/ae';
				}
				$xml .= processUri($uri, 'material', true);
			} else {
				if ($val == 'http://nomisma.org/id/orichalcum' || $val == 'http://nomisma.org/id/cu'){
					$uri = 'http://nomisma.org/id/ae';
				} else {
					$uri = $val;
				}
				$xml .= processUri($uri, 'material', false);
			}
		}
	}
	//authority
	$xml .= '<authority>';
	$vals = explode('|', $row['Authority URI']);
	foreach ($vals as $val){
		if (substr($val, -1) == '?'){
			$uri = substr($val, 0, -1);
			$xml .= processUri($uri, 'authority', true);
		} else {
			$uri = $val;
			$xml .= processUri($uri, 'authority', false);
		}
	}
	if (array_key_exists('Issuer URI',$row)){
		if (strlen($row['Issuer URI']) > 0){
			$vals = explode('|', $row['Issuer URI']);
			foreach ($vals as $val){
				if (substr($val, -1) == '?'){
					$uri = substr($val, 0, -1);
					$xml .= processUri($uri, 'issuer', true);
				} else {
					$uri = $val;
					$xml .= processUri($uri, 'issuer', false);
				}
			}
		}
	}
	
	$xml .= '</authority>';
	
	//geography
	if (strlen($row['Mint URI']) > 0 || strlen($row['New Region URI']) > 0){
		$xml .= '<geographic>';
		if (strlen($row['Mint URI']) > 0){
			$vals = explode('|', $row['Mint URI']);
			foreach ($vals as $val){
				if (substr($val, -1) == '?'){
					$uri = substr($val, 0, -1);
					$xml .= processUri($uri, 'mint', true);
				} else {
					$uri = $val;
					$xml .= processUri($uri, 'mint', false);
				}
			}
		}
		if (strlen($row['New Region URI']) > 0){
			$vals = explode('|', $row['New Region URI']);
			foreach ($vals as $val){
				if (substr($val, -1) == '?'){
					$uri = substr($val, 0, -1);
					$xml .= processUri($uri, 'region', true);
				} else {
					$uri = $val;
					$xml .= processUri($uri, 'region', false);
				}
			}
		}
		$xml .= '</geographic>';
	}
	
	//obverse
	if (strlen($row['Obverse Type']) > 0 || strlen($row['Obverse Legend']) > 0 || strlen($row['Obverse Portrait URI']) > 0){
		$xml .= '<obverse>';
		if (strlen($row['Obverse Legend']) > 0){
			$xml .= '<legend scriptCode="Latn">' . trim($row['Obverse Legend']) . '</legend>';
		}
		if (strlen($row['Obverse Type']) > 0){
			$xml .= '<type><description xml:lang="en">' . trim($row['Obverse Type']) . '</description></type>';
		}
		if (strlen($row['Obverse Portrait URI']) > 0){
			$vals = explode('|', $row['Obverse Portrait URI']);
			foreach ($vals as $val){
				if (strstr($val, 'http://') == true){
					$xml .= processUri($val, 'portrait', false);
				} else {
					$xml .= '<persname xlink:type="simple" xlink:role="portrait">' . $val . '</persname>';
				}
			}
		}
		if (strlen($row['Obverse Deity']) > 0){
			$vals = explode('|', $row['Obverse Deity']);
			foreach ($vals as $val){
				if (substr($val, -1) == '?'){
					$val = substr($val, 0, -1);
					$deity_uri = '';
					foreach($deities_array as $deity){
						if ($deity['OCRE Value'] == $val) {
							if (strlen($deity['BM URI']) > 0){
								$deity_uri = ' xlink:href="' . $deity['BM URI'] . '"';
							}
							if (strlen($deity['Should be']) > 0){
								$val = $deity['Should be'];
							}
						}
					}
					if ($val != '[delete]'){
						$xml .= '<persname xlink:type="simple" xlink:role="deity" certainty="uncertain"' . $deity_uri . '>' . trim($val) . '</persname>';
					}					
				} else {
					$deity_uri = '';
					foreach($deities_array as $deity){
						if ($deity['OCRE Value'] == $val) {
							if (strlen($deity['BM URI']) > 0){
								$deity_uri = ' xlink:href="' . $deity['BM URI'] . '"';
							}
							if (strlen($deity['Should be']) > 0){
								$val = $deity['Should be'];
							}
						}
					}
					if ($val != '[delete]'){
						$xml .= '<persname xlink:type="simple" xlink:role="deity"' . $deity_uri . '>' . trim($val) . '</persname>';
					}
				}
			}
		}
		
		//obverse control mark
		if (strlen($row['Control Mark']) > 0){
			$xml .= '<symbol localType="controlMark">' . $row['Control Mark'] . '</symbol>';
		}
		$xml .= '</obverse>';
	}
	//reverse
	if (strlen($row['Reverse Type']) > 0 || strlen($row['Reverse Legend']) > 0 || strlen($row['Reverse Portrait URI']) > 0){
		$xml .= '<reverse>';
		if (strlen($row['Reverse Legend']) > 0){
			$xml .= '<legend scriptCode="Latn">' . trim($row['Reverse Legend']) . '</legend>';
		}
		if (strlen($row['Reverse Type']) > 0){
			$xml .= '<type><description xml:lang="en">' . trim($row['Reverse Type']) . '</description></type>';
		}
		if (strlen($row['Reverse Portrait URI']) > 0){
			$vals = explode('|', $row['Reverse Portrait URI']);
			foreach ($vals as $val){
				if (strstr($val, 'http://') == true){
					$xml .= processUri($val, 'portrait', false);
				} else {
					$xml .= '<persname xlink:type="simple" xlink:role="portrait">' . $val . '</persname>';
				}
			}
		}
	if (strlen($row['Reverse Deity']) > 0){
			$vals = explode('|', $row['Reverse Deity']);
			foreach ($vals as $val){
				if (substr($val, -1) == '?'){
					$val = substr($val, 0, -1);
					$deity_uri = '';
					foreach($deities_array as $deity){
						if ($deity['OCRE Value'] == $val) {
							if (strlen($deity['BM URI']) > 0){
								$deity_uri = ' xlink:href="' . $deity['BM URI'] . '"';
							}
							if (strlen($deity['Should be']) > 0){
								$val = $deity['Should be'];
							}
						}
					}
					if ($val != '[delete]'){
						$xml .= '<persname xlink:type="simple" xlink:role="deity" certainty="uncertain"' . $deity_uri . '>' . trim($val) . '</persname>';
					}
				} else {
					$deity_uri = '';
					foreach($deities_array as $deity){
						if ($deity['OCRE Value'] == $val) {
							if (strlen($deity['BM URI']) > 0){
								$deity_uri = ' xlink:href="' . $deity['BM URI'] . '"';
							}
							if (strlen($deity['Should be']) > 0){
								$val = $deity['Should be'];
							}
						}
					}
					if ($val != '[delete]'){
						$xml .= '<persname xlink:type="simple" xlink:role="deity"' . $deity_uri . '>' . trim($val) . '</persname>';
					}					
				}
			}
		}
		if (strlen($row['Mint Mark(s) Left']) > 0){
			$xml .= '<symbol position="left">' . $row['Mint Mark(s) Left'] . '</symbol>';
		}
		if (strlen($row['Mint Mark(s) Center']) > 0){
			$xml .= '<symbol position="center">' . $row['Mint Mark(s) Center'] . '</symbol>';
		}
		if (strlen($row['Mint Mark(s) Right']) > 0){
			$xml .= '<symbol position="right">' . $row['Mint Mark(s) Right'] . '</symbol>';
		}
		if (strlen($row['Mint Mark(s) Exergue']) > 0){
			$xml .= '<symbol position="exergue">' . $row['Mint Mark(s) Exergue'] . '</symbol>';
		}
		$xml .= '</reverse>';
	}
	
	$xml .= '</typeDesc></descMeta></nuds>';
	
	return $xml;
	
}

function get_date_textual($year){
	$textual_date = '';
	//display start date
	if ($year != 0){
		if($year < 0){
			$textual_date .= abs($year) . ' BC';
		} else {
			if ($year <= 600){
				$textual_date .= 'AD ';
			}
			$textual_date .= $year;
		}
	}
	return $textual_date;
}

function get_date($fromDate, $toDate){
	//validate dates, compliant to ISO
	if ($fromDate < 0){
		$start_gYear = number_pad($fromDate + 1, 4);
	} else {
		$start_gYear = number_pad($fromDate, 4);
	}
	if ($toDate < 0){
		$end_gYear = number_pad($toDate + 1, 4);
	} else {
		$end_gYear = number_pad($toDate, 4);
	}

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

function get_title($nudsid){
	$pieces = explode('.', $nudsid);
	switch ($pieces[1]) {
		case '1':
			$vol = 'I';
			break;
		case '1(2)':
			$vol = 'I (second edition)';
			break;
		case '2':
			$vol = 'II';
			break;
		case '2_1(2)':
			$vol = 'II, Part 1 (second edition)';
			break;
		case '3':
			$vol = 'III';
			break;
		case '4':
			$vol = 'IV';
			break;
	}
	
	switch ($pieces[2]) {
		case 'aug':
			$auth = 'Augustus';
			break;
		case 'tib':
			$auth = 'Tiberius';
			break;
		case 'gai':
			$auth = 'Gaius/Caligula';
			break;
		case 'cl':
			$auth = 'Claudius';
			break;
		case 'ner':
			if ($pieces[1] == '1(2)'){
				$auth = 'Nero';
			} else if ($pieces[1] == '2'){
				$auth = 'Nerva';
			}
			break;
		case 'clm':
			$auth = 'Clodius Macer';
			break;
		case 'cw':
			$auth = 'Civil Wars';
			break;
		case 'gal':
			$auth = 'Galba';
			break;
		case 'ot':
			$auth = 'Otho';
			break;
		case 'vit':
			$auth = 'Vitellius';
			break;
		case 'ves':
			$auth = 'Vespasian';
			break;
		case 'tit':
			$auth = 'Titus';
			break;
		case 'dom':
			$auth = 'Domitian';
			break;
		case 'anys':
			$auth = 'Anonymous';
			break;
		case 'tr':
			$auth = 'Trajan';
			break;
		case 'hdn':
			$auth = 'Hadrian';
			break;
		case 'ant':
			$auth = 'Antoninus Pius';
			break;
		case 'm_aur':
			$auth = 'Marcus Aurelius';
			break;
		case 'com':
			$auth = 'Commodus';
			break;
		case 'pert':
			$auth = 'Pertinax';
			break;
		case 'dj':
			$auth = 'Didius Julianus';
			break;
		case 'pn':
			$auth = 'Pescennius Niger';
			break;
		case 'ca':
			$auth = 'Clodius Albinus';
			break;
		case 'ss':
			$auth = 'Septimius Severus';
			break;
		case 'crl':
			$auth = 'Caracalla';
			break;
		case 'ge':
			$auth = 'Geta';
			break;
		case 'mcs':
			$auth = 'Macrinus';
			break;
		case 'el':
			$auth = 'Elagabalus';
			break;
		case 'sa':
			$auth = 'Severus Alexander';
			break;
		case 'max_i':
			$auth = 'Maximinus Thrax';
			break;
		case 'pa':
			$auth = 'Caecilia Paulina';
			break;
		case 'mxs':
			$auth = 'Maximus';
			break;
		case 'gor_i':
			$auth = 'Gordian I';
			break;
		case 'gor_ii':
			$auth = 'Gordian II';
			break;
		case 'balb':
			$auth = 'Balbinus';
			break;
		case 'pup':
			$auth = 'Pupienus';
			break;
		case 'gor_iii_caes':
			$auth = 'Gordian III (Caesar)';
			break;
		case 'gor_iii':
			$auth = 'Gordian III';
			break;
		case 'ph_i':
			$auth = 'Philip I';
			break;
		case 'pac':
			$auth = 'Pacatianus';
			break;
		case 'jot':
			$auth = 'Jotapianus';
			break;
		case 'mar_s':
			$auth = 'Mar. Silbannacus';
			break;
		case 'spon':
			$auth = 'Sponsianus';
			break;
		case 'tr_d':
			$auth = 'Trajan Decius';
			break;
		case 'tr_g':
			$auth = 'Trebonianus Gallus';
			break;
		case 'vo':
			$auth = 'Volusian';
			break;
		case 'aem':
			$auth = 'Aemilian';
			break;
		case 'uran_ant':
			$auth = 'Uranius Antoninus';
			break;
	}
	
	if (strpos($pieces[3], '_') === FALSE){
		$num = $pieces[3];
	} else {
		$tokens = explode('_', $pieces[3]);
		$num = $tokens[0];
		unset($tokens[0]);
		$num .= ' (' . implode(' ', $tokens) . ')';
	}
	
	//subtypes
	$subtype = '';
	if (isset($pieces[4])){
		$subtype = ': Subtype ' . $pieces[4];
	}
	
	$title = 'RIC ' . $vol . ' ' . $auth . ' ' . $num . $subtype;
	return $title;	
}

//process $nudsid to derive otherRecordId from OCRE version 1
function get_other_ids($nudsid){
	GLOBAL $errors;
	$pieces = explode('.', $nudsid);	
	$result = '';
	//check if split by means of duplicate denominations
	if (strstr($pieces[3], '_')){
		$num = strstr($pieces[3], '_', true);
		//if $num is an integer, return integer, otherwise check if lowercase id is a valid OCRE URI.
		if (is_numeric($num)){
			$pieces[3] = $num;
			$old_id =  implode('.', $pieces);
			$result = '<otherRecordId semantic="dcterms:replaces">' . $old_id . '</otherRecordId>';
			//deprecate old ID
			deprecate_id($old_id, $nudsid, 'cancelledSplit');
		} else {
			$pieces[3] = strtolower($num);
			$old_id =  implode('.', $pieces);
			$url = 'http://numismatics.org/ocre/id/' . $old_id;
			$file_headers = @get_headers($url);
			//first try lowercasing the ID
			if ($file_headers[0] == 'HTTP/1.1 200 OK'){
				$result = '<otherRecordId semantic="dcterms:replaces">' . $old_id . '</otherRecordId>';
				//deprecate old ID
				deprecate_id($old_id, $nudsid, 'cancelledSplit');
			} else {
					//if the lowercase ID is not found, trim the last letter and try again (mainly for variants)
				$pieces[3] = strtolower(substr($num, 0, strlen($num) - 1));
				$old_id =  implode('.', $pieces);
				$url = 'http://numismatics.org/ocre/id/' . $old_id;
				$file_headers = @get_headers($url);
				if ($file_headers[0] == 'HTTP/1.1 200 OK'){
					$result = '<otherRecordId semantic="dcterms:replaces">' . $old_id . '</otherRecordId>';
					//deprecate old ID
					deprecate_id($old_id, $nudsid, 'cancelledSplit');
				}
				else {
					echo $old_id . " not found.\n";
					$errors[] = $nudsid . ': old URI not found - ' . $old_id;
				}
			}
		}
	} else {
		//if the type has not been split by denomination
		$num = $pieces[3];
		if (is_numeric($num) || strtolower($num) == $num){
			//if $num is identical to previous id number, in integer or lower case number
			return $result;
		} else {
			//if $num is not an integer, check whether the lower-cased $num OCRE URI exists
			$pieces[3] = strtolower($num);
			$old_id = implode('.', $pieces);
			$url = 'http://numismatics.org/ocre/id/' . $old_id;
			$file_headers = @get_headers($url);
			//first try lowercasing the ID
			if ($file_headers[0] == 'HTTP/1.1 200 OK'){				
				$result = '<otherRecordId semantic="dcterms:replaces">' . $old_id . '</otherRecordId>';
				//deprecate old ID
				deprecate_id($old_id, $nudsid, 'cancelledReplaced');
			} else {
				//if the lowercase ID is not found, trim the last letter and try again (mainly for variants)
				$pieces[3] = strtolower(substr($num, 0, strlen($num) - 1));
				$old_id = implode('.', $pieces);
				$url = 'http://numismatics.org/ocre/id/' . $old_id;
				$file_headers = @get_headers($url);
				if ($file_headers[0] == 'HTTP/1.1 200 OK'){
					$result = '<otherRecordId semantic="dcterms:replaces">' . $old_id . '</otherRecordId>';
					//deprecate old ID
					deprecate_id($old_id, $nudsid, 'cancelledReplaced');
				} else {
					echo $old_id . " not found.\n";
					$errors[] = $nudsid . ': old URI not found - ' . $old_id;
				}
			}
		}		
	}
	return $result;
}

function deprecate_id($old_id, $nudsid, $status){	
	GLOBAL $errors;
	$filename = '/home/komet/ans_migration/ocre/old/' . $old_id . '.xml';
	if ($handle = fopen($filename, "r") !== FALSE){
		$xml = file_get_contents($filename);
		
		$maintenanceEvent = '<maintenanceEvent><eventType>' . $status . '</eventType>' .
				'<eventDateTime standardDateTime="' . date(DATE_W3C) . '">' . date(DATE_RFC2822) . '</eventDateTime>' .
				'<agentType>machine</agentType><agent>PHP</agent><eventDescription>URI cancelled and replaced following OCRE renumbering.</eventDescription>' .
				'</maintenanceEvent>';
		$publicationStatus = "<publicationStatus>inProcess</publicationStatus>";
		$semanticDeclaration = '<semanticDeclaration><prefix>dcterms</prefix><namespace>http://purl.org/dc/terms/</namespace></semanticDeclaration>';
		$maintenanceStatus = "<maintenanceStatus>{$status}</maintenanceStatus>";
		$otherRecordId = '<otherRecordId semantic="dcterms:isReplacedBy">' . $nudsid . '</otherRecordId>'; 
		
		//first add in maintenanceEvent if there isn't already one
		if (strpos($xml, 'cancelled') === FALSE){
			$xml = str_replace('</maintenanceHistory>', $maintenanceEvent . '</maintenanceHistory>', $xml);
		}
		//change publicationStatus
		$xml = str_replace('<publicationStatus>approved</publicationStatus>', $publicationStatus, $xml);
		//add semanticDeclaration if it doesn't exist in the file.
		if (strpos($xml, 'semanticDeclaration') === FALSE){
			$xml = str_replace('</rightsStmt>', '</rightsStmt>' . $semanticDeclaration, $xml);
		}		
		//set maintenanceStatus
		$xml = str_replace('<maintenanceStatus>revised</maintenanceStatus>', $maintenanceStatus, $xml);
		//insert otherRecordId if it hasn't already
		if (strpos($xml, $nudsid . '</otherRecordId>') === FALSE) {
			$xml = str_replace('</recordId>', '</recordId>' . $otherRecordId, $xml);
		}
		
		//write_file($xml, $old_id);
		$dom = new DOMDocument('1.0', 'UTF-8');
		$dom->preserveWhiteSpace = FALSE;
		$dom->formatOutput = TRUE;
		if ($dom->loadXML($xml) === FALSE){
			echo "Deprecated {$old_id}.xml failed to validate.\n";
			$errors[] = "Deprecated {$old_id}.xml failed to validate.";
		} else {			
			$dom->save($filename);
			put_to_exist($filename, $old_id);
		}
	} else {
		echo "Deprecated {$old_id}.xml failed to load.\n";
		$errors[] = "Deprecated {$old_id}.xml failed to load.";
	}
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
	 		
		$filename = '/home/komet/ans_migration/ocre/new/' . $nudsid . '.xml';
		$dom->save($filename);
	
		put_to_exist($filename, $nudsid);
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