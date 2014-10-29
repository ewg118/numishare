<?php
/************************
AUTHOR: Ethan Gruber
MODIFIED: September, 2013
DESCRIPTION: Receive and interpret escaped CSV sent from Filemaker Pro database
to public server, transform to Numishare-compliant NUDS XML (performing cleanup of data),
post to eXist XML database via cURL, and get Solr add document from Cocoon and post to Solr.
REQUIRED LIBRARIES: php5, php5-curl, php5-cgi
************************/

/************************
 * DEPLOYMENT STEPS
* 1. install required PHP libraries (see above)
* 2. install sendmail (for reporting)
* 3. create /var/log/numishare/error.log and set write permissions
* 4. create /var/log/numishare/success.log and set write permissions
* 5. Create symlink for this script in /usr/lib/cgi-bin (or default cgi folder in Ubuntu or other OS)
* 6. Set Apache configuration in sites-enabled to enable cgi execution:
* <Directory "/usr/lib/cgi-bin">
AllowOverride None
Options +ExecCGI -MultiViews FollowSymLinks
Order deny, allow
Deny from all
Allow from ....
AddHandler cgi-script cgi php py
</Directory>
* 7. Allow from ANS IP address
* 8. Restart Apache
* 9. Increase maxHeaderLength for Tomcat in conf/server.xml
* 10. Script is good to go.
************************/

// Ignore user aborts and allow the script
// to run forever
error_reporting(0);
ignore_user_abort(true);
set_time_limit(0);

//get unique id of recently uploaded Filemaker CSV from request parameter
//the line below is for passing request parameters from the command line.
parse_str(implode('&', array_slice($argv, 1)), $_GET);
$csv_id = $_GET['id'];
error_log(date(DATE_W3C) . ": {$csv_id}.csv now entering fm-to-nuds.php.\n", 3, "/var/log/numishare/process.log");

//create an array with pre-defined labels and values passed from the Filemaker POST
$labels = array("accnum","department","objtype","material","manufacture",
		"shape","weight","measurements","axis","denomination","era","dob",
		"startdate","enddate","refs","published","info","prevcoll","region",
		"locality","series","dynasty","mint","mintabbr","person","issuer",
		"magistrate","maker","artist","sernum","subjevent","subjperson",
		"subjissuer","subjplace","decoration","degree","findspot",
		"obverselegend","obversetype","reverselegend","reversetype","color",
		"edge","undertype","counterstamp","conservation","symbol",
		"obversesymbol","reversesymbol","signature","watermark",
		"imageavailable","acknowledgment","category","imagesponsor",
		"OrigIntenUse","Authenticity","PostManAlt","diameter","height","width","depth","privateinfo");
$errors = array();
$warnings = array();
$deityMatchArray = get_deity_array();

/*$csv = '"1979.38.312","ME","MEDAL","AE","Cast","","","89","12","","","1919","1919","1919","K.229|||||||||||||||||||","","","","Germany","","","","","","|||||||||||||||||||","","|||||||||","","Goetz","","The Good Samaritan","","","","","","","DER . BARMHERZIGE . SAMARITER! (=""The good Samaritan"")/ in exergue: 1919","Figure of Uncle Sam in center, to l., holding long scroll; figure of ""Michel"" (Germans) laying injured on floor reading the long scroll; to r. of Uncle Sam: mule shown from back packed with suitcases and large sack.   ","ENGLAND\'S . SCHANDTAT (=""England\'s deed of shame"")/ in exergue: AUFGEHOBEN . AM/ 12. JULI 1919! (=Lifted on July 12, 1919"")","5 figures and an infant laying on ground in front of large wall, behind which there is the sea with 7 vessels.","","","","","","","K.GOETZ","","","","","","","",""';
$temp = str_getcsv($csv, ',', '"');
var_dump($temp);*/
//load Google Spreadsheets
//mints
$Byzantine_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdGJSRFhnR3ZKbHo2bG5oV0pDSzBBRnc&single=true&gid=0&output=csv');
$Decoration_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdFdTVy1UWGp6bFZvbTlsQWJyWmtlR1E&single=true&gid=0&output=csv');
$East_Asian_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdFdONnhna3RpNGxwTjJ1M3RiSkxfTUE&single=true&gid=0&output=csv');
$Greek_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdERQcHlNWXJlbTcwQ2g4YmM5QmxRMVE&single=true&gid=0&output=csv');
$Islamic_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdG1MbV9PcGMzTUU1dWU2by1sNWNnbGc&single=true&gid=0&output=csv');
$Latin_American_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdGI0UmpzSTNaXy1OWHhCSnp6VDA4OEE&single=true&gid=0&output=csv');
$Medieval_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdGFkbW8xLV9yYm9rQ3VVd25rcUJTVmc&single=true&gid=0&output=csv');
$Medal_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdGg5SFlaU0VUUzM5ZUZQdHFHV3ZncVE&single=true&gid=0&output=csv');
$Modern_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdG9WVk5EMW1YamN3UFNNTHZlS0hwT1E&single=true&gid=0&output=csv');
$Roman_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdHNMSmFWdXRkWnVxRy1sOTR1Z09HQnc&single=true&gid=0&output=csv');
$South_Asian_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdFpxbjVsc25rblIyZy1OSngtVy15VGc&single=true&gid=0&output=csv');
$United_States_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdEZ3VU1JeThGVHJiNEJsUkptbTFTRGc&single=true&gid=0&output=csv');

