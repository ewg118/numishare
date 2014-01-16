<?php
/************************
 AUTHOR: Ethan Gruber
MODIFIED: August, 2012
DESCRIPTION: Convert Egyptian National Collection spreadsheet to NUDS
REQUIRED LIBRARIES: php5, php5-curl, php5-cgi
************************/

$errors = array();

//create an array with pre-defined labels and values passed from the Filemaker POST
$data = generate_json('/home/komet/ans_migration/egypt/data.csv');

foreach ($data as $row){
	echo "Processing {$row['Cat. Num']}\n";
	$xml = generate_nuds($row);
	//write file
	write_file($xml, $row['Cat. Num']);
}

var_dump ($errors);

/****** GENERATE NUDS ******/
function generate_nuds($row){
	$nudsid = $row['Cat. Num'];
	//array of cleaned labels for title elements
	$title_elements = array();
	
	$startdate_int = trim($row['From CE date']) * 1;
	$enddate_int = trim($row['To CE date']) * 1;
	if (trim($row['From CE date']) != '' || trim($row['To CE date']) != ''){
		$fromDate_textual = get_date_textual($startdate_int);
		$toDate_textual = get_date_textual($enddate_int);
		$date_textual = $fromDate_textual . (strlen($fromDate_textual) > 0 && strlen($toDate_textual) > 0 ? '-' : '' ) . $toDate_textual;
		$date = get_date($startdate_int, $enddate_int, $date_textual, $fromDate_textual, $toDate_textual);
	}

	switch (trim($row['Type of object e.g. Coin, die, etc.'])) {
		case 'Coin':
			$objtype = 'Coin';
			$objtype_uri = 'http://nomisma.org/id/coin';
			break;
		case 'Medals':
			$objtype = 'Medal';
			$objtype_uri = 'http://nomisma.org/id/medal';
			break;
		default:
			$objtype = trim($row['Type of object e.g. Coin, die, etc.']);
			$objtype_uri = '';
	}

	//control
	$xml = '<?xml version="1.0" encoding="UTF-8"?><nuds xmlns="http://nomisma.org/nuds" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mets="http://www.loc.gov/METS/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" recordType="physical">';
	$xml .= "<control><recordId>{$nudsid}</recordId>";
	$xml .= '<publicationStatus>approved</publicationStatus>';
	$xml .= '<maintenanceAgency><agencyName>American Numismatic Society</agencyName></maintenanceAgency>';
	$xml .= '<maintenanceStatus>derived</maintenanceStatus>';
	$xml .= '<maintenanceHistory><maintenanceEvent>';
	$xml .= '<eventType>derived</eventType><eventDateTime standardDateTime="' . date(DATE_W3C) . '">' . date(DATE_RFC2822) . '</eventDateTime><agentType>machine</agentType><agent>PHP</agent><eventDescription>Generated from Egypt CSV.</eventDescription>';
	$xml .= '</maintenanceEvent></maintenanceHistory>';
	$xml .= '<rightsStmt><copyrightHolder>American Numismatic Society</copyrightHolder><license xlink:type="simple" xlink:href="http://opendatacommons.org/licenses/odbl/"/></rightsStmt>';
	$xml .= '<semanticDeclaration><prefix>dcterms</prefix><namespace>http://purl.org/dc/terms/</namespace></semanticDeclaration>';
	$xml .= "</control>";
	$xml .= '<descMeta>';

	/************ typeDesc ***************/
	$xml .= '<typeDesc>';

	//fill in other typeDesc metadata
	if (strlen($objtype_uri) > 0){
		$xml .= '<objectType xlink:type="simple" xlink:href="' . $objtype_uri . '">' . $objtype . '</objectType>';
	} else {
		$xml .= '<objectType>' . $objtype . '</objectType>';
	}	
	
	//date
	if (strlen($date) > 0){
		$xml .= $date;
	}
	//material
	if (strlen($row['Metal']) > 0){
		switch (trim($row['Metal'])) {
			case 'Copper':
				$xml .= '<material xlink:type="simple" xlink:href="http://nomisma.org/id/cu">' . $row['Metal'] . '</material>';
				break;
			case 'Silver':
				$xml .= '<material xlink:type="simple" xlink:href="http://nomisma.org/id/ar">' . $row['Metal'] . '</material>';
				break;
			case 'Gold':
				$xml .= '<material xlink:type="simple" xlink:href="http://nomisma.org/id/av">' . $row['Metal'] . '</material>';
				break;
			default:
				$xml .= "<material>{$row['Metal']}</material>";
		}
		
		//insert material
		$title_elements['material'] = $row['Metal'];
	}
	
	if (strlen(trim($row['Inscription on medal - obverse'])) > 0){
		$xml .= '<obverse><legend>' . str_replace('&', '&amp;', trim($row['Inscription on medal - obverse'])) . '</legend></obverse>';
	}
	
	if (strlen(trim($row['Inscription on medals - reverse'])) > 0){
		$xml .= '<reverse><legend>' . str_replace('&', '&amp;', trim($row['Inscription on medals - reverse'])) . '</legend></reverse>';
	}

	/***** GEOGRAPHICAL LOCATIONS *****/
	if (strlen(trim($row['Mint: modern name'])) > 0){
		$val = trim($row['Mint: modern name']);
		$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
		$geonames = strlen($row['geoname number']) > 0 ? ' xlink:href="http://www.geonames.org/' . $row['geoname number'] . '"'  : '';
		$xml .= '<geographic>';
		$xml .= '<geogname xlink:type="simple" xlink:role="mint"' . $geonames . $certainty . '>' . trim(str_replace('?', '', $val)) . '</geogname>';	
		$xml .= '</geographic>';
	}

	/***** AUTHORITIES AND PERSONS *****/
	if (strlen($row['Dynasty or Country']) > 0 || strlen($row['Ruler']) > 0){
		$xml .= '<authority>';
		//ruler
		if (strlen(trim($row['Ruler'])) > 0){
			$val = trim(str_replace('"', '', $row['Ruler']));
			$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
			$xml .= '<persname xlink:type="simple" xlink:role="authority"' . $certainty . '>' . trim(str_replace('?', '', $val)) . '</persname>';		
			$title_elements['issuer'] = trim(str_replace('?', '', $val));
		}
		//dynasty
		if (strlen(trim($row['Dynasty or Country'])) > 0){
			$val = trim(str_replace('"', '', $row['Dynasty or Country']));
			$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
			$xml .= '<famname xlink:type="simple" xlink:role="dynasty"' . $certainty . '>' . trim(str_replace('?', '', $val)) . '</famname>';
		}	
		$xml .= '</authority>';
	}
	$xml .= '</typeDesc>';

	/***** PHYSICAL DESCRIPTION *****/
	$xml .= '<physDesc>';

	//axis: only create if it's an integer
	/*$axis = (int) $row['axis'];
	if (is_int($axis) && $axis <= 12){
		$xml .= '<axis>' . $axis . '</axis>';
	} elseif((strlen($axis) > 0 && !is_int($axis)) || $axis > 12){
		$warnings[] = 'Line ' . $row . ': ' . $accnum . ' (' . $department . ') has non-integer axis or value exceeding 12.';
	}*/
	//dob
	if (strlen(trim($row['AH date'])) > 0){
		$dob = $row['AH date'];
		$xml .= '<dateOnObject><date calendar="ah"' . (is_int( (int) $dob) ? ' standardDate="' . number_pad($dob, 4) . '"' : '') . '>' . $dob . '</date></dateOnObject>';
	}
	if (strlen(trim($row['Non-AH date'])) > 0){
		$dob = $row['Non-AH date'];
		$xml .= '<dateOnObject><date' . (is_int( (int) $dob) ? ' standardDate="' . number_pad($dob, 4) . '"' : '') . '>' . $dob . '</date></dateOnObject>';
	}
	//create measurementsSet, if applicable
	if ((is_numeric(trim($row['Weight in gr.'])) && trim($row['Weight in gr.']) > 0) || (is_numeric(trim($row['Diameter in mm.'])) && trim($row['Diameter in mm.']) > 0)){
		$xml .= '<measurementsSet>';
		//weight
		$weight = trim($row['Weight in gr.']);
		if (is_numeric($weight) && $weight > 0){
			$xml .= '<weight units="g">' . $weight . '</weight>';
		}
		//diameter
		$diameter = trim($row['Diameter in mm.']);
		if (is_numeric($diameter) && $diameter > 0){
			$xml .= '<diameter units="mm">' . $diameter . '</diameter>';
		}
		$xml .= '</measurementsSet>';
	}
	$xml .= '</physDesc>';

	/***** ADMINSTRATIVE DESCRIPTION *****/
	$xml .= '<adminDesc>';
	$xml .= '<identifier>' . $row['Registration number'] . '</identifier>';
	$xml .= '<collection>Egyptian National Library</collection>';
	$xml .= '</adminDesc>';

	/***** BIBLIOGRAPHIC DESCRIPTION *****/
	if (strlen(trim($row['Khedieval cat number'])) > 0 || strlen(trim($row['Reverence in 1982 catalog']))){
		$xml .= '<refDesc>';
		if (strlen(trim($row['Khedieval cat number'])) > 0){
			$xml .= '<reference>' . trim($row['Khedieval cat number']) . '</reference>';
		}
		if (strlen(trim($row['Reverence in 1982 catalog'])) > 0){
			$xml .= '<citation>' . str_replace('&', '&amp;', trim($row['Reverence in 1982 catalog'])) . '</citation>';
		}
		$xml .= '</refDesc>';
	}

	/***** TITLE *****/
	$title = '';
	if (array_key_exists('material', $title_elements)){
		$title .= $title_elements['material'];
	}
	$title .= ' ' . $objtype;
	if (array_key_exists('issuer', $title_elements)){
		$title .= ' of ' .  $title_elements['issuer'];
	}
	if (array_key_exists('location', $title_elements)){
		$title .= ', ' . $title_elements['location'];
	}
	if (strlen($date_textual) > 0){
		$title .= ', ';
		$title .= $date_textual;
	}
	$title .= '. ' . $nudsid;

	$xml .= '<title xml:lang="en">' . $title . '</title>';
	$xml .= '</descMeta>';

	/***** IMAGES *****/
	$xml .= '<digRep><mets:fileSec>';
	$xml .= '<mets:fileGrp USE="obverse">';
	$xml .= '<mets:file USE="reference" MIMETYPE="image/jpeg"><mets:FLocat LOCTYPE="URL" xlink:href="media/reference/' . $nudsid . '_obv.jpg"/></mets:file>';
	$xml .= '<mets:file USE="thumbnail" MIMETYPE="image/jpeg"><mets:FLocat LOCTYPE="URL" xlink:href="media/thumbnail/' . $nudsid . '_obv.jpg"/></mets:file>';
	$xml .= '</mets:fileGrp>';
	$xml .= '<mets:fileGrp USE="reverse">';
	$xml .= '<mets:file USE="reference" MIMETYPE="image/jpeg"><mets:FLocat LOCTYPE="URL" xlink:href="media/reference/' . $nudsid . '_rev.jpg"/></mets:file>';
	$xml .= '<mets:file USE="thumbnail" MIMETYPE="image/jpeg"><mets:FLocat LOCTYPE="URL" xlink:href="media/thumbnail/' . $nudsid . '_rev.jpg"/></mets:file>';
	$xml .= '</mets:fileGrp>';
	$xml .= '<mets:fileGrp USE="legend">';
	$xml .= '<mets:file USE="reference" MIMETYPE="image/jpeg"><mets:FLocat LOCTYPE="URL" xlink:href="media/reference/' . $nudsid . '_legend.jpg"/></mets:file>';
	$xml .= '</mets:fileGrp>';
	$xml .= '</mets:fileSec></digRep>';
	
	//close nuds
	$xml .= '</nuds>';

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

function get_date($startdate, $enddate, $date_textual, $fromDate_textual, $toDate_textual){

	//validate dates
	if ($startdate != 0 && is_int($startdate) && $startdate < 3000 ){
		$start_gYear = number_pad($startdate, 4);
	}
	if ($enddate != 0 && is_int($enddate) && $enddate < 3000 ){
		$end_gYear = number_pad($enddate, 4);
	}

	if ($startdate == 0 && $enddate != 0){
		$node = '<date' . (strlen($end_gYear) > 0 ? ' standardDate="' . $end_gYear . '"' : '') . '>' . $date_textual . '</date>';
	} elseif ($startdate != 0 && $enddate == 0) {
		$node = '<date' . (strlen($start_gYear) > 0 ? ' standardDate="' . $start_gYear . '"' : '') . '>' . $date_textual . '</date>';
	} elseif ($startdate == $enddate){
		$node = '<date' . (strlen($end_gYear) > 0 ? ' standardDate="' . $end_gYear . '"' : '') . '>' . $date_textual . '</date>';
	}
	elseif ($startdate != 0 && $enddate != 0){
		$node = '<dateRange><fromDate' . (strlen($start_gYear) > 0 ? ' standardDate="' . $start_gYear . '"' : '') . '>' . $fromDate_textual . '</fromDate><toDate' . (strlen($start_gYear) > 0 ? ' standardDate="' . $end_gYear . '"' : '') . '>' . $toDate_textual . '</toDate></dateRange>';
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
	//load DOMDocument
	$dom = new DOMDocument('1.0', 'UTF-8');
	if ($dom->loadXML($xml) === FALSE){
		echo "{$nudsid} failed to validate.\n";
		$errors[] = $nudsid . ' failed to validate.';
	} else {
		$dom->preserveWhiteSpace = FALSE;
		$dom->formatOutput = TRUE;
		//echo $dom->saveXML() . "\n";

		$filename = '/home/komet/ans_migration/egypt/new/' . $nudsid . '.xml';
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
		curl_setopt($putToExist,CURLOPT_URL,'http://localhost:8080/exist/rest/db/egypt/objects/' . $nudsid . '.xml');
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
