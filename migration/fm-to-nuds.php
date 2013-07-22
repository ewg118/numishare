<?php
/************************
 AUTHOR: Ethan Gruber
MODIFIED: August, 2012
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
ignore_user_abort(true);
set_time_limit(0);

//get unique id of recently uploaded Filemaker CSV from request parameter
$csv_id = $_GET['id'];

//create an array with pre-defined labels and values passed from the Filemaker POST
$labels = array("accnum","department","objtype","material","manufacture","shape","weight","measurements","axis","denomination","era","dob","startdate","enddate","refs","published","info","prevcoll","region","locality","series","dynasty","mint","mintabbr","person","issuer","magistrate","maker","artist","sernum","subjevent","subjperson","subjissuer","subjplace","decoration","degree","findspot","obverselegend","obversetype","reverselegend","reversetype","color","edge","undertype","counterstamp","conservation","symbol","obversesymbol","reversesymbol","signature","watermark","dlu","drc","imageavailable","citation","collectionabbr","accyr","accgrp","accseq","keywords","category","imagesponsor");
$geoURIs = array();
$errors = array();
$warnings = array();
$deityMatchArray = get_deity_array();

//load Google Spreadsheets
//mints
$Byzantine_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdGJSRFhnR3ZKbHo2bG5oV0pDSzBBRnc&single=true&gid=0&output=csv');
$Decoration_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdG1MbV9PcGMzTUU1dWU2by1sNWNnbGc&single=true&gid=0&output=csv');
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

//$csv = "'1944.100.5883','US','C','AE','Struck','','8.54','','12','Nummus?','','','10','15','RIC','','','','United States','California','<RIC.6>','','San Francisco?','','Diocletian?','Issuer1|Issuer2?','','','Artist (obv.)(rev.)|Artist 2 (rev.)|Artist 3','','','','','','','','','','','GENIO POPVLI ROMANI','Genius stg. l., holding patera and cornucopiae','','','','','','','','B\Gamma:TR','','','2/22/2012','','yes','Bequest of E.T. Newell','N','1944','100','5883','ae nummus ric 171a diocletian trier ric 6 genio popvli romani genius stg l holding patera and cornucopiae b gamma tr','Roman--Imperial',''";
if (($handle = fopen("/tmp/" . $csv_id . ".csv", "r")) !== FALSE) {
	$accnums = array();
	$startTime = date(DATE_W3C);
	$row = 1;
	while (($data = fgetcsv($handle, 1000, ",", "'")) !== FALSE) {
		//$data = str_getcsv($csv, ',', "'", null);
		$values_with_labels = array();
		foreach ($labels as $key=>$label){
			//escape conflicting XML characters
			$values_with_labels[$label] = str_replace('>', '&gt;', str_replace('<', '&lt;', str_replace('&', 'and', $data[$key])));
		}

		if (trim(strtoupper($values_with_labels['department'])) != 'J'){
			//create new filename path
			$collection = 'mantis';
			$department = get_department($values_with_labels['department']);
			$accPieces = explode('.', trim($values_with_labels['accnum']));
			$accYear = $accPieces[0];
			$accnum = trim($values_with_labels['accnum']);
			$fileName = '/tmp/' . $accnum . '.xml';

			//call function to generate xml
			//echo $row . ": Processing " . $accnum . ": "

			//provide error handling for $accnums that lack values
			if (strlen($accnum) == 0){
				//echo "FAIL.\n";
				error_log('[no accnum] (' . $department . ') record lacks accession number: ' . date(DATE_W3C) . "\n", 3, "/var/log/numishare/error.log");
				$errors[] = '(' . $department . ') record lacks accession number: ' . date(DATE_W3C);
			} else {
				$xml = generate_nuds($values_with_labels, $row);

				//load DOMDocument
				$dom = new DOMDocument('1.0', 'UTF-8');
				if ($dom->loadXML($xml) === FALSE){
					//echo "FAIL.\n";
					error_log($accnum . ' (' . $department . ') failed to validate in DOMDocument at ' . date(DATE_W3C) . "\n", 3, "/var/log/numishare/error.log");
					$errors[] = $accnum . ' (' . $department . ') failed to validate in DOMDocument at ' . date(DATE_W3C);
				} else {
					$dom->preserveWhiteSpace = FALSE;
					$dom->formatOutput = TRUE;
					//echo $dom->saveXML();
					$dom->save($fileName);

					//read file back into memory for PUT to eXist
					if (($readFile = fopen($fileName, 'r')) === FALSE){
						//echo "FAIL.\n";
						error_log($accnum . ' (' . $department . ') failed to open temporary file (accnum likely broken) at ' . date(DATE_W3C) . "\n", 3, "/var/log/numishare/error.log");
						$errors[] = $accnum . ' (' . $department . ') failed to open temporary file (accnum likely broken) at ' . date(DATE_W3C);
					} else {
						//PUT xml to eXist
						$putToExist=curl_init();

						//set curl opts
						curl_setopt($putToExist,CURLOPT_URL,'http://localhost:8080/orbeon/exist/rest/db/' . $collection . '/objects/' . $accYear . '/' . $accnum . '.xml');
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
							//echo "FAIL.\n";
							error_log($accnum . ' (' . $department . ') failed to upload to eXist at ' . date(DATE_W3C) . "\n", 3, "/var/log/numishare/error.log");
							$errors[] = $accnum . ' (' . $department . ') failed to upload to eXist at ' . date(DATE_W3C);
						}
						else {
							if ($http_code == '201'){
								//echo "SUCCESS.\n";
								error_log($accnum . ' posted to eXist at ' . date(DATE_W3C) . "\n", 3, "/var/log/numishare/success.log");

								//if file was successfully PUT to eXist, add the accession number to the array for Solr indexing.
								$accnums[] = trim($values_with_labels['accnum']);

								//index records into Solr in increments of 5,000
								if (count($accnums) > 0 && count($accnums) % 5000 == 0 ){
									$start = count($accnums) - 5000;
									$toIndex = array_slice($accnums, $start, 5000);

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
		$row++;
	}


	//execute process for remaining accnums.
	$start = floor(count($accnums) / 5000) * 5000;
	$toIndex = array_slice($accnums, $start);

	//POST TO SOLR
	generate_solr_shell_script($toIndex);

	$endTime = date(DATE_W3C);

	//generate HTML response
	echo generate_html_response($csv_id, $accnums, $errors, $warnings, $startTime, $endTime);

	//send email if there are errors
	if (count($errors) > 0){
		generate_email_report($csv_id, $accnums, $errors, $warnings, $startTime, $endTime);
	}

	fclose($handle);
}

/****** GENERATE NUDS ******/
function generate_nuds($values_with_labels, $row){
	GLOBAL $deityMatchArray;
	GLOBAL $warnings;

	//generate collection year for images
	$accnum = trim($values_with_labels['accnum']);
	$accession_array = explode('.', $accnum);
	$collection_year = $accession_array[0];

	//department
	$department = get_department($values_with_labels['department']);

	//define variables that are used to comprise the unittitle
	//dates
	$startdate_int = trim($values_with_labels['startdate']) * 1;
	$enddate_int = trim($values_with_labels['enddate']) * 1;
	if (trim($values_with_labels['startdate']) != '' || trim($values_with_labels['enddate']) != ''){
		$fromDate_textual = get_date_textual($startdate_int);
		$toDate_textual = get_date_textual($enddate_int);
		$date_textual = $fromDate_textual . (strlen($fromDate_textual) > 0 && strlen($toDate_textual) > 0 ? ' - ' : '' ) . $toDate_textual;
		$date = get_date($startdate_int, $enddate_int, $date_textual, $fromDate_textual, $toDate_textual, $accnum, $row, $department);
	}

	//facets
	$denominations = explode('|', $values_with_labels['denomination']);
	$materials = explode('|', $values_with_labels['material']);
	$mints = explode('|', $values_with_labels['mint']);
	$regions = explode('|', $values_with_labels['region']);
	$localities = explode('|', $values_with_labels['locality']);
	$issuers = explode('|', $values_with_labels['issuer']);
	$artists = explode('|', $values_with_labels['artist']);

	//references; used to check for 'ric.' for pointing typeDesc to OCRE
	$refs = explode('|', $values_with_labels['refs']);

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
	//array of cleaned labels for title elements
	$title_elements = array();

	$geogAuthorities = array();

	switch (trim(strtoupper($values_with_labels['objtype']))) {
		case 'C':
			$objtype = 'Coin';
			$objtype_uri = 'http://nomisma.org/id/coin';
			break;
		case 'DE':
			$objtype = 'Decoration';
			break;
		case 'P':
			$objtype = 'Paper';
			break;
		case 'T':
			$objtype = 'Token';
			$objtype_uri = 'http://nomisma.org/id/token';
			break;
		case 'ME':
			$objtype = 'Medal';
			$objtype_uri = 'http://nomisma.org/id/medal';
			break;
		default:
			$objtype = trim(strtoupper($values_with_labels['objtype']));
	}

	$xml = '<?xml version="1.0" encoding="UTF-8"?><nuds xmlns="http://nomisma.org/nuds" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mets="http://www.loc.gov/METS/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" recordType="physical">';
	$xml .= "<nudsHeader><nudsid>" . $accnum . "</nudsid>";
	$xml .= '<publicationStmt><publisher>American Numismatic Society</publisher><createdBy>Ethan Gruber</createdBy><date standardDateTime="' . date(DATE_W3C) . '"></date>';
	$xml .= '<langUsage><language langcode="eng">English</language></langUsage>';
	$xml .= '</publicationStmt><rightsStmt><copyrightHolder>American Numismatic Society</copyrightHolder><date standardDate="2012">2012</date></rightsStmt>';
	$xml .= "</nudsHeader>";
	$xml .= '<descMeta>';
	$xml .= '<department>' . $department . '</department>';

	//subjects
	if (strlen(trim($values_with_labels['category'])) > 0 || strlen(trim($values_with_labels['series'])) > 0 || strlen(trim($values_with_labels['subjevent'])) > 0 || strlen(trim($values_with_labels['subjissuer'])) > 0 || strlen(trim($values_with_labels['subjperson'])) > 0 || strlen(trim($values_with_labels['subjplace'])) > 0 || strlen(trim($values_with_labels['degree'])) > 0 || strlen(trim($values_with_labels['era'])) > 0){
		$xml .= '<subjectSet>';
		if (strlen(trim($values_with_labels['category'])) > 0){
			$xml .= '<subject type="category">' . trim($values_with_labels['category']) . '</subject>';
		}
		if (strlen(trim($values_with_labels['series'])) > 0){
			$serieses = explode('|', $values_with_labels['series']);
			foreach ($serieses as $series){
				$xml .= '<subject type="series">' . trim($series) . '</subject>';
			}
		}
		if (strlen(trim($values_with_labels['subjevent'])) > 0){
			$subjEvents = explode('|', $values_with_labels['subjevent']);
			foreach ($subjEvents as $subjEvent){
				$xml .= '<subject type="subjectEvent">' . trim($subjEvent) . '</subject>';
			}
		}
		if (strlen(trim($values_with_labels['subjissuer'])) > 0){
			$subjIssuers = explode('|', $values_with_labels['subjissuer']);
			foreach ($subjIssuers as $subjIssuer){
				$xml .= '<subject type="subjectIssuer">' . trim($subjIssuer) . '</subject>';
			}
		}
		if (strlen(trim($values_with_labels['subjperson'])) > 0){
			$subjPersons = explode('|', $values_with_labels['subjperson']);
			foreach ($subjPersons as $subjPerson){
				$xml .= '<subject type="subjectPerson">' . trim($subjPerson) . '</subject>';
			}
		}
		if (strlen(trim($values_with_labels['subjplace'])) > 0){
			$subjPlaces = explode('|', $values_with_labels['subjplace']);
			foreach ($subjPlaces as $subjPlace){
				$xml .= '<subject type="subjectPlace">' . trim($subjPlace) . '</subject>';
			}
		}
		if (strlen(trim($values_with_labels['era'])) > 0){
			$eras = explode('|', $values_with_labels['era']);
			foreach ($eras as $era){
				$xml .= '<subject type="era">' . trim($era) . '</subject>';
			}
		}
		//degree
		if (strlen(trim($values_with_labels['degree'])) > 0){
			$degrees = explode('|', $values_with_labels['degree']);
			foreach ($degrees as $degree){
				$xml .= '<subject type="degree">' . trim($degree) . '</subject>';
			}
		}
		$xml .= '</subjectSet>';
	}
	//notes
	if (strlen(trim($values_with_labels['info'])) > 0){
		$infos = explode('|', $values_with_labels['info']);
		$xml .= '<noteSet>';
		foreach ($infos as $info){
			$xml .= '<note>' . trim($info) . '</note>';
		}
		$xml .= '</noteSet>';
	}

	/************ typeDesc ***************/
	//if the coin is Roman and contains 'ric.' as a reference, point the typeDesc to OCRE
	//supported nomisma-style strings are: ric.1., ric.1(2)., ric.2_1(2)., ric.3.
	$ocre_id = array();
	if (count(preg_grep('/ric\.1\./', $refs)) > 0 || count(preg_grep('/ric\.1\(2\)\./', $refs)) > 0 || count(preg_grep('/ric\.2_1\(2\)\./', $refs)) > 0 || count(preg_grep('/ric\.2\./', $refs)) > 0 || count(preg_grep('/ric\.3\./', $refs)) > 0){
		$ocre_id = preg_grep('/ric\./', $refs);

		//if there is a value, include xlink:href otherwise generate typeDesc from CSV data
		if(strlen($ocre_id[0]) > 0){
			$xml .= '<typeDesc xlink:type="simple" xlink:href="http://numismatics.org/ocre/id/' . $ocre_id[0] . '">';
		}
	} else {
		$xml .= '<typeDesc>';
	}

	//fill in other typeDesc metadata
	if(strlen($ocre_id[0]) <= 0){
		$xml .= '<objectType xlink:href="' . $objtype_uri . '">' . $objtype . '</objectType>';
		//date

		if (strlen($date) > 0){
			$xml .= $date;
		}
		//denomination
		if (strlen($values_with_labels['denomination']) > 0){
			foreach ($denominations as $denomination){
				$val = trim(str_replace('"', '', $denomination));
				$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
				$xml .= '<denomination' . $certainty . '>' . trim(str_replace('?', '', $val)) . '</denomination>';
					
				//insert material
				$title_elements['denomination'] = trim(str_replace('?', '', $val));
			}
		}
		//manufacture
		if (strlen($values_with_labels['manufacture']) > 0){
			$manufactures = explode('|', $values_with_labels['manufacture']);
			foreach ($manufactures as $manufacture){
				$val = trim(str_replace('"', '', $manufacture));
				$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
				$xml .= '<manufacture' . $certainty . '>' . trim(str_replace('?', '', $val)) . '</manufacture>';
			}
		}
		//material
		if (strlen($values_with_labels['material']) > 0){
			foreach ($materials as $material){
				$material_string = get_material_label(trim($material));
				$mat_array = normalize_material(trim($material));
				if (strlen($mat_array['uri']) > 0){
					$xml .= '<material xlink:href="' . $mat_array['uri'] . '">' . $material_string . '</material>';
				} else {
					$xml .= '<material>' . $material_string . '</material>';
				}
					
				//insert material
				$title_elements['material'] = $material_string;
			}
		}
		//obverse
		if (strlen($values_with_labels['obverselegend']) > 0 || strlen($values_with_labels['obversesymbol']) > 0 || strlen($values_with_labels['obversetype']) > 0 || count($artists_obv) > 0){
			$xml .= '<obverse>';
			//obverselegend
			if (strlen($values_with_labels['obverselegend']) > 0){
				$xml .= '<legend>' . trim($values_with_labels['obverselegend']) . '</legend>';
			}
			//obversesymbol
			if (strlen($values_with_labels['obversesymbol']) > 0){
				$xml .= '<symbol>' . trim($values_with_labels['obversesymbol']) . '</symbol>';
			}
			//obversetype
			if (strlen($values_with_labels['obversetype']) > 0){
				$xml .= '<type><description xml:lang="en">' . trim($values_with_labels['obversetype']) . '</description></type>';
			}
			//artist
			foreach ($artists_obv as $artist){
				//WORK ON ARTIST OBV/REV
				$certainty = substr($artist, -1) == '?' ? ' certainty="uncertain"' : '';
				$xml .= '<persname xlink:role="artist"' . $certainty . '>' . str_replace('?', '', $artist) . '</persname>';
			}
			if ($department == 'Greek' || $department == 'Roman'){
				$haystack = strtolower($values_with_labels['obversetype']);
				foreach($deityMatchArray as $match=>$name){
					if ($name != 'Hera' && $name != 'Sol' && strlen(strstr($haystack,strtolower($match)))>0) {
						$xml .= '<persname xlink:role="deity">' . $name . '</persname>';
					}
					//Hera and Sol need special cases because they are commonly part of other works, eg Herakles, soldiers
					elseif ($name == 'Hera' && strlen(strstr($haystack,strtolower($match . ' ')))>0){
						$xml .= '<persname xlink:role="deity">' . $name . '</persname>';
					}
					elseif ($name == 'Sol' && strlen(strstr($haystack,strtolower($match . ' ')))>0){
						$xml .= '<persname xlink:role="deity">' . $name . '</persname>';
					}
				}
			}
			$xml .= '</obverse>';
		}

		//reverse
		if (strlen($values_with_labels['reverselegend']) > 0 || strlen($values_with_labels['reversesymbol']) > 0 || strlen($values_with_labels['reversetype']) > 0 || count($artists_rev) > 0){
			$xml .= '<reverse>';
			//reverselegend
			if (strlen($values_with_labels['reverselegend']) > 0){
				$xml .= '<legend>' . trim($values_with_labels['reverselegend']) . '</legend>';
			}
			//reversesymbol
			if (strlen($values_with_labels['reversesymbol']) > 0){
				$xml .= '<symbol>' . trim($values_with_labels['reversesymbol']) . '</symbol>';
			}
			//reversetype
			if (strlen($values_with_labels['reversetype']) > 0){
				$xml .= '<type><description xml:lang="en">' . trim($values_with_labels['reversetype']) . '</description></type>';
			}
			//artist
			foreach ($artists_rev as $artist){
				//WORK ON ARTIST OBV/REV
				$certainty = substr($artist, -1) == '?' ? ' certainty="uncertain"' : '';
				$xml .= '<persname xlink:role="artist"' . $certainty . '>' . str_replace('?', '', $artist) . '</persname>';
			}
			if ($department == 'Greek' || $department == 'Roman'){
				$haystack = strtolower($values_with_labels['reversetype']);
				foreach($deityMatchArray as $match=>$name){
					if ($name != 'Hera' && $name != 'Sol' && strlen(strstr($haystack,strtolower($match)))>0) {
						$xml .= '<persname xlink:role="deity">' . $name . '</persname>';
					}
					//Hera and Sol need special cases because they are commonly part of other works, eg Herakles, soldiers
					elseif ($name == 'Hera' && strlen(strstr($haystack,strtolower($match . ' ')))>0){
						$xml .= '<persname xlink:role="deity">' . $name . '</persname>';
					}
					elseif ($name == 'Sol' && strlen(strstr($haystack,strtolower($match . ' ')))>0){
						$xml .= '<persname xlink:role="deity">' . $name . '</persname>';
					}
				}
			}
			$xml .= '</reverse>';
		}
		//edge
		if (strlen(trim($values_with_labels['edge'])) > 0){
			$xml .= '<edge><description>' . trim($values_with_labels['edge']) . '</description></edge>';
		}

		/***** GEOGRAPHICAL LOCATIONS *****/
		if (strlen(trim($values_with_labels['mint'])) > 0 || strlen(trim($values_with_labels['region'])) > 0 || strlen(trim($values_with_labels['locality'])) > 0){
			$xml .= '<geographic>';
			if (strlen(trim($values_with_labels['mint'])) > 0){
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
			if (strlen(trim($values_with_labels['region'])) > 0){
				$regions_cleaned = array();
				foreach ($regions as $region){
					$val = trim(str_replace('"', '', $region));
					$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
					$xml .= '<geogname xlink:role="region"' . $certainty . '>' . trim(str_replace('?', '', $val)) . '</geogname>';
					$regions_cleaned[] = trim(str_replace('?', '', $val));
				}
				if (strlen(trim($values_with_labels['mint'])) == 0){
					$title_elements['location'] = implode('/', $regions_cleaned);
				}
			}
			//locality
			if (strlen(trim($values_with_labels['locality'])) > 0){
				$localities_cleaned = array();
				foreach ($localities as $locality){
					$val = trim(str_replace('"', '', $locality));
					$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
					$xml .= '<geogname xlink:role="locality"' . $certainty . '>' . trim(str_replace('?', '', $val)) . '</geogname>';
					$localities_cleaned[] = trim(str_replace('?', '', $val));
				}
				if (strlen(trim($values_with_labels['mint'])) == 0 && strlen(trim($values_with_labels['region'])) == 0){
					$title_elements['location'] = implode('/', $localities_cleaned);
				}
			}

			$xml .= '</geographic>';
		}

		/***** AUTHORITIES AND PERSONS *****/
		if (strlen($geogAuthorities['state']) > 0 || strlen($geogAuthorities['authority']) > 0 || strlen($values_with_labels['person']) > 0 || strlen($values_with_labels['issuer']) > 0 || strlen($values_with_labels['magistrate']) > 0 || strlen($values_with_labels['maker']) > 0 ||  count($artists_none) > 0){
			$xml .= '<authority>';
			//insert authorities parsed out from the mint lookups (applies primarily to Latin America)
			if (strlen($geogAuthorities['state']) > 0){
				$xml .= $geogAuthorities['state'];
			}
			if (strlen($geogAuthorities['authority']) > 0){
				$xml .= $geogAuthorities['authority'];
			}
			//issuer
			if (strlen(trim($values_with_labels['issuer'])) > 0){
				$issuers_cleaned = array();
				foreach ($issuers as $issuer){
					$val = trim(str_replace('"', '', $issuer));
					$certainty = substr($val, -1) == '?' ? ' certainty="uncertain"' : '';
					if ($department == 'Islamic' || $department == 'Greek' || $department == 'Medieval' || $department == 'Byzantine' || $department == 'Roman'){
						$xml .= '<persname xlink:role="issuer"' . $certainty . '>' . trim(str_replace('?', '', $val)) . '</persname>';
					}
					else {
						$xml .= '<corpname xlink:role="issuer"' . $certainty . '>' . trim(str_replace('?', '', $val)) . '</corpname>';
					}
					$issuers_cleaned[] = trim(str_replace('?', '', $val));
				}
				$title_elements['issuer'] = implode('/', $issuers_cleaned);
			}
			//artist
			foreach ($artists_none as $artist){
				//WORK ON ARTIST OBV/REV
				$certainty = substr($artist, -1) == '?' ? ' certainty="uncertain"' : '';
				$xml .= '<persname xlink:role="artist"' . $certainty . '>' . str_replace('?', '', $artist) . '</persname>';
			}
			//maker
			if (strlen(trim($values_with_labels['maker'])) > 0){
				$makers = explode('|', $values_with_labels['maker']);
				foreach ($makers as $maker){
					$certainty = substr(trim(str_replace('"', '', $maker)), -1) == '?' ? ' certainty="uncertain"' : '';
					$xml .= '<corpname xlink:role="maker"' . $certainty . '>' . str_replace('?', '', $maker) . '</corpname>';
				}
			}
			//magistrate
			if (strlen(trim($values_with_labels['magistrate'])) > 0){
				$magistrates = explode('|', $values_with_labels['magistrate']);
				foreach ($magistrates as $magistrate){
					$certainty = substr(trim(str_replace('"', '', $magistrate)), -1) == '?' ? ' certainty="uncertain"' : '';
					$xml .= '<persname xlink:role="issuer" title="magistrate"' . $certainty . '>' . str_replace('?', '', $magistrate) . '</persname>';
				}
			}
			//person: portrait
			if (strlen(trim($values_with_labels['person'])) > 0){
				$persons = explode('|', $values_with_labels['person']);
				foreach ($persons as $person){
					$certainty = substr(trim(str_replace('"', '', $person)), -1) == '?' ? ' certainty="uncertain"' : '';
					$xml .= '<persname xlink:role="portrait"' . $certainty . '>' . str_replace('?', '', $person) . '</persname>';
				}
			}
			$xml .= '</authority>';
		}
	}
	$xml .= '</typeDesc>';




	/***** UNDERTYPE DESCRIPTION *****/
	if (trim($values_with_labels['undertype']) != ''){
		$xml .= '<undertypeDesc><description xml:lang="en">' . trim($values_with_labels['undertype']) . '</description></undertypeDesc>';
	}

	/***** PHYSICAL DESCRIPTION *****/
	$xml .= '<physDesc>';

	//axis: only create if it's an integer
	$axis = (int) $values_with_labels['axis'];
	if (is_int($axis) && $axis <= 12){
		$xml .= '<axis>' . $axis . '</axis>';
	} elseif((strlen($axis) > 0 && !is_int($axis)) || $axis > 12){
		$warnings[] = 'Line ' . $row . ': ' . $accnum . ' (' . $department . ') has non-integer axis or value exceeding 12.';
	}

	//color
	if (strlen($values_with_labels['color']) > 0){
		$colors = explode('|', $values_with_labels['color']);
		foreach ($colors as $color){
			$xml .= '<color>' . trim($color) . '</color>';
		}
	}
	//dob
	if (strlen(trim($values_with_labels['dob'])) > 0){
		$xml .= '<dateOnObject><date>' . trim($values_with_labels['dob']) . '</date></dateOnObject>';
	}
	//sernum
	if (strlen(trim($values_with_labels['sernum'])) > 0){
		$xml .= '<serialNumber>' . trim($values_with_labels['sernum']) . '</serialNumber>';
	}
	//watermark
	if (strlen(trim($values_with_labels['watermark'])) > 0){
		$xml .= '<watermark>' . trim($values_with_labels['watermark']) . '</watermark>';
	}
	//shape
	if (strlen(trim($values_with_labels['shape'])) > 0){
		$xml .= '<shape>' . trim($values_with_labels['shape']) . '</shape>';
	}
	//signature
	if (strlen(trim($values_with_labels['signature'])) > 0){
		$xml .= '<signature>' . trim($values_with_labels['signature']) . '</signature>';
	}
	//counterstamp
	if (strlen(trim($values_with_labels['counterstamp'])) > 0){
		$xml .= '<countermark><description xml:lang="en">' . trim($values_with_labels['counterstamp']) . '</description></countermark>';
	}
	//create measurementsSet, if applicable
	if ((is_numeric(trim($values_with_labels['weight'])) && trim($values_with_labels['weight']) > 0) || (is_numeric(trim($values_with_labels['measurements'])) && trim($values_with_labels['weight']) > 0)){
		$xml .= '<measurementsSet>';
		//weight
		$weight = trim($values_with_labels['weight']);
		if (is_numeric($weight) && $weight > 0){
			$xml .= '<weight units="g">' . $weight . '</weight>';
		} elseif(!is_numeric($weight) && strlen($weight) > 0){
			$warnings[] = 'Line ' . $row . ': ' . $accnum . ' (' . $department . ') has non-numeric weight.';
		}
		//diameter
		$diameter = trim($values_with_labels['measurements']);
		if (is_numeric($diameter) && $diameter > 0){
			$xml .= '<diameter units="mm">' . $diameter . '</diameter>';
		} elseif(!is_numeric($diameter) && strlen($diameter) > 0){
			$warnings[] = 'Line ' . $row . ': ' . $accnum . ' (' . $department . ') has non-numeric measurements.';
		}
		$xml .= '</measurementsSet>';
	}
	//conservationState
	if (strlen(trim($values_with_labels['conservation'])) > 0){
		$xml .= '<conservationState><description xml:lang="en">' . trim($values_with_labels['conservation']) . '</description></conservationState>';
	}
	$xml .= '</physDesc>';

	/***** ADMINSTRATIVE DESCRIPTION *****/
	$xml .= '<adminDesc>';
	$xml .= '<identifier>' . $accnum . '</identifier>';

	if (strlen(trim($values_with_labels['citation'])) > 0){
		$xml .= '<acqinfo><acquiredFrom>' . trim($values_with_labels['citation']) . '</acquiredFrom></acqinfo>';
	}

	if (strlen(trim($values_with_labels['imagesponsor'])) > 0){
		$xml .= '<acknowledgment>' . trim($values_with_labels['imagesponsor']) . '</acknowledgment>';
	}
	//custhodhist
	if (strlen(trim($values_with_labels['prevcoll'])) > 0){
		$prevcolls = explode('|', $values_with_labels['prevcoll']);
		$xml .= '<custodhist><chronlist>';
		foreach ($prevcolls as $prevcoll){
			if (!is_int($prevcoll)){
				$xml .= '<chronitem><previousColl>' . trim($prevcoll) . '</previousColl></chronitem>';
			}
		}
		$xml .= '</chronlist></custodhist>';
	}

	$xml .= '</adminDesc>';

	/***** BIBLIOGRAPHIC DESCRIPTION *****/
	if (strlen(trim($values_with_labels['refs'])) > 0 || strlen(trim($values_with_labels['published'])) > 0){
		$xml .= '<refDesc>';
		//reference
		if (strlen(trim($values_with_labels['refs'])) > 0){
			foreach ($refs as $ref){
				$xml .= '<reference>' . trim($ref) . '</reference>';
			}
		}

		//citation
		if (strlen(trim($values_with_labels['published'])) > 0){
			$publisheds = explode('|', $values_with_labels['published']);
			foreach ($publisheds as $published){
				$xml .= '<citation>' . trim($published) . '</citation>';
			}
		}
		$xml .= '</refDesc>';
	}

	/***** FINDSPOT DESCRIPTION *****/
	if (strlen(trim($values_with_labels['findspot'])) > 0){
		$xml .= '<findspotDesc><geogname xlink:role="findspot">' . trim($values_with_labels['findspot']) . '</geogname></findspotDesc>';
	}

	/***** TITLE *****/
	$title = '';
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
	if (strlen($date_textual) > 0){
		$title .= ', ';
		$title .= $date_textual;
	}
	$title .= '. ' . $accnum;

	$xml .= '<title>' . $title . '</title>';
	$xml .= '</descMeta>';

	/***** IMAGES AVAILABLE *****/

	if (strlen(trim($values_with_labels['imageavailable'])) > 0){
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
	if (trim($values_with_labels['symbol']) != ''){
	$xml .= '<physfacet type="symbol">' . trim($values_with_labels['symbol']) . '</physfacet>';
	}
	*/
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
			$mat_array['label'] = 'Bronze';
			$mat_array['uri'] = 'http://nomisma.org/id/ae';
			break;
		case 'AV':
			$mat_array['label'] = 'Gold';
			$mat_array['uri'] = 'http://nomisma.org/id/av';
			break;
		case 'AR':
			$mat_array['label'] = 'Silver';
			$mat_array['uri'] = 'http://nomisma.org/id/ar';
			break;
		case 'BRONZE':
			$mat_array['label'] = 'Bronze';
			$mat_array['uri'] = 'http://nomisma.org/id/ae';
			break;
		case 'GOLD':
			$mat_array['label'] = 'Gold';
			$mat_array['uri'] = 'http://nomisma.org/id/av';
			break;
		case 'SILVER':
			$mat_array['label'] = 'Silver';
			$mat_array['uri'] = 'http://nomisma.org/id/ar';
			break;
		case 'ELECTRUM':
			$mat_array['label'] = 'Electrum';
			$mat_array['uri'] = 'http://nomisma.org/id/el';
			break;
		case 'PB':
			$mat_array['label'] = 'Lead';
			break;
		default:
			$mat_array['label'] = strtoupper($material);
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

function get_date($startdate, $enddate, $date_textual, $fromDate_textual, $toDate_textual, $accnum, $row, $department){
	GLOBAL $warnings;

	//validate dates
	if ($startdate != 0 && is_int($startdate) && $startdate < 3000 ){
		$start_gYear = number_pad($startdate, 4);
	} elseif ($startdate > 3000 || (is_numeric($startdate) && !is_int($startdate))) {
		$warnings[] = 'Line ' . $row . ': ' . $accnum . ' (' . $department . ') contains invalid startdate (non-integer or greater than 3000).';
	}
	if ($enddate != 0 && is_int($enddate) && $enddate < 3000 ){
		$end_gYear = number_pad($enddate, 4);
	}  elseif ($enddate > 3000 || (is_numeric($enddate) && !is_int($enddate))) {
		$warnings[] = 'Line ' . $row . ': ' . $accnum . ' (' . $department . ') contains invalid enddate (non-integer or greater than 3000).';
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
			}

			if (strpos($nomisma_value, 'nomisma.org') > 0 || strpos($nomisma_value, 'geonames.org') > 0){
				$mint_uri = $nomisma_value;
			}
		}
	}
	if (strlen($mint_uri) > 0){
		$geography = get_mintNode($mint_uri, $isUncertain);
	} else {
		$certainty = substr($mint, -1) == '?' ? ' certainty="uncertain"' : '';
		$geography['mint'] = '<geogname xlink:role="mint"' . $certainty . '>' . $mint . '</geogname>';
	}
	return $geography;
}

function get_mintNode($mint_uri, $isUncertain){
	GLOBAL $geoURIs;

	if (strpos($mint_uri, 'nomisma.org') > 0){
		//if the $mint_uri is already in the geoURIs array, get the label, else query nomisma and push to array
		if (in_array($mint_uri, $geoURIs)){
			$geography['mint'] = '<geogname xlink:role="mint" xlink:href="' . $mint_uri . '">' . array_search($mint_uri, $geoURIs) . '</geogname>';
		} else {
			$xmlDoc = new DOMDocument();
			$xmlDoc->load('http://www.w3.org/2012/pyRdfa/extract?format=xml&uri=' . urlencode($mint_uri));
			$xpath = new DOMXpath($xmlDoc);
			$xpath->registerNamespace('skos', 'http://www.w3.org/2004/02/skos/core#');
			$prefLabels = $xpath->query("descendant::skos:prefLabel[@xml:lang='en']");
			$geoURIs[$prefLabels->item(0)->nodeValue] = $mint_uri;
			$certainty = $isUncertain == true ? ' certainty="uncertain"' : '';
			$geography['mint'] = '<geogname xlink:role="mint" xlink:href="' . $mint_uri . '"' . $certainty . '>' . $prefLabels->item(0)->nodeValue . '</geogname>';
		}

	} elseif (strpos($mint_uri, 'geonames.org') > 0){
		//explode the geonames id, particularly necessary for Latin American coins where the mint varies from country of issue
		$uris = explode('|', $mint_uri);
		$mintUri = trim($uris[0]);
		$regionUri = trim($uris[1]);
		$localityUri = trim($uris[2]);

		$geography['mint'] = query_geonames($mintUri, 'mint', $isUncertain);
		if (strlen($regionUri) > 0){
			$geography['state'] = query_geonames($regionUri, 'state');
		}
		if (strlen($localityUri) > 0){
			$geography['authority'] = query_geonames($localityUri, 'authority');
		}
	}
	return $geography;
}

/* query_geonames
 * Accept a geonames URI and xlink:role to generate the label from geonames data
* and the NUDS element based on the role
*/
function query_geonames ($uri, $role, $isUncertain){
	GLOBAL $geoURIs;
	$api_key = 'anscoins';
	$uriPieces = explode('/', $uri);
	$geonameId = $uriPieces[3];
	$geonameUri = 'http://www.geonames.org/' . $geonameId . '/';
	$certainty = $isUncertain == true ? ' certainty="uncertain"' : '';

	//if the geonameUri is already in the $geoURIs array
	if (in_array($geonameUri, $geoURIs)){
		if ($role == 'mint'){
			$mintNode = '<geogname xlink:role="mint" xlink:href="' . $geonameUri . '"' . $certainty . '>' . array_search($geonameUri, $geoURIs) . '</geogname>';
		} else {
			$mintNode = '<corpname xlink:role="' . $role . '" xlink:href="' . $geonameUri . '">' . array_search($geonameUri, $geoURIs) . '</corpname>';
		}
	} else {
		//query geonames
		$xmlDoc = new DOMDocument();
		$xmlDoc->load('http://api.geonames.org/get?geonameId=' . $geonameId . '&username=' . $api_key . '&style=full');
		$xpath = new DOMXpath($xmlDoc);
		$countryCode = $xpath->query('descendant::countryCode')->item(0)->nodeValue;
		$countryName = $xpath->query('descendant::countryName')->item(0)->nodeValue;
		$name = $xpath->query('descendant::name')->item(0)->nodeValue;
		$adminName1 = $xpath->query('descendant::adminName1')->item(0)->nodeValue;
		$fcode = $xpath->query('descendant::fcode')->item(0)->nodeValue;

		$place_name = get_geonames_placeName($countryCode, $countryName, $name, $adminName1, $fcode);
		$geoURIs[$place_name] = $geonameUri;

		if ($role == 'mint'){
			$mintNode = '<geogname xlink:role="mint" xlink:href="' . $geonameUri . '"' . $certainty . '>' . $place_name . '</geogname>';
		} else {
			$mintNode = '<corpname xlink:role="' . $role . '" xlink:href="' . $geonameUri . '">' . $place_name . '</corpname>';
		}
	}

	return $mintNode;
}

function get_geonames_placeName($countryCode, $countryName, $name, $adminName1, $fcode){
	if ($countryCode == 'US' || $countryCode == 'AU' || $countryCode == 'CA'){
		if ($fcode == 'ADM1'){
			$place_name = $name;
		} else {
			$place_name = $name . ' (' . get_geonames_region($countryCode, $adminName1) . ')';
		}
	} elseif ($countryCode == 'GB'){
		if ($fcode == 'ADM1'){
			$place_name = $name;
		} else {
			$place_name = $name . ' (' . $adminName1 . ')';
		}
	} elseif ($fcode == 'PCLI'){
		$place_name = $name;
	} else {
		$place_name = $name . ' (' . $countryName . ')';
	}



	return $place_name;
}

function get_geonames_region($countryCode, $adminName1){
	switch ($countryCode){
		case 'US':
			switch ($adminName1){
				case 'Alabama':
					$region = 'Ala.';
					break;
				case 'Alaska':
					$region = 'Alaska';
					break;
				case 'Arizona':
					$region = 'Ariz.';
					break;
				case 'Arkansas':
					$region = 'Ark.';
					break;
				case 'California':
					$region = 'Calif.';
					break;
				case 'Colorado':
					$region = 'Colo.';
					break;
				case 'Connecticut':
					$region = 'Conn.';
					break;
				case 'Delaware':
					$region = 'Del.';
					break;
				case 'Washington, D.C.':
					$region = 'D.C.';
					break;
				case 'Florida':
					$region = 'Fla.';
					break;
				case 'Georgia':
					$region = 'Ga.';
					break;
				case 'Hawaii':
					$region = 'Hawaii';
					break;
				case 'Idaho':
					$region = 'Idaho';
					break;
				case 'Illinois':
					$region = 'Ill.';
					break;
				case 'Indiana':
					$region = 'Ind.';
					break;
				case 'Iowa':
					$region = 'Iowa';
					break;
				case 'Kansas':
					$region = 'Kans.';
					break;
				case 'Kentucky':
					$region = 'Ky.';
					break;
				case 'Louisiana':
					$region = 'La.';
					break;
				case 'Maine':
					$region = 'Maine';
					break;
				case 'Maryland':
					$region = 'Md.';
					break;
				case 'Massachusetts':
					$region = 'Mass.';
					break;
				case 'Michigan':
					$region = 'Mich.';
					break;
				case 'Minnesota':
					$region = 'Minn.';
					break;
				case 'Mississippi':
					$region = 'Miss.';
					break;
				case 'Missouri':
					$region = 'Mo.';
					break;
				case 'Montana':
					$region = 'Mont.';
					break;
				case 'Nebraska':
					$region = 'Nebr.';
					break;
				case 'Nevada':
					$region = 'Nev.';
					break;
				case 'New Hampshire':
					$region = 'N.H.';
					break;
				case 'New Jersey':
					$region = 'N.J.';
					break;
				case 'New Mexico':
					$region = 'N.M.';
					break;
				case 'New York':
					$region = 'N.Y.';
					break;
				case 'North Carolina':
					$region = 'N.C.';
					break;
				case 'North Dakota':
					$region = 'N.D.';
					break;
				case 'Ohio':
					$region = 'Ohio';
					break;
				case 'Oklahoma':
					$region = 'Okla.';
					break;
				case 'Oregon':
					$region = 'Oreg.';
					break;
				case 'Pennsylvania':
					$region = 'Pa.';
					break;
				case 'Rhode Island':
					$region = 'R.I.';
					break;
				case 'South Carolina':
					$region = 'S.C.';
					break;
				case 'South Dakota':
					$region = 'S.D';
					break;
				case 'Tennessee':
					$region = 'Tenn.';
					break;
				case 'Texas':
					$region = 'Tex.';
					break;
				case 'Utah':
					$region = 'Utah';
					break;
				case 'Vermont':
					$region = 'Vt.';
					break;
				case 'Virginia':
					$region = 'Va.';
					break;
				case 'Washington':
					$region = 'Wash.';
					break;
				case 'West Virginia':
					$region = 'W.Va.';
					break;
				case 'Wisconsin':
					$region = 'Wis.';
					break;
				case 'Wyoming':
					$region = 'Wyo.';
					break;
				case 'American Samoa':
					$region = 'A.S.';
					break;
				case 'Guam':
					$region = 'Guam';
					break;
				case 'Northern Mariana Islands':
					$region = 'M.P.';
					break;
				case 'Puerto Rico':
					$region = 'P.R.';
					break;
				case 'U.S. Virgin Islands':
					$region = 'V.I.';
					break;
			}
			break;
		case 'CA':
			switch ($adminName1){
				case 'Alberta':
					$region = 'Alta.';
					break;
				case 'British Columbia':
					$region = 'B.C.';
					break;
				case 'Manitoba':
					$region = 'Alta.';
					break;
				case 'Alberta':
					$region = 'Man.';
					break;
				case 'New Brunswick':
					$region = 'N.B.';
					break;
				case 'Newfoundland and Labrador':
					$region = 'Nfld.';
					break;
				case 'Northwest Territories':
					$region = 'N.W.T.';
					break;
				case 'Nova Scotia':
					$region = 'N.S.';
					break;
				case 'Nunavut':
					$region = 'NU';
					break;
				case 'Ontario':
					$region = 'Ont.';
					break;
				case 'Prince Edward Island':
					$region = 'P.E.I.';
					break;
				case 'Quebec':
					$region = 'Que.';
					break;
				case 'Saskatchewan':
					$region = 'Sask.';
					break;
				case 'Yukon':
					$region = 'Y.T.';
					break;
			}
			break;
		case 'AU':
			switch ($adminName1){
				case 'Australian Capital Territory':
					$region = 'A.C.T.';
					break;
				case 'Jervis Bay Territory':
					$region = 'J.B.T.';
					break;
				case 'New South Wales':
					$region = 'N.S.W.';
					break;
				case 'Northern Territory':
					$region = 'N.T.';
					break;
				case 'Queensland':
					$region = 'Qld.';
					break;
				case 'South Australia':
					$region = 'S.A.';
					break;
				case 'Tasmania':
					$region = 'Tas.';
					break;
				case 'Victoria':
					$region = 'Vic.';
					break;
				case 'Western Australia':
					$region = 'W.A.';
					break;
			}
			break;
	}
	return $region;
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
				$dept_string = trim($values_with_labels['department']);
		}
	}
	return $dept_string;
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
	$to = 'systems@numismatics.org';
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

?>