if (($handle = fopen("/tmp/" . $csv_id . ".csv", "r")) !== FALSE) {	
	error_log(date(DATE_W3C) . ": {$csv_id}.csv successfully opened for processing.\n", 3, "/var/log/numishare/process.log");
	$accnums = array();
	$startTime = date(DATE_W3C);
	$count = 1;
	$file = file_get_contents("/tmp/" . $csv_id . ".csv");
	$cleanFile = '/tmp/' . substr(md5(rand()), 0, 7) . '.csv';
	//escape conflicting XML characters
	$cleaned = preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F\x80-\x9F]/u', '', preg_replace("[\x1D]", "|", str_replace('>', '&gt;', str_replace('<', '&lt;', str_replace('&', 'and', preg_replace("[\x0D]", "\n", $file))))));
	file_put_contents($cleanFile, $cleaned);
	if (($cleanHandle = fopen($cleanFile, "r")) !== FALSE) {
		error_log(date(DATE_W3C) . ": {$csv_id}.csv cleaned. {$cleanFile} opened for processing.\n", 3, "/var/log/numishare/process.log");
		while (($data = fgetcsv($cleanHandle, 2500, ',', '"')) !== FALSE) {
			$row = array();
			foreach ($labels as $key=>$label){
				$row[$label] = preg_replace('/\s+/', ' ', $data[$key]);
			}
			if (trim(strtoupper($row['department'])) != 'J'){
				//create new filename path
				$collection = 'mantis';
				$department = get_department($row['department']);
					
				$accPieces = explode('.', trim($row['accnum']));
				$accYear = $accPieces[0];
				$accnum = trim($row['accnum']);
				$fileName = '/tmp/' . $accnum . '.xml';
				//call function to generate xml
				//provide error handling for $accnums that lack values
				if (strlen($accnum) == 0){
					error_log('[no accnum] (' . $department . ') record lacks accession number ' . date(DATE_W3C) . "\n", 3, "/var/log/numishare/error.log");
					$errors[] = $count . ':(' . $department . ') record lacks accession number.';
				} elseif (!is_numeric($accPieces[0]) || !is_numeric($accPieces[1]) || !is_numeric($accPieces[2])) {
					error_log($accnum . '[invalid accnum] (' . $department . ') accnum contains non-integer component: ' . date(DATE_W3C) . "\n", 3, "/var/log/numishare/error.log");
					$errors[] = $count . ': ' . $accnum . '(' . $department . ') accnum contains non-integer component';
				} elseif ($department == 'FAIL') {
					error_log($accnum . '(' . $row['department'] . ') invalid department: ' . date(DATE_W3C) . "\n", 3, "/var/log/numishare/error.log");
					$errors[] = $count . ': ' . $accnum . '(' . $row['department'] . ') invalid department.';
				} else {
					//block 1001.1.* and 1001.57.* ranges
					if (strpos($accnum, '1001.1.') === FALSE && strpos($accnum, '1001.57.') === FALSE){
						$xml = generate_nuds($row, $count);
						//load DOMDocument
						$dom = new DOMDocument('1.0', 'UTF-8');
						if ($dom->loadXML($xml) === FALSE){
							error_log($accnum . ' (' . $department . ') failed to validate in DOMDocument at ' . date(DATE_W3C) . "\n", 3, "/var/log/numishare/error.log");
							$errors[] = $accnum . ' (' . $department . ') failed to validate in DOMDocument.';
						} else {						
							$dom->preserveWhiteSpace = FALSE;
							$dom->formatOutput = TRUE;
							//echo $dom->saveXML();
							$dom->save($fileName);
						
							//read file back into memory for PUT to eXist
							if (($readFile = fopen($fileName, 'r')) === FALSE){
								error_log($accnum . ' (' . $department . ') failed to open temporary file (accnum likely broken) at ' . date(DATE_W3C) . "\n", 3, "/var/log/numishare/error.log");
								$errors[] = $accnum . ' (' . $department . ') failed to open temporary file (accnum likely broken).';
							} else {
								//PUT xml to eXist
								$putToExist=curl_init();
									
								//set curl opts
								curl_setopt($putToExist,CURLOPT_URL,'http://localhost:8080/exist/rest/db/' . $collection . '/objects/' . $accYear . '/' . $accnum . '.xml');
								curl_setopt($putToExist,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8"));
								curl_setopt($putToExist,CURLOPT_CONNECTTIMEOUT,2);
								curl_setopt($putToExist,CURLOPT_RETURNTRANSFER,1);
								curl_setopt($putToExist,CURLOPT_PUT,1);
								curl_setopt($putToExist,CURLOPT_INFILESIZE,filesize($fileName));
								curl_setopt($putToExist,CURLOPT_INFILE,$readFile);
								curl_setopt($putToExist,CURLOPT_USERPWD,"admin:");
								$response = curl_exec($putToExist);
									
								$http_code = curl_getinfo($putToExist,CURLINFO_HTTP_CODE);
									
								//error and success logging
								if (curl_error($putToExist) === FALSE){
									error_log($accnum . ' (' . $department . ') failed to upload to eXist at ' . date(DATE_W3C) . "\n", 3, "/var/log/numishare/error.log");
									$errors[] = $accnum . ' (' . $department . ') failed to upload to eXist.';
								} else {
									if ($http_code == '201'){
										$datetime = date(DATE_W3C);
										echo "Writing {$accnum}.\n";
										error_log("{$accnum}: {$datetime}\n", 3, "/var/log/numishare/success.log");
											
										//if file was successfully PUT to eXist, add the accession number to the array for Solr indexing.
										$accnums[] = trim($row['accnum']);
											
										//index records into Solr in increments of 5,000
										if (count($accnums) > 0 && count($accnums) % 1000 == 0 ){
											$start = count($accnums) - 1000;
											$toIndex = array_slice($accnums, $start, 1000);
						
											//POST TO SOLR
											generate_solr_shell_script($toIndex);
										}
									}
								}
								//close eXist curl
								curl_close($putToExist);
										
								//close files and delete from /tmp
								fclose($readFile);
								unlink($fileName);
							}
						}
					}
				}
			}
			$count++;
		}
	} else {
		error_log(date(DATE_W3C) . ": Unable to open {$cleanFile}.\n", 3, "/var/log/numishare/process.log");
	}
	
	//delete temporary cleaned CSV file
	error_log(date(DATE_W3C) . ": {$cleanFile} has been processed and deleted.\n", 3, "/var/log/numishare/process.log");
	fclose($cleanHandle);
	unlink($cleanFile);
	
	$endTime = date(DATE_W3C);
	echo generate_html_response($csv_id, $accnums, $errors, $warnings, $startTime, $endTime);

	//execute process for remaining accnums.
	$start = floor(count($accnums) / 1000) * 1000;
	$toIndex = array_slice($accnums, $start);

	//POST TO SOLR
	generate_solr_shell_script($toIndex);

	$endTime = date(DATE_W3C);

	//generate HTML response
	echo generate_html_response($csv_id, $accnums, $errors, $warnings, $startTime, $endTime);

	//send email if there are errors
	generate_email_report($csv_id, $accnums, $errors, $warnings, $startTime, $endTime);
	
	fclose($handle);
	unlink("/tmp/" . $csv_id . ".csv");
	error_log(date(DATE_W3C) . ": Processing completed. /tmp/{$csv_id}.csv has been deleted.\n", 3, "/var/log/numishare/process.log");
} else {
	error_log(date(DATE_W3C) . ": Unable to open {$csv_id}.csv.\n", 3, "/var/log/numishare/process.log");
}

/****** GENERATE NUDS ******/
function generate_nuds($row, $count){
	GLOBAL $deityMatchArray;
	GLOBAL $warnings;

	//generate collection year for images
	$accnum = trim($row['accnum']);
	$accession_array = explode('.', $accnum);
	$collection_year = $accession_array[0];

	//department
	$department = get_department($row['department']);

	//references; used to check for 'ric.' for pointing typeDesc to OCRE
	$refs = array_filter(explode('|', $row['refs']));
	
	//control
	$xml = '<?xml version="1.0" encoding="UTF-8"?><nuds xmlns="http://nomisma.org/nuds" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mets="http://www.loc.gov/METS/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" recordType="physical">';
	$xml .= "<control><recordId>{$accnum}</recordId>";
	$xml .= '<publicationStatus>approved</publicationStatus>';
	$xml .= '<maintenanceAgency><agencyName>American Numismatic Society</agencyName></maintenanceAgency>';
	$xml .= '<maintenanceStatus>derived</maintenanceStatus>';
	$xml .= '<maintenanceHistory><maintenanceEvent>';
	$xml .= '<eventType>derived</eventType><eventDateTime standardDateTime="' . date(DATE_W3C) . '">' . date(DATE_W3C) . '</eventDateTime><agentType>machine</agentType><agent>PHP</agent><eventDescription>Exported from Filemaker</eventDescription>';
	$xml .= '</maintenanceEvent></maintenanceHistory>';
	$xml .= '<rightsStmt><copyrightHolder>American Numismatic Society</copyrightHolder></rightsStmt>';
	$xml .= "</control>";
	$xml .= '<descMeta>';

	//subjects
	if (strlen(trim($row['category'])) > 0 || strlen(trim($row['series'])) > 0 || strlen(trim($row['subjevent'])) > 0 || strlen(trim($row['subjissuer'])) > 0 || strlen(trim($row['subjperson'])) > 0 || strlen(trim($row['subjplace'])) > 0 || strlen(trim($row['degree'])) > 0 || strlen(trim($row['era'])) > 0){
		$xml .= '<subjectSet>';
		if (strlen(trim($row['category'])) > 0){
			$categories = array_filter(explode('|', trim($row['category'])));
			foreach ($categories as $category){
				$xml .= '<subject localType="category">' . trim($category) . '</subject>';
			}
		}
		if (strlen(trim($row['series'])) > 0){
			$serieses = array_filter(explode('|', $row['series']));
			foreach ($serieses as $series){
				$xml .= '<subject localType="series">' . trim($series) . '</subject>';
			}
		}
		if (strlen(trim($row['subjevent'])) > 0){
			$subjEvents = array_filter(explode('|', $row['subjevent']));
			foreach ($subjEvents as $subjEvent){
				$xml .= '<subject localType="subjectEvent">' . trim($subjEvent) . '</subject>';
			}
		}
		if (strlen(trim($row['subjissuer'])) > 0){
			$subjIssuers = array_filter(explode('|', $row['subjissuer']));
			foreach ($subjIssuers as $subjIssuer){
				$xml .= '<subject localType="subjectIssuer">' . trim($subjIssuer) . '</subject>';
			}
		}
		if (strlen(trim($row['subjperson'])) > 0){
			$subjPersons = array_filter(explode('|', $row['subjperson']));
			foreach ($subjPersons as $subjPerson){
				$xml .= '<subject localType="subjectPerson">' . trim($subjPerson) . '</subject>';
			}
		}
		if (strlen(trim($row['subjplace'])) > 0){
			$subjPlaces = array_filter(explode('|', $row['subjplace']));
			foreach ($subjPlaces as $subjPlace){
				$xml .= '<subject localType="subjectPlace">' . trim($subjPlace) . '</subject>';
			}
		}
		if (strlen(trim($row['era'])) > 0){
			$eras = array_filter(explode('|', $row['era']));
			foreach ($eras as $era){
				$xml .= '<subject localType="era">' . trim($era) . '</subject>';
			}
		}
		//degree
		if (strlen(trim($row['degree'])) > 0){
			$degrees = array_filter(explode('|', $row['degree']));
			foreach ($degrees as $degree){
				$xml .= '<subject localType="degree">' . trim($degree) . '</subject>';
			}
		}
		$xml .= '</subjectSet>';
	}
	//notes
	if (strlen(trim($row['info'])) > 0){
		$infos = array_filter(explode('|', $row['info']));
		$xml .= '<noteSet>';
		foreach ($infos as $info){
			$xml .= '<note>' . trim($info) . '</note>';
		}
		$xml .= '</noteSet>';
	}

	/************ typeDesc ***************/
	//if the coin is Roman and contains 'ric.' as a reference, point the typeDesc to OCRE
	//supported nomisma-style strings are: ric.1., ric.1(2)., ric.2_1(2)., ric.3.
	if (count(preg_grep('/ric\.1\./', $refs)) == 1 || count(preg_grep('/ric\.1\(2\)\./', $refs)) == 1 || count(preg_grep('/ric\.2_1\(2\)\./', $refs)) == 1 || count(preg_grep('/ric\.2\./', $refs)) == 1 || count(preg_grep('/ric\.3\./', $refs)) == 1 || count(preg_grep('/ric\.4\./', $refs)) == 1){
		//only continue process if the reference is not variant
		if (strpos($row['info'], 'variant') === FALSE){
			$matches = preg_grep('/ric\./', $refs);
			$certainty = '';
			foreach ($matches as $k=>$v){
				if (strlen(trim($v)) > 0){
					//account for ? used as uncertainty
					$id = substr(trim($v), -1) == '?' ? str_replace('?', '', trim($v)) : trim($v);
					$certainty = substr(trim($v), -1) == '?' ? ' certainty="uncertain"' : '';
				}
			}
			$url = 'http://numismatics.org/ocre/id/' . $id;
			$file_headers = @get_headers($url);
			$rdf_headers = @get_headers($url . '.rdf');
			if ($file_headers[0] == 'HTTP/1.1 200 OK' && $rdf_headers[0] == 'HTTP/1.1 200 OK'){
				$currentUri = get_current_ocre_uri($url);
				if ($currentUri != 'FAIL'){
					$title = get_title_from_rdf($currentUri, $accnum);
					if ($title != 'FAIL'){
						$xml .= $title;
						$xml .= '<typeDesc xlink:type="simple" xlink:href="' . $currentUri . '"' . $certainty . '/>';
					} else {
						$xml .= generate_typeDesc($row, $department);
					}
				} else {
					//FAIL if the $ref actually has two new URIs
					$xml .= generate_typeDesc($row, $department);
				}				
			} else {
				$xml .= generate_typeDesc($row, $department);
			}	
		} else {
			//otherwise simply generate typeDesc
			$xml .= generate_typeDesc($row, $department);
		}
		
	} elseif ($department=='Roman' && count(preg_grep('/C\.[1-9]/', $refs)) > 0){
		//handle Roman Republican
		$matches = preg_grep('/C\.[1-9]/', $refs);
		$certainty = '';
		foreach ($matches as $k=>$v){
			if (strlen(trim($v)) > 0){
				$id = substr(trim($v), -1) == '?' ? str_replace('?', '', trim($v)) : trim($v);
				$certainty = substr(trim($v), -1) == '?' ? ' certainty="uncertain"' : '';
			}
		}
		$url = 'http://nomisma.org/id/' . str_replace('C.', 'rrc-', $id);
		$file_headers = @get_headers($url);
		$rdf_headers = @get_headers($url . '.rdf');
		if ($file_headers[0] == 'HTTP/1.1 200 OK' && $rdf_headers[0] == 'HTTP/1.1 200 OK'){
			$title = get_title_from_rdf($url, $accnum);
			if ($title != 'FAIL'){
				$xml .= $title;
				$xml .= '<typeDesc xlink:type="simple" xlink:href="' . $url . '"' . $certainty . '/>';
			} else {
				$xml .= generate_typeDesc($row, $department);
			}
		} else {
			$xml .= generate_typeDesc($row, $department);
		}
	} elseif ($row['privateinfo'] == 'WW I project ready') {
		//handle AoD
		$citations = array_filter(explode('|', trim($row['published'])));
		$url = 'http://numismatics.org/aod/id/' . $citations[0];
		$file_headers = @get_headers($url);
		$rdf_headers = @get_headers($url . '.rdf');
		if ($file_headers[0] == 'HTTP/1.1 200 OK' && $rdf_headers[0] == 'HTTP/1.1 200 OK'){
			$title = get_title_from_rdf($url, $accnum);
			if ($title != 'FAIL'){
				$xml .= $title;
				$xml .= '<typeDesc xlink:type="simple" xlink:href="' . $url . '"/>';
			} else {
				$xml .= generate_typeDesc($row, $department);
			}
		} else {
			$xml .= generate_typeDesc($row, $department);
		}
		
	}  else {
		$xml .= generate_typeDesc($row, $department);
	}

	/***** UNDERTYPE DESCRIPTION *****/
	if (strlen(trim($row['undertype'])) > 0){
		$xml .= '<undertypeDesc><description xml:lang="en">' . trim($row['undertype']) . '</description></undertypeDesc>';
	}

	/***** PHYSICAL DESCRIPTION *****/
	$xml .= '<physDesc>';

	//axis: only create if it's an integer
	$axis = (int) $row['axis'];
	if (is_int($axis) && $axis <= 12 && $axis >= 0){
		$xml .= '<axis>' . $axis . '</axis>';
	} elseif((strlen($axis) > 0 && !is_int($axis)) || $axis > 12){
		$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-integer axis or value exceeding 12.';
	}

	//color
	if (strlen($row['color']) > 0){
		$colors = array_filter(explode('|', $row['color']));
		foreach ($colors as $color){
			$xml .= '<color>' . trim($color) . '</color>';
		}
	}
	//dob
	if (strlen(trim($row['dob'])) > 0){
		$xml .= '<dateOnObject><date>' . trim($row['dob']) . '</date></dateOnObject>';
	}
	//sernum
	if (strlen(trim($row['sernum'])) > 0){
		$xml .= '<serialNumber>' . trim($row['sernum']) . '</serialNumber>';
	}
	//watermark
	if (strlen(trim($row['watermark'])) > 0){
		$xml .= '<watermark>' . trim($row['watermark']) . '</watermark>';
	}
	//shape
	if (strlen(trim($row['shape'])) > 0){
		$xml .= '<shape>' . trim($row['shape']) . '</shape>';
	}
	//signature
	if (strlen(trim($row['signature'])) > 0){
		$xml .= '<signature>' . trim($row['signature']) . '</signature>';
	}
	//counterstamp
	if (strlen(trim($row['counterstamp'])) > 0){
		$xml .= '<countermark><description xml:lang="en">' . trim($row['counterstamp']) . '</description></countermark>';
	}
	//create measurementsSet, if applicable
	if ((is_numeric(trim($row['weight'])) && trim($row['weight']) > 0) || (is_numeric(trim($row['diameter'])) && trim($row['diameter']) > 0) || (is_numeric(trim($row['height'])) && trim($row['height']) > 0) || (is_numeric(trim($row['width'])) && trim($row['width']) > 0) || (is_numeric(trim($row['depth'])) && trim($row['depth']) > 0)){
		$xml .= '<measurementsSet>';
		//weight
		$weight = trim($row['weight']);
		if (is_numeric($weight) && $weight > 0){
			$xml .= '<weight units="g">' . $weight . '</weight>';
		} elseif(!is_numeric($weight) && strlen($weight) > 0){
			$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-numeric weight.';
		}
		//diameter
		$diameter = trim($row['diameter']);
		if (is_numeric($diameter) && $diameter > 0){
			$xml .= '<diameter units="mm">' . $diameter . '</diameter>';
		} elseif(!is_numeric($diameter) && strlen($diameter) > 0){
			$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-numeric diameter.';
		}
		//height
		$height = trim($row['height']);
		if (is_numeric($height) && $height > 0){
			$xml .= '<height units="mm">' . $height . '</height>';
		} elseif(!is_numeric($height) && strlen($height) > 0){
			$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-numeric height.';
		}
		//width
		$width = trim($row['width']);
		if (is_numeric($width) && $width > 0){
			$xml .= '<width units="mm">' . $width . '</width>';
		} elseif(!is_numeric($width) && strlen($width) > 0){
			$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-numeric width.';
		}
		//depth
		$depth = trim($row['depth']);
		if (is_numeric($depth) && $depth > 0){
			$xml .= '<thickness units="mm">' . $depth . '</thickness>';
		} elseif(!is_numeric($depth) && strlen($depth) > 0){
			$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-numeric depth.';
		}
		$xml .= '</measurementsSet>';
	}
	
	if (strlen(trim($row['Authenticity'])) > 0){
		$array = array_filter(explode('|', $row['Authenticity']));
		foreach ($array as $val){
			$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
			$label = str_replace('?', '', trim($val));
			$xml .= '<authenticity' . $certainty . '>' . $label . '</authenticity>';
		}
	}
	
	if (strlen(trim($row['OrigIntendedUse'])) > 0){
		$array = array_filter(explode('|', $row['OrigIntendedUse']));
		foreach ($array as $val){
			$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
			$label = str_replace('?', '', trim($val));
			$xml .= '<originalIntendeUse' . $certainty . '>' . $label . '</originalIntendeUse>';
		}
	}
	
	//conservationState
	if (strlen(trim($row['conservation'])) > 0 || strlen(trim($row['PostManAlt'])) > 0){
		$xml .= '<conservationState>';
		if (strlen(trim($row['conservation'])) > 0){
			$xml .= '<description xml:lang="en">' . trim($row['conservation']) . '</description>';
		}
		
		if (strlen(trim($row['PostManAlt'])) > 0){
			$array = array_filter(explode('|', $row['PostManAlt']));
			foreach ($array as $val){
				$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
				$label = str_replace('?', '', trim($val));
				$xml .= '<condition' . $certainty . '>' . $label . '</condition>';
			}
		}
		$xml .='</conservationState>';
	}
	$xml .= '</physDesc>';

	/***** ADMINSTRATIVE DESCRIPTION *****/
	$xml .= '<adminDesc>';
	$xml .= '<identifier>' . $accnum . '</identifier>';
	$xml .= '<department>' . $department . '</department>';
	$xml .= '<collection xlink:type="simple" xlink:href="http://nomisma.org/id/ans">American Numismatic Society</collection>';

	if (strlen(trim($row['imagesponsor'])) > 0){
		$xml .= '<acknowledgment>' . trim($row['imagesponsor']) . '</acknowledgment>';
	}
	//custhodhist
	if (strlen(trim($row['prevcoll'])) > 0 || strlen(trim($row['acknowledgment'])) > 0){
		$prevcolls = array_filter(explode('|', $row['prevcoll']));
		$xml .= '<provenance><chronList>';
		if (strlen(trim($row['acknowledgment'])) > 0){
			$xml .= '<chronItem><acquiredFrom>' . trim($row['acknowledgment']) . '</acquiredFrom></chronItem>';
		}
		foreach ($prevcolls as $prevcoll){
			if (!is_int($prevcoll) && strlen(trim($prevcoll)) > 0){
				$xml .= '<chronItem><previousColl>' . trim($prevcoll) . '</previousColl></chronItem>';
			}
		}
		$xml .= '</chronList></provenance>';
	}

	$xml .= '</adminDesc>';

	/***** BIBLIOGRAPHIC DESCRIPTION *****/
	$citations = array_filter(explode('|', trim($row['published'])));
	if (count($refs) > 0 || count($citations) > 0){		
		$xml .= '<refDesc>';
		//reference
		if (count($refs) > 0){
			foreach ($refs as $val){				
				$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
				$label = str_replace('?', '', trim($val));
				$xml .= '<reference' . $certainty . '>' . $label . '</reference>';
			}
		}
		//citation
		if (count($citations) > 0){
			foreach ($citations as $val){				
				$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
				$label = str_replace('?', '', trim($val));
				$xml .= '<citation' . $certainty . '>' . $label . '</citation>';
			}
		}
		$xml .= '</refDesc>';
	}

	/***** FINDSPOT DESCRIPTION *****/
	if (strlen(trim($row['findspot'])) > 0){
		$xml .= '<findspotDesc><findspot><geogname xlink:type="simple" xlink:role="findspot">' . trim($row['findspot']) . '</geogname></findspot></findspotDesc>';
	}
	
	$xml .= '</descMeta>';

	/***** IMAGES AVAILABLE *****/

	if (strlen(trim($row['imageavailable'])) > 0){
		switch ($collection_year) {
			case $collection_year < 1900:
				$image_path = '00001899';
				break;
			case $collection_year >= 1900 && $collection_year < 1950:
				$image_path = '19001949';
				break;
			case $collection_year >= 1950 && $collection_year < 2000:
				$image_path = '19501999';
				break;
			case $collection_year >= 2000 && $collection_year < 2050:
				$image_path = '20002049';
				break;
		}
		$xml .= '<digRep><mets:fileSec><mets:fileGrp USE="obverse"><mets:file USE="reference" MIMETYPE="image/jpeg">';
		$xml .= '<mets:FLocat LOCTYPE="URL" xlink:href="http://numismatics.org/collectionimages/' . $image_path . '/' . $collection_year . '/' . $accnum . '.obv.width350.jpg"/>';
		$xml .= '</mets:file><mets:file USE="thumbnail" MIMETYPE="image/jpeg">';
		$xml .=	'<mets:FLocat LOCTYPE="URL" xlink:href="http://numismatics.org/collectionimages/' . $image_path . '/' . $collection_year . '/' . $accnum . '.obv.width175.jpg"/>';
		$xml .= '</mets:file></mets:fileGrp><mets:fileGrp USE="reverse"><mets:file USE="reference" MIMETYPE="image/jpeg">';
		$xml .= '<mets:FLocat LOCTYPE="URL" xlink:href="http://numismatics.org/collectionimages/' . $image_path . '/' . $collection_year . '/' . $accnum . '.rev.width350.jpg"/>';
		$xml .= '</mets:file><mets:file USE="thumbnail" MIMETYPE="image/jpeg">';
		$xml .= '<mets:FLocat LOCTYPE="URL" xlink:href="http://numismatics.org/collectionimages/' . $image_path . '/' . $collection_year . '/' . $accnum . '.rev.width175.jpg"/>';
		$xml .= '</mets:file></mets:fileGrp></mets:fileSec></digRep>';
	}
	$xml .= '</nuds>';

	return $xml;

	/*
	 //symbol
	if (trim($row['symbol']) != ''){
	$xml .= '<physfacet type="symbol">' . trim($row['symbol']) . '</physfacet>';
	}
	*/
}

function generate_typeDesc($row, $department){
	GLOBAL $deityMatchArray;
	GLOBAL $warnings;
	
	$geogAuthorities = array();
	$title_elements = array();
	
	//facets
	$denominations = array_filter(explode('|', $row['denomination']));
	$materials = array_filter(explode('|', $row['material']));
	$mints = array_filter(explode('|', $row['mint']));
	$regions = array_filter(explode('|', $row['region']));
	$localities = array_filter(explode('|', $row['locality']));
	$issuers = array_filter(explode('|', $row['issuer']));
	$artists = array_filter(explode('|', $row['artist']));
	$manufactures = array_filter(explode('|', $row['manufacture']));
	$persons = array_filter(explode('|', $row['person']));	
	$magistrates = array_filter(explode('|', $row['magistrate']));
	$makers = array_filter(explode('|', $row['maker']));
	$dynasties = array_filter(explode('|', $row['dynasty']));
	
	//dates
	$startdate_int = trim($row['startdate']) * 1;
	$enddate_int = trim($row['enddate']) * 1;
	$date = '';
	if (trim($row['startdate']) != '' || trim($row['enddate']) != ''){		
		$date = get_date($startdate_int, $enddate_int, $row['accnum'], $department);
	}
	
	//define obv., rev., and unspecified artists
	$artists_none = array();
	$artists_obv = array();
	$artists_rev = array();
	foreach ($artists as $artist){
		if (strlen(trim($artist)) > 0){
			if (strpos($artist, '(obv.)') !== false && strpos($artist, '(rev.)') !== false){
				$artists_obv[] = trim(str_replace('(rev.)', '', str_replace('(obv.)', '', str_replace('"', '', $artist))));
				$artists_rev[] = trim(str_replace('(rev.)', '', str_replace('(obv.)', '', str_replace('"', '', $artist))));
			} else if (strpos($artist, '(obv.)') !== false && strpos($artist, '(rev.)') !== true){
				$artists_obv[] = trim(str_replace('(rev.)', '', str_replace('(obv.)', '', str_replace('"', '', $artist))));
			} else if (strpos($artist, '(obv.)') !== true && strpos($artist, '(rev.)') !== false){
				$artists_rev[] = trim(str_replace('(rev.)', '', str_replace('(obv.)', '', str_replace('"', '', $artist))));
			} else if (strpos($artist, '(obv.)') !== true && strpos($artist, '(rev.)') !== true){
				$artists_none[] = str_replace('"', '', $artist);
			}
		}
	}
	
	//object type
	switch (trim(strtoupper($row['objtype']))) {
		case 'C':
			$objtype = 'Coin';
			$objtype_uri = 'http://nomisma.org/id/coin';
			break;
		case 'DE':
			$objtype = 'Decoration';
			break;
		case 'INGOT':
			$objtype = 'Ingot';
			$objtype_uri = 'http://nomisma.org/id/ingot';
			break;
		case 'ME':
			$objtype = 'Medal';
			$objtype_uri = 'http://nomisma.org/id/medal';
			break;
		case 'P':
			$objtype = 'Paper';
			break;
		case 'T':
			$objtype = 'Token';
			$objtype_uri = 'http://nomisma.org/id/token';
			break;
		default:
			$objtype = ucfirst(strtolower(trim($row['objtype'])));
	}
	
	$xml = '<typeDesc>';
	$xml .= '<objectType xlink:type="simple" xlink:href="' . $objtype_uri . '">' . $objtype . '</objectType>';
	//date
	
	if (strlen($date) > 0){
		$xml .= $date;
	}
	//denomination
	if (count($denominations) > 0){
		foreach ($denominations as $denomination){
			$val = trim(str_replace('"', '', $denomination));
			$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
			$xml .= '<denomination xlink:type="simple"' . $certainty . '>' . trim(str_replace('?', '', $val)) . '</denomination>';
				
			//insert material
			$title_elements['denomination'] = trim(str_replace('?', '', $val));
		}
	}
	//manufacture
	if (count($manufactures) > 0){
		
		foreach ($manufactures as $manufacture){
			$val = trim(str_replace('"', '', $manufacture));
			$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
			if (strstr(strtolower($val), 'struck')){
				$href = ' xlink:type="simple" xlink:href="http://nomisma.org/id/struck"';
				$label = 'Struck';
			} elseif (strstr(strtolower($val), 'cast')){
				$href = ' xlink:type="simple" xlink:href="http://nomisma.org/id/cast"';
				$label = 'Cast';
			} else {
				$href = '';
				$label = str_replace('?', '', trim($val));
			}
			$xml .= '<manufacture' . $href . $certainty . '>' . $label . '</manufacture>';
		}
	}
	//material
	if (count($materials) > 0){
		foreach ($materials as $material){
			$material_string = get_material_label(trim($material));
			$mat_array = normalize_material(trim($material));
			if (strlen($mat_array['uri']) > 0){
				$xml .= '<material xlink:type="simple" xlink:href="' . $mat_array['uri'] . '">' . $material_string . '</material>';
			} else {
				$xml .= '<material>' . $material_string . '</material>';
			}
				
			//insert material
			$title_elements['material'] = $material_string;
		}
	}
	//obverse
	if (strlen($row['obverselegend']) > 0 || strlen($row['obversesymbol']) > 0 || strlen($row['obversetype']) > 0 || count($artists_obv) > 0){
		$xml .= '<obverse>';
		//obverselegend
		if (strlen($row['obverselegend']) > 0){
			$xml .= '<legend>' . trim($row['obverselegend']) . '</legend>';
		}
		//obversesymbol
		if (strlen($row['obversesymbol']) > 0){
			$xml .= '<symbol>' . trim($row['obversesymbol']) . '</symbol>';
		}
		//obversetype
		if (strlen($row['obversetype']) > 0){
			$xml .= '<type><description xml:lang="en">' . trim($row['obversetype']) . '</description></type>';
		}
		//artist
		foreach ($artists_obv as $artist){
			//WORK ON ARTIST OBV/REV
			$certainty = substr($artist, -1) == '?' ? ' certainty="uncertain"' : '';
			$xml .= '<persname xlink:role="artist"' . $certainty . '>' . str_replace('?', '', $artist) . '</persname>';
		}
		if ($department == 'Greek' || $department == 'Roman'){
			$haystack = strtolower($row['obversetype']);
			foreach($deityMatchArray as $match=>$name){
				if ($name != 'Hera' && $name != 'Sol' && strlen(strstr($haystack,strtolower($match)))>0) {
					$xml .= '<persname xlink:type="simple" xlink:role="deity">' . $name . '</persname>';
				}
				//Hera and Sol need special cases because they are commonly part of other works, eg Herakles, soldiers
				elseif ($name == 'Hera' && strlen(strstr($haystack,strtolower($match . ' ')))>0){
					$xml .= '<persname xlink:type="simple" xlink:role="deity">' . $name . '</persname>';
				}
				elseif ($name == 'Sol' && strlen(strstr($haystack,strtolower($match . ' ')))>0){
					$xml .= '<persname xlink:type="simple" xlink:role="deity">' . $name . '</persname>';
				}
			}
		}
		$xml .= '</obverse>';
	}
	
	//reverse
	if (strlen($row['reverselegend']) > 0 || strlen($row['reversesymbol']) > 0 || strlen($row['reversetype']) > 0 || count($artists_rev) > 0){
		$xml .= '<reverse>';
		//reverselegend
		if (strlen($row['reverselegend']) > 0){
			$xml .= '<legend>' . trim($row['reverselegend']) . '</legend>';
		}
		//reversesymbol
		if (strlen($row['reversesymbol']) > 0){
			$xml .= '<symbol>' . trim($row['reversesymbol']) . '</symbol>';
		}
		//reversetype
		if (strlen($row['reversetype']) > 0){
			$xml .= '<type><description xml:lang="en">' . trim($row['reversetype']) . '</description></type>';
		}
		//artist
		foreach ($artists_rev as $artist){
			//WORK ON ARTIST OBV/REV
			$certainty = substr($artist, -1) == '?' ? ' certainty="uncertain"' : '';
			$xml .= '<persname xlink:role="artist"' . $certainty . '>' . str_replace('?', '', $artist) . '</persname>';
		}
		if ($department == 'Greek' || $department == 'Roman'){
			$haystack = strtolower($row['reversetype']);
			foreach($deityMatchArray as $match=>$name){
				if ($name != 'Hera' && $name != 'Sol' && strlen(strstr($haystack,strtolower($match)))>0) {
					$xml .= '<persname xlink:type="simple" xlink:role="deity">' . $name . '</persname>';
				}
				//Hera and Sol need special cases because they are commonly part of other works, eg Herakles, soldiers
				elseif ($name == 'Hera' && strlen(strstr($haystack,strtolower($match . ' ')))>0){
					$xml .= '<persname xlink:type="simple" xlink:role="deity">' . $name . '</persname>';
				}
				elseif ($name == 'Sol' && strlen(strstr($haystack,strtolower($match . ' ')))>0){
					$xml .= '<persname xlink:type="simple" xlink:role="deity">' . $name . '</persname>';
				}
			}
		}
		$xml .= '</reverse>';
	}
	//edge
	if (strlen(trim($row['edge'])) > 0){
		$xml .= '<edge><description>' . trim($row['edge']) . '</description></edge>';
	}
	
	/***** GEOGRAPHICAL LOCATIONS *****/
	if (count($mints) > 0 || count($regions) > 0 || count($localities) > 0){
		$xml .= '<geographic>';
		if (strlen(trim($row['mint'])) > 0){
			$mints_cleaned = array();
			foreach ($mints as $mint){
				//normalize mint by stripping bad characters
				if (substr($mint, 1, 1) == '('){
					$mint_normalized = trim(preg_replace('/\(|\)|\"|\{|\}|\[|\]|\#/', "", $mint));
				} else {
					$mint_normalized = trim(preg_replace('/\"|\{|\}|\[|\]|\#/', "", $mint));
				}
				$geography = parse_mint($department, $mint_normalized, $regions, $localities);
				$xml .= $geography['mint'];
				$geogAuthorities['state'] = $geography['state'];
				$geogAuthorities['authority'] = $geography['authority'];
				$mints_cleaned[] = preg_replace('/<.*>(.*)<\/geogname>/i', '$1', $geography['mint']);
			}
			$title_elements['location'] = implode('/', $mints_cleaned);
		}
		//region
		if (count($regions) > 0){
			$regions_cleaned = array();
			foreach ($regions as $region){
				$val = trim(str_replace('"', '', $region));
				$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
				$xml .= '<geogname xlink:type="simple" xlink:role="region"' . $certainty . '>' . trim(str_replace('?', '', $val)) . '</geogname>';
				$regions_cleaned[] = trim(str_replace('?', '', $val));
			}
			if (strlen(trim($row['mint'])) == 0){
				$title_elements['location'] = implode('/', $regions_cleaned);
			}
		}
		//locality
		if (count($localities) > 0){
			$localities_cleaned = array();
			foreach ($localities as $locality){
				$val = trim(str_replace('"', '', $locality));
				$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
				$xml .= '<geogname xlink:type="simple" xlink:role="locality"' . $certainty . '>' . trim(str_replace('?', '', $val)) . '</geogname>';
				$localities_cleaned[] = trim(str_replace('?', '', $val));
			}
			if (strlen(trim($row['mint'])) == 0 && strlen(trim($row['region'])) == 0){
				$title_elements['location'] = implode('/', $localities_cleaned);
			}
		}
	
		$xml .= '</geographic>';
	}
	
	/***** AUTHORITIES AND PERSONS *****/
	if (strlen($geogAuthorities['state']) > 0 || strlen($geogAuthorities['authority']) > 0 || count($persons) > 0 || count($issuers) > 0 || count($magistrates) > 0 || count($makers) > 0 ||  count($artists_none) > 0 || count($dynasties) > 0){
		$xml .= '<authority>';
		//insert authorities parsed out from the mint lookups (applies primarily to Latin America)
		if (strlen($geogAuthorities['state']) > 0){
			$xml .= $geogAuthorities['state'];
		}
		if (strlen($geogAuthorities['authority']) > 0){
			$xml .= $geogAuthorities['authority'];
		}
		//issuer
		if (count($issuers) > 0){
			$issuers_cleaned = array();
			foreach ($issuers as $issuer){
				$val = trim(str_replace('"', '', $issuer));
				$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
				if ($department == 'Medieval' || $department == 'Byzantine' || $department == 'Roman'){
					$xml .= '<persname xlink:type="simple" xlink:role="issuer"' . $certainty . '>' . trim(str_replace('?', '', $val)) . '</persname>';
				} elseif ($department == 'Greek' || $department == 'Islamic'){
					$xml .= '<persname xlink:type="simple" xlink:role="authority"' . $certainty . '>' . trim(str_replace('?', '', $val)) . '</persname>';
				}
				else {
					$xml .= '<corpname xlink:type="simple" xlink:role="issuer"' . $certainty . '>' . trim(str_replace('?', '', $val)) . '</corpname>';
				}
				$issuers_cleaned[] = trim(str_replace('?', '', $val));
			}
			$title_elements['issuer'] = implode('/', $issuers_cleaned);
		}
		//artist
		foreach ($artists_none as $artist){
			//WORK ON ARTIST OBV/REV
			$certainty = substr(trim(str_replace('"', '', $artist)), -1) == '?' ? ' certainty="uncertain"' : '';
			$xml .= '<persname xlink:type="simple" xlink:role="artist"' . $certainty . '>' . str_replace('?', '', $artist) . '</persname>';
		}
		//dynasty
		foreach ($dynasties as $dynasty){
			$certainty = substr(trim(str_replace('"', '', $dynasty)), -1) == '?' ? ' certainty="uncertain"' : '';
			$xml .= '<famname xlink:type="simple" xlink:role="dynasty"' . $certainty . '>' . str_replace('?', '', $dynasty) . '</famname>';
		}
		//maker
		if (count($makers) > 0){
			foreach ($makers as $maker){
				$certainty = substr(trim(str_replace('"', '', $maker)), -1) == '?' ? ' certainty="uncertain"' : '';
				$xml .= '<corpname xlink:type="simple" xlink:role="maker"' . $certainty . '>' . str_replace('?', '', $maker) . '</corpname>';
			}
		}
		//magistrate
		if (count($magistrates) > 0){
			foreach ($magistrates as $magistrate){
				$certainty = substr(trim(str_replace('"', '', $magistrate)), -1) == '?' ? ' certainty="uncertain"' : '';
				$xml .= '<persname xlink:type="simple" xlink:role="issuer"' . $certainty . '>' . str_replace('?', '', $magistrate) . '</persname>';
			}
		}
		//person: portrait
		if (count($persons) > 0){			
			foreach ($persons as $person){
				$certainty = substr(trim(str_replace('"', '', $person)), -1) == '?' ? ' certainty="uncertain"' : '';
				if ($department != 'Medieval'){
					$xml .= '<persname xlink:type="simple" xlink:role="portrait"' . $certainty . '>' . str_replace('?', '', $person) . '</persname>';
				}				
				if ($department == 'Roman' || $department == 'Medieval'){
					$xml .= '<persname xlink:type="simple" xlink:role="authority"' . $certainty . '>' . str_replace('?', '', $person) . '</persname>';
				}
			}
		}
		$xml .= '</authority>';
	}
	$xml .= '</typeDesc>';
	
	/***** TITLE *****/
	$title = '<title xml:lang="en">';
	if (array_key_exists('material', $title_elements)){
		$title .= $title_elements['material'];
	}
	if (array_key_exists('denomination', $title_elements)){
		$title .= ' ' .  $title_elements['denomination'];
	} else {
		$title .= ' ' . $objtype;
	}
	if (array_key_exists('issuer', $title_elements)){
		$title .= ' of ' .  $title_elements['issuer'];
	}
	if (array_key_exists('location', $title_elements)){
		$title .= ', ' . $title_elements['location'];
	}
	if (strlen($date) > 0){
		$title .= ', ';
		$title .= get_title_date($startdate_int, $enddate_int);
	}
	$title .= '. ' . trim($row['accnum']) . '</title>';
	
	//return the title before the typeDesc
	return $title . $xml;
}

function get_material_label($material){
	$hypos = strpos($material, '-');
	$slashpos = strpos($material, '/');
	if ($hypos === true){
		$frags = explode('-', $material);
		$new_array = array();
		foreach ($frags as $frag){
			$mat_array = normalize_material($frag);
			array_push($new_array, $mat_array['label']);
		}
		return implode('-', $new_array);
	}
	elseif ($slashpos === true){
		$frags = explode('/', $material);
		$new_array = array();
		foreach ($frags as $frag){
			$mat_array = normalize_material($frag);
			array_push($new_array, $mat_array['label']);
		}
		return implode('/', $new_array);
	}
	elseif ($slashpos === false && $hypos === false){
		$mat_array = normalize_material($material);
		return $mat_array['label'];
	}
}

function normalize_material($material){
	$mat_array = array();
	switch (strtoupper($material)) {
		case 'AE':
		case 'BRONZE':
			$mat_array['label'] = 'Bronze';
			$mat_array['uri'] = 'http://nomisma.org/id/ae';
			break;
		case 'AV':
		case 'AU':
		case 'GOLD':
			$mat_array['label'] = 'Gold';
			$mat_array['uri'] = 'http://nomisma.org/id/av';
			break;
		case 'AR':
		case 'SILVER':
			$mat_array['label'] = 'Silver';
			$mat_array['uri'] = 'http://nomisma.org/id/ar';
			break;
		case 'BI':
		case 'BIL':
		case 'BILLON':
			$mat_array['label'] = 'Billon';
			$mat_array['uri'] = 'http://nomisma.org/id/billon';
			break;
		case 'CU':
		case 'COPPER':
			$mat_array['label'] = 'Copper';
			$mat_array['uri'] = 'http://nomisma.org/id/cu';
			break;
		case 'EL':
		case 'ELECTRUM':
			$mat_array['label'] = 'Electrum';
			$mat_array['uri'] = 'http://nomisma.org/id/electrum';
			break;
		case 'FE':
		case 'IRON':
			$mat_array['label'] = 'Iron';
			$mat_array['uri'] = 'http://nomisma.org/id/fe';
			break;
		case 'NI':
		case 'NICKEL':
			$mat_array['label'] = 'Nickel';
			$mat_array['uri'] = 'http://nomisma.org/id/ni';
			break;
		case 'ORICHALCUM':
			$mat_array['label'] = 'Orichalcum';
			$mat_array['uri'] = 'http://nomisma.org/id/orichalcum';
			break;
		case 'PB':
		case 'LEAD':
			$mat_array['label'] = 'Lead';
			$mat_array['uri'] = 'http://nomisma.org/id/pb';
			break;
		case 'SN':
		case 'TIN':
			$mat_array['label'] = 'Tin';
			$mat_array['uri'] = 'http://nomisma.org/id/sn';
			break;
		case 'ZN':
		case 'Z':
		case 'ZINC':
			$mat_array['label'] = 'Zinc';
			$mat_array['uri'] = 'http://nomisma.org/id/zn';
			break;
		default:
			$mat_array['label'] = ucfirst(strtolower($material));
	}
	return $mat_array;
}

function get_deity_array(){
	//load deities DOM document from Google Docs
	$deityUrl = 'https://spreadsheets.google.com/feeds/list/0Avp6BVZhfwHAdHk2ZXBuX0RYMEZzUlNJUkZOLXRUTmc/od6/public/values';
	$deityDoc = new DOMDocument();
	$deityDoc->load($deityUrl);
	$deityMatches = $deityDoc->getElementsByTagNameNS('http://schemas.google.com/spreadsheets/2006/extended', 'matches');
	$deityNames = $deityDoc->getElementsByTagNameNS('http://schemas.google.com/spreadsheets/2006/extended', 'name');
	$matchArray = Array();
	$nameArray = Array();
	$deityMatchArray = Array();
	foreach($deityMatches as $match){
		$matchArray[] = $match->nodeValue;
	}
	foreach($deityNames as $name){
		$nameArray[] = $name->nodeValue;
	}
	//associate the arrays
	foreach($matchArray as $key=>$value){
		$deityMatchArray[$value] = $nameArray[$key];
	}

	return $deityMatchArray;
}

function get_title_date($fromDate, $toDate){
	if ($fromDate == 0 && $toDate != 0){
		return get_date_textual($toDate);
	} elseif ($fromDate != 0 && $toDate == 0) {
		return get_date_textual($fromDate);
	} elseif ($fromDate == $toDate){
		return get_date_textual($toDate);
	} elseif ($fromDate != 0 && $toDate != 0){
		return get_date_textual($fromDate) . ' - ' . get_date_textual($toDate);
	}
}

function get_date_textual($year){
	$textual_date = '';
	//display start date
	if($year < 0){
		$textual_date .= abs($year) . ' BC';
	} elseif ($year > 0) {
		if ($year <= 600){
			$textual_date .= 'AD ';
		}
		$textual_date .= $year;
	}
	return $textual_date;
}

function get_date($startdate, $enddate, $accnum, $department){
	GLOBAL $warnings;
	$node = '';
	$start_gYear = '';
	$end_gYear = '';
	
	//validate dates
	if ($startdate != 0 && is_int($startdate) && $startdate < 3000 ){
		$start_gYear = number_pad($startdate, 4);
	} elseif ($startdate > 3000 || (is_numeric($startdate) && !is_int($startdate))) {
		$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') contains invalid startdate (non-integer or greater than 3000).';
	}
	if ($enddate != 0 && is_int($enddate) && $enddate < 3000 ){
		$end_gYear = number_pad($enddate, 4);
	}  elseif ($enddate > 3000 || (is_numeric($enddate) && !is_int($enddate))) {
		$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') contains invalid enddate (non-integer or greater than 3000).';
	}
	
	if ($startdate == 0 && $enddate != 0){
		$node = '<date' . (strlen($end_gYear) > 0 ? ' standardDate="' . $end_gYear . '"' : '') . '>' . get_date_textual($enddate) . '</date>';
	} elseif ($startdate != 0 && $enddate == 0) {
		$node = '<date' . (strlen($start_gYear) > 0 ? ' standardDate="' . $start_gYear . '"' : '') . '>' . get_date_textual($startdate) . '</date>';
	} elseif ($startdate == $enddate){
		$node = '<date' . (strlen($end_gYear) > 0 ? ' standardDate="' . $end_gYear . '"' : '') . '>' . get_date_textual($enddate) . '</date>';
	} elseif ($startdate != 0 && $enddate != 0){
		$node = '<dateRange><fromDate' . (strlen($start_gYear) > 0 ? ' standardDate="' . $start_gYear . '"' : '') . '>' . get_date_textual($startdate) . '</fromDate><toDate' . (strlen($start_gYear) > 0 ? ' standardDate="' . $end_gYear . '"' : '') . '>' . get_date_textual($enddate) . '</toDate></dateRange>';
	}
	return $node;
}

//pad integer value from Filemaker to create a year that meets the xs:gYear specification
function number_pad($number,$n) {
	if ($number > 0){
		$gYear = str_pad((int) $number,$n,"0",STR_PAD_LEFT);
	} elseif ($number < 0) {
		$bcNum = (int)abs($number) - 1;
		$gYear = '-' . str_pad($bcNum,$n,"0",STR_PAD_LEFT);
	}
	return $gYear;
}

//generate the NUDS node for mint: perform geonames and nomisma lookups to include xlink:href attribute and labels generated from nomisma or geonames
function parse_mint($department, $mint, $regions, $localities){
	GLOBAL $Byzantine_array;
	GLOBAL $Decoration_array;
	GLOBAL $East_Asian_array;
	GLOBAL $Greek_array;
	GLOBAL $Islamic_array;
	GLOBAL $Latin_American_array;
	GLOBAL $Medieval_array;
	GLOBAL $Medal_array;
	GLOBAL $Modern_array;
	GLOBAL $Roman_array;
	GLOBAL $South_Asian_array;
	GLOBAL $United_States_array;

	$geoData = str_replace(' ', '_', $department) . '_array';

	$regions_array = array();
	$localities_array = array();
	$mint_uri = '';

	//create boolean variable to pass to get_mintNode
	$isUncertain = substr($mint, -1) == '?' ? true : false;
	//strip '?' from $mint
	$mint = str_replace('?', '', $mint);

	foreach ($regions as $region){
		$regions_array[] = trim(str_replace('?', '', str_replace('"', '', $region)));
	}
	foreach ($localities as $locality){
		$localities_array[] = trim(str_replace('?', '', str_replace('"', '', $locality)));
	}

	//if there is no region or locality
	if (count($regions_array) == 0 && count($localities_array) == 0){
		$results = array_filter($$geoData, array(new filterGeo($mint, '', ''), 'matches'));

		foreach ($results as $result){
			$nomisma_value = $result['nomisma_id'];
			$label = $result['label'];
		}

		if (strpos($nomisma_value, 'nomisma.org') > 0 || strpos($nomisma_value, 'geonames.org') > 0){
			$mint_uri = $nomisma_value;
		}
	}
	//if there is a region: test for available of locality
	if (count($regions_array) > 0){
		if (count($localities_array) == 0){
			foreach ($regions_array as $rv){
				$results = array_filter($$geoData, array(new filterGeo($mint, $rv, ''), 'matches'));

				foreach ($results as $result){
					$nomisma_value = $result['nomisma_id'];
					$label = $result['label'];
				}

				if (strpos($nomisma_value, 'nomisma.org') > 0 || strpos($nomisma_value, 'geonames.org') > 0){
					$mint_uri = $nomisma_value;
				}
			}
		} else {
			foreach ($regions_array as $rv){
				foreach ($localities_array as $lv) {
					$results = array_filter($$geoData, array(new filterGeo($mint, $rv, $lv), 'matches'));

					foreach ($results as $result){
						$nomisma_value = $result['nomisma_id'];
						$label = $result['label'];
					}

					if (strpos($nomisma_value, 'nomisma.org') > 0 || strpos($nomisma_value, 'geonames.org') > 0){
						$mint_uri = $nomisma_value;
					}
				}
			}
		}
	}
	//if there is a locality but no region:
	if (count($regions_array) == 0 && count($localities_array) > 0){
		foreach ($localities_array as $lv){
			$results = array_filter($$geoData, array(new filterGeo($mint, '', $lv), 'matches'));

			foreach ($results as $result){
				$nomisma_value = $result['nomisma_id'];
				$label = $result['label'];
			}

			if (strpos($nomisma_value, 'nomisma.org') > 0 || strpos($nomisma_value, 'geonames.org') > 0){
				$mint_uri = $nomisma_value;
			}
		}
	}
	if (strlen($mint_uri) > 0){
		if (strlen($label) > 0){
			$label = $label;
		} else {
			$label = $mint;
		}
		$geography = get_mintNode($mint_uri, $label, $isUncertain);
	} else {
		$certainty = $isUncertain == true ? ' certainty="uncertain"' : '';
		$geography['mint'] = '<geogname xlink:type="simple" xlink:role="mint"' . $certainty . '>' . $mint . '</geogname>';
	}
	return $geography;
}

function get_mintNode($mint_uri, $label, $isUncertain){
	if (strpos($mint_uri, 'nomisma.org') > 0){
		$certainty = $isUncertain == true ? ' certainty="uncertain"' : '';
		$geography['mint'] = '<geogname xlink:type="simple" xlink:role="mint" xlink:href="' . $mint_uri . '"' . $certainty . '>' . $label . '</geogname>';
	} elseif (strpos($mint_uri, 'geonames.org') > 0){
		//explode the geonames id, particularly necessary for Latin American coins where the mint varies from country of issue
		$uris = explode('|', $mint_uri);
		$mintUri = trim($uris[0]);
		$regionUri = trim($uris[1]);
		$localityUri = trim($uris[2]);

		$geography['mint'] = process_label($mintUri, $label, 'mint', $isUncertain, 0);
		if (strlen($regionUri) > 0){
			$geography['state'] = process_label($regionUri, $label, 'state', null, 1);
		}
		if (strlen($localityUri) > 0){
			$geography['authority'] = process_label($localityUri, $label, 'authority', null, 2);
		}
	}
	return $geography;
}

/* process_label */
function process_label ($uri, $label, $role, $isUncertain, $pos){
	$uriPieces = explode('/', $uri);
	$geonameId = $uriPieces[3];
	$geonameUri = 'http://www.geonames.org/' . $geonameId . '/';
	$certainty = $isUncertain == true ? ' certainty="uncertain"' : '';
	
	//explode label pieces, display correct one
	$labelPieces = explode('|', trim($label));
	$place_name = trim($labelPieces[$pos]);
	
	if ($role == 'mint'){
		$mintNode = '<geogname xlink:type="simple" xlink:role="mint" xlink:href="' . $geonameUri . '"' . $certainty . '>' . $place_name . '</geogname>';
	} else {
		$mintNode = '<corpname xlink:type="simple" xlink:role="' . $role . '" xlink:href="' . $geonameUri . '">' . $place_name . '</corpname>';
	}

	return $mintNode;
}

function get_department($department){
	//department
	if (strlen(trim($department)) > 0){
		switch (trim(strtoupper($department))) {
			case 'B':
				$dept_string = 'Byzantine';
				break;
			case 'DE':
				$dept_string = 'Decoration';
				break;
			case 'EA':
				$dept_string = 'East Asian';
				break;
			case 'G':
				$dept_string = 'Greek';
				break;
			case 'I':
				$dept_string = 'Islamic';
				break;
			case 'LA':
				$dept_string = 'Latin American';
				break;
			case 'M':
				$dept_string = 'Medieval';
				break;
			case 'ME':
				$dept_string = 'Medal';
				break;
			case 'MO':
				$dept_string = 'Modern';
				break;
			case 'R':
				$dept_string = 'Roman';
				break;
			case 'SA':
				$dept_string = 'South Asian';
				break;
			case 'US':
				$dept_string = 'United States';
				break;
			default:
				$dept_string = 'FAIL';
		}
	}
	return $dept_string;
}

function get_current_ocre_uri($url){
	$doc = new DOMDocument('1.0', 'UTF-8');
	if ($doc->load($url . '.rdf') === FALSE){
		return "FAIL";
	} else {
		$replacements = $doc->getElementsByTagNameNS('http://purl.org/dc/terms/', 'isReplacedBy');
		echo "LENGTH" . $replacements->length . "\n";
		if ($replacements->length == 0){
			return $url;
		} elseif ($replacements->length == 1){
			return $replacements->item(0)->getAttribute('rdf:resource');
		} elseif ($replacements->length > 1) {
			return "FAIL";
		}
	}
}

function get_title_from_rdf($url, $accnum){
	$doc = new DOMDocument();
	//if the rdf cannot be loaded, return FAIL, proceed to generation of typeDesc from Filemaker data
	if ($doc->load($url . '.rdf') === FALSE){
		return "FAIL";
	} else {
		$xpath = new DOMXpath($doc);
		$xpath->registerNamespace('skos', 'http://www.w3.org/2004/02/skos/core#');
		$xpath->registerNamespace('dcterms', 'http://purl.org/dc/terms/');
		$titles = $xpath->query("descendant::skos:prefLabel[@xml:lang='en']|descendant::dcterms:title");
		return '<title xml:lang="en">' . $titles->item(0)->nodeValue . '. ' . $accnum . '</title>';
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

function generate_solr_shell_script($array){
	$uniqid = uniqid();
	$solrDocUrl = 'http://localhost:8080/cocoon/mantis/ingest?identifiers=' . implode('\|', $array);
	$solrUrl = 'http://localhost:8080/solr/numishare-published/update';

	//generate content of bash script
	$sh = "#!/bin/sh\n";
	$sh .= "curl {$solrDocUrl} > /tmp/{$uniqid}.xml\n";
	$sh .= "curl {$solrUrl} --data-binary @/tmp/{$uniqid}.xml -H 'Content-type:text/xml; charset=utf-8'\n";
	$sh .= "curl {$solrUrl} --data-binary '<commit/>' -H 'Content-type:text/xml; charset=utf-8'\n";
	$sh .= "rm /tmp/{$uniqid}.xml\n";

	$shFileName = '/tmp/' . $uniqid . '.sh';
	$file = fopen($shFileName, 'w');
	if ($file){
		fwrite($file, $sh);
		fclose($file);

		//execute script
		shell_exec('sh /tmp/' . $uniqid . '.sh > /dev/null 2>/dev/null &');
		//commented out the line below because PHP seems to delete the file before it has had a chance to run in the shell
		//unlink('/tmp/' . $uniqid . '.sh');
	} else {
		error_log("Unable to create {$uniqid}.sh at " . date(DATE_W3C) . "\n", 3, "/var/log/numishare/error.log");
	}
}

function generate_html_response($csv_id, $accnums, $errors, $warnings, $startTime, $endTime){
	$body = "<html><head><title>Mantis Filemaker-to-NUDS Report for {$csv_id}.csv</title></head>";
	$body .= "<body><h1>Mantis Filemaker-to-NUDS Report for {$csv_id}.csv</h1><p>";
	$body .= "Successful objects: " . count($accnums) . "<br/>\n";
	$body .= "Errors: " . count($errors) . "<br/>\n";
	$body .= "Warnings: " . count($warnings) . "<br/>\n\n";
	$body .= "Start Time: {$startTime}<br/>\n";
	$body .= "End Time: {$endTime}</p>\n\n";

	if(count($errors) > 0){
		$body .= '<p>Errors reported via email.</p>';
	}

	$body .= '</body></html>';

	return $body;
}

function generate_email_report ($csv_id, $accnums, $errors, $warnings, $startTime, $endTime){
	$to = 'database@numismatics.org';
	$subject = "Error report for {$csv_id}.csv";
	$body = "Error Report for {$csv_id}.csv\n\n";
	$body .= "Successful objects: " . count($accnums) . "\n";
	$body .= "Errors: " . count($errors) . "\n";
	$body .= "Warnings: " . count($warnings) . "\n\n";
	$body .= "Start Time: {$startTime}\n";
	$body .= "End Time: {$endTime}\n\n";
	$body .= "The following accession numbers failed to process:\n\n";
	foreach ($errors as $error){
		$body .= $error . "\n";
	}
	$body .= "\nThe following warnings were recorded:\n\n";
	foreach ($warnings as $warning){
		$body .= $warning . "\n";
	}
	$body .= "\nNote that records with warnings likely did upload to Mantis, but offending data have been removed.\n";
	mail($to, $subject, $body);
}

function url_exists($url) {
	if (!$fp = curl_init($url)) return false;
	return true;
}

class filterGeo {
	private $mv;
	private $rv;
	private $lv;

	function __construct($mv, $rv, $lv) {
		$this->mint = $mv;
		$this->region = $rv;
		$this->locality = $lv;
	}

	function matches($m) {
		return $m['mint'] == $this->mint && $m['region'] == $this->region && $m['locality'] == $this->locality;
	}
}

?>