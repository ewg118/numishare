<?php
/************************
AUTHOR: Ethan Gruber
MODIFIED: November, 2016
DESCRIPTION: Receive and interpret escaped CSV sent from Filemaker Pro database
to public server, transform to Numishare-compliant NUDS XML (performing cleanup of data),
post to eXist XML database via cURL, and get Solr add document from Orbeon and post to Solr.
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
//error_reporting(0);
ignore_user_abort(true);
set_time_limit(0);
ini_set("auto_detect_line_endings", "1");

//get unique id of recently uploaded Filemaker CSV from request parameter
//the line below is for passing request parameters from the command line.
parse_str(implode('&', array_slice($argv, 1)), $_GET);
$csv_id = $_GET['id'];
//$csv_id = 'fmexport120116';
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

//load Google Spreadsheets
$Byzantine_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdGJSRFhnR3ZKbHo2bG5oV0pDSzBBRnc&single=true&gid=0&output=csv');
$Decoration_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdFdTVy1UWGp6bFZvbTlsQWJyWmtlR1E&single=true&gid=0&output=csv');
$East_Asian_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdFdONnhna3RpNGxwTjJ1M3RiSkxfTUE&single=true&gid=0&output=csv');
$Greek_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdERQcHlNWXJlbTcwQ2g4YmM5QmxRMVE&single=true&gid=0&output=csv');
$Islamic_array = generate_json('https://docs.google.com/spreadsheets/d/1b2_YqnX-ikzieCSsE5k4wqhiSG-nvFv46351k6ilUvQ/pub?gid=1497998420&single=true&output=csv');
$Latin_American_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdGI0UmpzSTNaXy1OWHhCSnp6VDA4OEE&single=true&gid=0&output=csv');
$Medieval_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdGFkbW8xLV9yYm9rQ3VVd25rcUJTVmc&single=true&gid=0&output=csv');
$Medal_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdGg5SFlaU0VUUzM5ZUZQdHFHV3ZncVE&single=true&gid=0&output=csv');
$Modern_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdG9WVk5EMW1YamN3UFNNTHZlS0hwT1E&single=true&gid=0&output=csv');
$Roman_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdHNMSmFWdXRkWnVxRy1sOTR1Z09HQnc&single=true&gid=0&output=csv');
$South_Asian_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdFpxbjVsc25rblIyZy1OSngtVy15VGc&single=true&gid=0&output=csv');
$United_States_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdEZ3VU1JeThGVHJiNEJsUkptbTFTRGc&single=true&gid=0&output=csv');

//deities
$deities_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdHk2ZXBuX0RYMEZzUlNJUkZOLXRUTmc&single=true&gid=0&output=csv');

//keep array of valid coin type URIs to reduce the number of lookups
$coinTypes = array();

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
						echo "Processing {$accnum}\n";
						generate_nuds($row, $count, $fileName);
						
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
									$accnums[] = trim($accnum);
										
									//index records into Solr in increments of 1,000
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

	//send email if there are errors
	generate_email_report($csv_id, $accnums, $errors, $warnings, $startTime, $endTime);
	
	fclose($handle);
	//unlink("/tmp/" . $csv_id . ".csv");
	error_log(date(DATE_W3C) . ": Processing completed. /tmp/{$csv_id}.csv has been deleted.\n", 3, "/var/log/numishare/process.log");
} else {
	error_log(date(DATE_W3C) . ": Unable to open {$csv_id}.csv.\n", 3, "/var/log/numishare/process.log");
}

/****** GENERATE NUDS ******/
function generate_nuds($row, $count, $fileName){
	GLOBAL $warnings;
	GLOBAL $coinTypes;
	
	$ocreUri = '';
	$ocreTitle = '';

	//generate collection year for images
	$accnum = trim($row['accnum']);
	$accession_array = explode('.', $accnum);
	$collection_year = $accession_array[0];

	//department
	$department = get_department($row['department']);

	//references; used to check for 'ric.' for pointing typeDesc to OCRE
	$refs = array_filter(explode('|', $row['refs']));
	
	$writer = new XMLWriter();
	$writer->openURI($fileName);
	//$writer->openURI('php://output');
	$writer->startDocument('1.0','UTF-8');
	$writer->setIndent(true);
	//now we need to define our Indent string,which is basically how many blank spaces we want to have for the indent
	$writer->setIndentString("    ");
	
	$writer->startElement('nuds');
	$writer->writeAttribute('xmlns', 'http://nomisma.org/nuds');
	$writer->writeAttribute('xmlns:xs', "http://www.w3.org/2001/XMLSchema");
	$writer->writeAttribute('xmlns:xlink', "http://www.w3.org/1999/xlink");
	$writer->writeAttribute('xmlns:mets', "http://www.loc.gov/METS/");
	$writer->writeAttribute('xmlns:xsi', "http://www.w3.org/2001/XMLSchema-instance");
	$writer->writeAttribute('recordType', "physical");
		
		//start control
		$writer->startElement('control');
			$writer->writeElement('recordId', $accnum);
			$writer->writeElement('publicationStatus', 'approved');
			$writer->startElement('maintenanceAgency');
				$writer->writeElement('agencyName', 'American Numismatic Society');
			$writer->endElement();
			$writer->writeElement('maintenanceStatus', 'derived');
			$writer->startElement('maintenanceHistory');
				$writer->startElement('maintenanceEvent');
					$writer->writeElement('eventType', 'derived');
					$writer->startElement('eventDateTime');
						$writer->writeAttribute('standardDateTime', date(DATE_W3C));
						$writer->text(date(DATE_W3C));
					$writer->endElement();
					$writer->writeElement('agentType', 'machine');
					$writer->writeElement('agent', 'PHP');
					$writer->writeElement('eventDescription', 'Exported from Filemaker');
				$writer->endElement();
			$writer->endElement();
		$writer->endElement();
		//end control
	
		//begin descMeta
		$writer->startElement('descMeta');
		
		/************ BEGIN TYPEDESC ***************/
		//if the coin is Roman and contains 'ric.' as a reference, point the typeDesc to OCRE
		if (count(preg_grep('/ric\.[1-9]/', $refs)) == 1){
			//only continue process if the reference is not variant
			if (strpos(strtolower($row['info']), 'variant') === FALSE){
				$matches = preg_grep('/ric\./', $refs);
				foreach ($matches as $k=>$v){
					if (strlen(trim($v)) > 0){
						//account for ? used as uncertainty
						$id = substr(trim($v), -1) == '?' ? str_replace('?', '', trim($v)) : trim($v);
						$uncertain = substr(trim($v), -1) == '?' ? true : false;
					}
				}
				
				//if the $id is from RIC 9, capitalize final letter
				if (strpos($id, 'ric.9') !== FALSE){
					$pieces = explode('.', $id);
					$pieces[3] = strtoupper($pieces[3]);
					
					//reassemble $id
					$id = implode('.', $pieces);
					$uri = 'http://numismatics.org/ocre/id/' . $id;
				} else {
					$uri = 'http://numismatics.org/ocre/id/' . $id;
				}
				
				//reduce lookups
				if (array_key_exists($uri, $coinTypes)){
					echo "Matched {$uri}\n";
					
					$ocreUri = $uri;
					$ocreTitle = $coinTypes[$uri]['reference'];
					$title = $coinTypes[$uri]['title'];
					
					//generate title
					$writer->startElement('title');
						$writer->writeAttribute('xml:lang', 'en');
						$writer->text("{$title}. {$accnum}");
					$writer->endElement();
					
					process_typeDesc_object($writer, $row, $coinTypes[$uri]['object'], $uncertain);
					//generate_typeDesc_from_OCRE($writer, $row, $uri, $uncertain);
				} else {
					$file_headers = @get_headers($uri);
					if ($file_headers[0] == 'HTTP/1.1 200 OK'){
						echo "Found {$uri}\n";
						$currentUri = get_current_ocre_uri($uri);
						//echo "{$currentUri}\n";
						if ($currentUri != 'FAIL'){
							//generate the title from the NUDS
							$titles = generate_title_from_type($currentUri);
							$writer->startElement('title');
								$writer->writeAttribute('xml:lang', 'en');
								$writer->text("{$titles['title']}. {$accnum}");
							$writer->endElement();
							
							//add data into the $coinTypes array
							$coinTypes[$currentUri] = array('title'=>$titles['title'], 'reference'=>$titles['reference']);
							generate_typeDesc_from_OCRE($writer, $row, $currentUri, $uncertain);
								
							//set the ocreTitle
							$ocreUri = $currentUri;
							$ocreTitle = $titles['reference'];
						} else {
							//FAIL if the $ref actually has two new URIs
							generate_typeDesc($writer, $row, $department, $uncertain);
						}
					} else {
						generate_typeDesc($writer, $row, $department, $uncertain);
					}
				}
			} else {
				//otherwise simply generate typeDesc
				$uncertain = false;
				generate_typeDesc($writer, $row, $department, $uncertain);
			}
		
		} elseif ($department=='Roman' && count(preg_grep('/C\.[1-9]/', $refs)) > 0){
			//handle Roman Republican
			$matches = preg_grep('/C\.[1-9]/', $refs);
			foreach ($matches as $k=>$v){
				if (strlen(trim($v)) > 0){
					$id = substr(trim($v), -1) == '?' ? str_replace('?', '', trim($v)) : trim($v);
					$uncertain = substr(trim($v), -1) == '?' ? true : false;
				}
			}
			$uri = 'http://numismatics.org/crro/id/' . str_replace('C.', 'rrc-', $id);
			
			//get info from $coinTypes array if the coin type has been verified already
			if (array_key_exists($uri, $coinTypes)){
				echo "Matched {$uri}\n";
				$title = $coinTypes[$uri]['title'];
					
				//generate title
				$writer->startElement('title');
					$writer->writeAttribute('xml:lang', 'en');
					$writer->text("{$title}. {$accnum}");	
				$writer->endElement();
				
				//generate typeDesc with link
				$writer->startElement('typeDesc');
					$writer->writeAttribute('xlink:type', 'simple');
					$writer->writeAttribute('xlink:href', $uri);
					if ($uncertain == true){
						$writer->writeAttribute('certainty', 'uncertain');
					}
				$writer->endElement();
			} else {
				$file_headers = @get_headers($uri);
				if ($file_headers[0] == 'HTTP/1.1 200 OK'){
					echo "Found {$uri}\n";
					$titles = generate_title_from_type($uri);
					$writer->startElement('title');
						$writer->writeAttribute('xml:lang', 'en');
						$writer->text("{$titles['title']}. {$accnum}");
					$writer->endElement();
					
					//generate typeDesc with link
					$writer->startElement('typeDesc');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:href', $uri);
						if ($uncertain == true){
							$writer->writeAttribute('certainty', 'uncertain');
						}
					$writer->endElement();
					
					//add data into the $coinTypes array
					$coinTypes[$uri] = array('title'=>$titles['title'], 'reference'=>$titles['reference']);
				} else {
					generate_typeDesc($writer, $row, $department, $uncertain);
				}
			}			
		} elseif ($department=='Greek' && count(preg_grep('/Price\.[L|P]?\d+[A-Z]?$/', $refs)) > 0){
			//handle Price references for Pella
			$matches = preg_grep('/Price\.[L|P]?\d+[A-Z]?$/', $refs);
			foreach ($matches as $k=>$v){
				if (strlen(trim($v)) > 0){
					$id = substr(trim($v), -1) == '?' ? str_replace('?', '', trim($v)) : trim($v);
					$uncertain = substr(trim($v), -1) == '?' ? true : false;
				}
			}
			$uri = 'http://numismatics.org/pella/id/' . str_replace('Price.', 'price.', $id);
			
			//get info from $coinTypes array if the coin type has been verified already
			if (array_key_exists($uri, $coinTypes)){
				echo "Matched {$uri}\n";
				$title = $coinTypes[$uri]['title'];
					
				//generate title
				$writer->startElement('title');
					$writer->writeAttribute('xml:lang', 'en');
					$writer->text("{$title}. {$accnum}");
				$writer->endElement();
			
				//generate typeDesc with link
				$writer->startElement('typeDesc');
					$writer->writeAttribute('xlink:type', 'simple');
					$writer->writeAttribute('xlink:href', $uri);
					if ($uncertain == true){
						$writer->writeAttribute('certainty', 'uncertain');
					}
				$writer->endElement();
			} else {
				$file_headers = @get_headers($uri);
				if ($file_headers[0] == 'HTTP/1.1 200 OK'){
					echo "Found {$uri}\n";
					//get title
					$titles = generate_title_from_type($uri);
					$writer->startElement('title');
						$writer->writeAttribute('xml:lang', 'en');
						$writer->text("{$titles['title']}. {$accnum}");
					$writer->endElement();
					
					//generate typeDesc with link
					$writer->startElement('typeDesc');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:href', $uri);
						if ($uncertain == true){
							$writer->writeAttribute('certainty', 'uncertain');
						}
					$writer->endElement();
					
					//add data into the $coinTypes array
					$coinTypes[$uri] = array('title'=>$titles['title'], 'reference'=>$titles['reference']);
				} else {
					generate_typeDesc($writer, $row, $department, $uncertain);
				}
			}
		} elseif ($row['privateinfo'] == 'WW I project ready') {
			//handle AoD
			$citations = array_filter(explode('|', trim($row['published'])));
			$uri = 'http://numismatics.org/aod/id/' . $citations[0];
			
			//get info from $coinTypes array if the coin type has been verified already
			if (array_key_exists($uri, $coinTypes)){
				$title = $coinTypes[$uri]['title'];
				//generate title
				$writer->startElement('title');
					$writer->writeAttribute('xml:lang', 'en');
					$writer->text("{$title}. {$accnum}");
				$writer->endElement();
					
				//generate typeDesc with link
				$writer->startElement('typeDesc');
					$writer->writeAttribute('xlink:type', 'simple');
					$writer->writeAttribute('xlink:href', $uri);
					//no uncertainty in AoD
					/*if ($uncertain == true){
						$writer->writeAttribute('certainty', 'uncertain');
					}*/
				$writer->endElement();
			} else {
				$file_headers = @get_headers($uri);
				if ($file_headers[0] == 'HTTP/1.1 200 OK'){
					
					//get title
					$titles = generate_title_from_type($uri);
					$writer->startElement('title');
						$writer->writeAttribute('xml:lang', 'en');
						$writer->text("{$titles['title']}. {$accnum}");
					$writer->endElement();
				
					//generate typeDesc with link
					$writer->startElement('typeDesc');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:href', $uri);
						//no uncertainty in AoD
						/*if ($uncertain == false){
							$writer->writeAttribute('certainty', 'uncertain');
						}*/
					$writer->endElement();
					
					//add data into the $coinTypes array
					$coinTypes[$uri] = array('title'=>$titles['title'], 'reference'=>$titles['reference']);
				} else {
					generate_typeDesc($writer, $row, $department, false);
				}
			}
		}  else {
			generate_typeDesc($writer, $row, $department, false);
		}		
		/***** END TYPESDESC *****/

		/***** UNDERTYPE DESCRIPTION *****/
		if (strlen(trim($row['undertype'])) > 0){
			$writer->startElement('undertypeDesc');
				$writer->startElement('description');
					$writer->writeAttribute('xml:lang', 'en');
					$writer->text(trim($row['undertype']));
				$writer->endElement();
			$writer->endElement();
		}
	
		/***** PHYSICAL DESCRIPTION *****/
		$writer->startElement('physDesc');
	
		//axis: only create if it's an integer
		$axis = (int) $row['axis'];
		if (is_int($axis) && $axis <= 12 && $axis >= 0){
			$writer->writeElement('axis', $axis);
		} elseif((strlen($axis) > 0 && !is_int($axis)) || $axis > 12){
			$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-integer axis or value exceeding 12.';
		}
	
		//color
		if (strlen($row['color']) > 0){
			$colors = array_filter(explode('|', $row['color']));
			foreach ($colors as $color){
				$writer->writeElement('color', trim($color));
			}
		}
		//dob
		if (strlen(trim($row['dob'])) > 0){
			$writer->startElement('dateOnObject');
				$writer->writeElement('date', trim($row['dob']));
			$writer->endElement();
		}
		//sernum
		if (strlen(trim($row['sernum'])) > 0){
			$writer->writeElement('serialNumber', trim($row['sernum']));
		}
		//watermark
		if (strlen(trim($row['watermark'])) > 0){
			$writer->writeElement('watermark', trim($row['matermark']));
		}
		//shape
		if (strlen(trim($row['shape'])) > 0){
			$writer->writeElement('shape', trim($row['shape']));
		}
		//signature
		if (strlen(trim($row['signature'])) > 0){
			$writer->writeElement('signature', trim($row['signature']));
		}
		//counterstamp
		if (strlen(trim($row['counterstamp'])) > 0){
			$writer->startElement('countermark');
				$writer->startElement('description');
					$writer->writeAttribute('xml:lang', 'en');
					$writer->text(trim($row['counterstamp']));
				$writer->endElement();
			$writer->endElement();
		}
		
		//create measurementsSet, if applicable
		if ((is_numeric(trim($row['weight'])) && trim($row['weight']) > 0) || (is_numeric(trim($row['diameter'])) && trim($row['diameter']) > 0) || (is_numeric(trim($row['height'])) && trim($row['height']) > 0) || (is_numeric(trim($row['width'])) && trim($row['width']) > 0) || (is_numeric(trim($row['depth'])) && trim($row['depth']) > 0)){
			$writer->startElement('measurementsSet');
			//weight
			$weight = trim($row['weight']);
			if (is_numeric($weight) && $weight > 0){
				$writer->startElement('weight');
					$writer->writeAttribute('units', 'g');
					$writer->text($weight);
				$writer->endElement();
			} elseif(!is_numeric($weight) && strlen($weight) > 0){
				$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-numeric weight.';
			}
			//diameter
			$diameter = trim($row['diameter']);
			if (is_numeric($diameter) && $diameter > 0){
				$writer->startElement('diameter');
					$writer->writeAttribute('units', 'mm');
					$writer->text($diameter);
				$writer->endElement();
			} elseif(!is_numeric($diameter) && strlen($diameter) > 0){
				$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-numeric diameter.';
			}
			//height
			$height = trim($row['height']);
			if (is_numeric($height) && $height > 0){
				$writer->startElement('height');
					$writer->writeAttribute('units', 'mm');
					$writer->text($height);
				$writer->endElement();
			} elseif(!is_numeric($height) && strlen($height) > 0){
				$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-numeric height.';
			}
			//width
			$width = trim($row['width']);
			if (is_numeric($width) && $width > 0){
				$writer->startElement('width');
					$writer->writeAttribute('units', 'mm');
					$writer->text($width);
				$writer->endElement();
			} elseif(!is_numeric($width) && strlen($width) > 0){
				$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-numeric width.';
			}
			//depth
			$depth = trim($row['depth']);
			if (is_numeric($depth) && $depth > 0){
				$writer->startElement('thickness');
					$writer->writeAttribute('units', 'mm');
					$writer->text($depth);
				$writer->endElement();
			} elseif(!is_numeric($depth) && strlen($depth) > 0){
				$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-numeric depth.';
			}
			$writer->endElement();
		}
		
		if (strlen(trim($row['Authenticity'])) > 0){
			$array = array_filter(explode('|', $row['Authenticity']));
			foreach ($array as $val){
				$uncertain = substr($val, -1) == '?' ? true : false;
				$label = str_replace('?', '', trim($val));
				$writer->startElement('authenticity');
					if($uncertain == true){
						$writer->writeAttribute('certainty', 'uncertain');
					}
					$writer->text($label);
				$writer->endElement();
			}
		}
		
		//no NUDS equivalent: not used in MANTIS anyway
		/*if (strlen(trim($row['OrigIntenUse'])) > 0){
			$array = array_filter(explode('|', $row['OrigIntenUse']));
			foreach ($array as $val){
				$uncertain = substr($val, -1) == '?' ? true : false;
				$label = str_replace('?', '', trim($val));
				$writer->startElement('originalIntendeUse');
					if($uncertain == true){
						$writer->writeAttribute('certainty', 'uncertain');
					}
					$writer->text($label);
				$writer->endElement();
			}
		}*/
		
		//conservationState
		if (strlen(trim($row['conservation'])) > 0 || strlen(trim($row['PostManAlt'])) > 0){
			$writer->startElement('conservationState');
			if (strlen(trim($row['conservation'])) > 0){
				$writer->startElement('description');
					$writer->writeAttribute('xml:lang', 'en');
					$writer->text(trim($row['conservation']));
				$writer->endElement();
			}
			
			if (strlen(trim($row['PostManAlt'])) > 0){
				$array = array_filter(explode('|', $row['PostManAlt']));
				foreach ($array as $val){
					$uncertain = substr($val, -1) == '?' ? true : false;
					$label = str_replace('?', '', trim($val));
					$writer->startElement('condition');
						if($uncertain == true){
							$writer->writeAttribute('certainty', 'uncertain');
						}
						$writer->text($label);
				$writer->endElement();
			}
		}
		$writer->endElement();
	}
	$writer->endElement();
	//end physDesc
	
	
		/***** ADMINSTRATIVE DESCRIPTION *****/
		$writer->startElement('adminDesc');
			$writer->writeElement('identifier', $accnum);
			$writer->writeElement('department', $department);
			$writer->startElement('collection');
				$writer->writeAttribute('xlink:type', 'simple');
				$writer->writeAttribute('xlink:href', 'http://nomisma.org/id/ans');
				$writer->text('American Numismatic Society');
			$writer->endElement();
			
			//image sponsor: acknowledgement with localType
			if (strlen(trim($row['imagesponsor'])) > 0){
				$writer->startElement('acknowledgment');
					$writer->writeAttribute('localType', 'imageSponsor');
					$writer->text(trim($row['imagesponsor']));
				$writer->endElement();
			}
			//custhodhist || strlen(trim($row['donor'])) > 0
			if (strlen(trim($row['prevcoll'])) > 0 || strlen(trim($row['acknowledgment'])) > 0){
				
				$writer->startElement('provenance');
					$writer->startElement('chronList');
					//acknowledgment row is donor?
					if (strlen(trim($row['acknowledgment'])) > 0){
						$writer->startElement('chronItem');
							$writer->writeElement('acquiredFrom', trim($row['acknowledgment']));
						$writer->endElement();
					}
					/*if (strlen(trim($row['donor'])) > 0){
						$writer->startElement('chronItem');
							$writer->writeElement('acquiredFrom', trim($row['donor']));
						$writer->endElement();
					}*/
					
					$prevcolls = array_filter(explode('|', $row['prevcoll']));
					foreach ($prevcolls as $prevcoll){
						if (!is_int($prevcoll) && strlen(trim($prevcoll)) > 0){
							$writer->startElement('chronItem');
								$writer->writeElement('previousColl', trim($prevcoll));
							$writer->endElement();
						}
					}
					$writer->endElement();
				$writer->endElement();
			}
		$writer->endElement();

		/***** BIBLIOGRAPHIC DESCRIPTION *****/
		$citations = array_filter(explode('|', trim($row['published'])));
		if (count($refs) > 0 || count($citations) > 0){
			$writer->startElement('refDesc');
				//reference		
				if (count($refs) > 0){
					foreach ($refs as $ref){		
						$uncertain = substr($ref, -1) == '?' ? true : false;
						if (preg_match('/ric\.[1-9]/', $ref)){
							if (strlen($ocreUri) > 0){
								//insert OCRE URIs into a normalized reference field
								$writer->startElement('reference');
									$writer->writeAttribute('xlink:type', 'simple');
									$writer->writeAttribute('xlink:arcrole', 'nmo:hasTypeSeriesItem');
									$writer->writeAttribute('xlink:href', $ocreUri);
									if ($uncertain == true){
										$writer->writeAttribute('certainty', 'uncertain');
									}
									$writer->text($ocreTitle);
								$writer->endElement();
							}
						} else {
							$label = str_replace('?', '', trim($ref));
							$writer->startElement('reference');
								if ($uncertain == true){
									$writer->writeAttribute('certainty', 'uncertain');
								}
								$writer->text($label);
							$writer->endElement();
						}
					}			
				}
				
				//citation
				if (count($citations) > 0){
					foreach ($citations as $val){				
						$uncertain = substr($val, -1) == '?' ? true : false;
						$label = str_replace('?', '', trim($val));
						$writer->startElement('citation');
							if ($uncertain == true){
								$writer->writeAttribute('certainty', 'uncertain');
							}
							$writer->text($label);
						$writer->endElement();
					}
				}
			$writer->endElement();
		}
		
		/***** SUBJECTS *****/
		if (strlen(trim($row['series'])) > 0 || strlen(trim($row['subjevent'])) > 0 || strlen(trim($row['subjissuer'])) > 0 || strlen(trim($row['subjperson'])) > 0 || strlen(trim($row['subjplace'])) > 0 || strlen(trim($row['degree'])) > 0 || strlen(trim($row['era'])) > 0){
			$writer->startElement('subjectSet');
				//suppressing categories: no longer useful or controlled in Filemaker
				/*if (strlen(trim($row['category'])) > 0){
				 $categories = array_filter(explode('|', trim($row['category'])));
				foreach ($categories as $category){
				$xml .= '<subject localType="category">' . trim($category) . '</subject>';
				}
				}*/
				if (strlen(trim($row['series'])) > 0){
					$serieses = array_filter(explode('|', $row['series']));
					foreach ($serieses as $series){
						$writer->startElement('subject');
							$writer->writeAttribute('localType', 'series');
							$writer->text(trim($series));
						$writer->endElement();
					}
				}
				if (strlen(trim($row['subjevent'])) > 0){
					$subjEvents = array_filter(explode('|', $row['subjevent']));
					foreach ($subjEvents as $subjEvent){
						$writer->startElement('subject');
							$writer->writeAttribute('localType', 'subjectEvent');
							$writer->text(trim($subjEvent));
						$writer->endElement();
					}
				}
				if (strlen(trim($row['subjissuer'])) > 0){
					$subjIssuers = array_filter(explode('|', $row['subjissuer']));
					foreach ($subjIssuers as $subjIssuer){
						$writer->startElement('subject');
							$writer->writeAttribute('localType', 'subjectIssuer');
							$writer->text(trim($subjIssuer));
						$writer->endElement();
					}
				}
				if (strlen(trim($row['subjperson'])) > 0){
					$subjPersons = array_filter(explode('|', $row['subjperson']));
					foreach ($subjPersons as $subjPerson){
						$writer->startElement('subject');
							$writer->writeAttribute('localType', 'subjectPerson');
							$writer->text(trim($subjPerson));
						$writer->endElement();
					}
				}
				if (strlen(trim($row['subjplace'])) > 0){
					$subjPlaces = array_filter(explode('|', $row['subjplace']));
					foreach ($subjPlaces as $subjPlace){
						$writer->startElement('subject');
							$writer->writeAttribute('localType', 'subjectPlace');
							$writer->text(trim($subjPlace));
						$writer->endElement();
					}
				}
				if (strlen(trim($row['era'])) > 0){
					$eras = array_filter(explode('|', $row['era']));
					foreach ($eras as $era){
						$writer->startElement('subject');
							$writer->writeAttribute('localType', 'era');
							$writer->text(trim($era));
						$writer->endElement();
					}
				}
				//degree
				if (strlen(trim($row['degree'])) > 0){
					$degrees = array_filter(explode('|', $row['degree']));
					foreach ($degrees as $degree){
						$writer->startElement('subject');
							$writer->writeAttribute('localType', 'degree');
							$writer->text(trim($degree));
						$writer->endElement();
					}
				}
			$writer->endElement();
		}
		//notes
		if (strlen(trim($row['info'])) > 0){
			$infos = array_filter(explode('|', $row['info']));
			$writer->startElement('nodeSet');
			foreach ($infos as $info){
				$writer->writeElement('note', trim($info));
			}
			$writer->endElement();
		}
	
		/***** FINDSPOT DESCRIPTION *****/
		if (strpos($row['privateinfo'], 'coinhoards.org') !== FALSE){
			$url = trim($row['privateinfo']);
			$file_headers = @get_headers($url);
			if ($file_headers[0] == 'HTTP/1.1 200 OK'){
				$writer->startElement('findspotDesc');
					$writer->writeAttribute('xlink:type', 'simple');
					$writer->writeAttribute('xlink:href', $url);
				$writer->endElement();
			}
		} elseif (strlen(trim($row['findspot'])) > 0){
			$writer->startElement('findspotDesc');
				$writer->startElement('findspot');
					$writer->startElement('geogname');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:role', 'findspot');
						$writer->text(trim($row['findspot']));
					$writer->endElement();
				$writer->endElement();
			$writer->endElement();
		}
	
		//end descMeta		
		$writer->endElement();

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
		
		$writer->startElement('digRep');
			$writer->startElement('mets:fileSec');
				//obverse images
				$writer->startElement('mets:fileGrp');
					$writer->writeAttribute('USE', 'obverse');
					//IIIF
					$writer->startElement('mets:file');
						$writer->writeAttribute('USE', 'iiif');
						$writer->startElement('mets:FLocat');
							$writer->writeAttribute('LOCYPE', 'URL');
							$writer->writeAttribute('xlink:href', "http://images.numismatics.org/collectionimages%2F{$image_path}%2F{$collection_year}%2F{$accnum}.obv.noscale.jpg");
						$writer->endElement();
					$writer->endElement();
					//reference
					$writer->startElement('mets:file');
						$writer->writeAttribute('USE', 'reference');
						$writer->writeAttribute('MIMETYPE', 'image/jpeg');
						$writer->startElement('mets:FLocat');
							$writer->writeAttribute('LOCYPE', 'URL');
							$writer->writeAttribute('xlink:href', "http://numismatics.org/collectionimages/{$image_path}/{$collection_year}/{$accnum}.obv.width350.jpg");
						$writer->endElement();					
					$writer->endElement();
					//thumbnail
					$writer->startElement('mets:file');
						$writer->writeAttribute('USE', 'thumbnail');
						$writer->writeAttribute('MIMETYPE', 'image/jpeg');
						$writer->startElement('mets:FLocat');
							$writer->writeAttribute('LOCYPE', 'URL');
							$writer->writeAttribute('xlink:href', "http://numismatics.org/collectionimages/{$image_path}/{$collection_year}/{$accnum}.obv.width175.jpg");
						$writer->endElement();
					$writer->endElement();
				$writer->endElement();
				//reverse images
				$writer->startElement('mets:fileGrp');
					$writer->writeAttribute('USE', 'reverse');
					//IIIF
					$writer->startElement('mets:file');
						$writer->writeAttribute('USE', 'iiif');
						$writer->startElement('mets:FLocat');
							$writer->writeAttribute('LOCYPE', 'URL');
							$writer->writeAttribute('xlink:href', "http://images.numismatics.org/collectionimages%2F{$image_path}%2F{$collection_year}%2F{$accnum}.rev.noscale.jpg");
						$writer->endElement();
					$writer->endElement();
					//reference
					$writer->startElement('mets:file');
						$writer->writeAttribute('USE', 'reference');
						$writer->writeAttribute('MIMETYPE', 'image/jpeg');
						$writer->startElement('mets:FLocat');
							$writer->writeAttribute('LOCYPE', 'URL');
							$writer->writeAttribute('xlink:href', "http://numismatics.org/collectionimages/{$image_path}/{$collection_year}/{$accnum}.rev.width350.jpg");
						$writer->endElement();
					$writer->endElement();
					//thumbnail
					$writer->startElement('mets:file');
						$writer->writeAttribute('USE', 'thumbnail');
						$writer->writeAttribute('MIMETYPE', 'image/jpeg');
						$writer->startElement('mets:FLocat');
							$writer->writeAttribute('LOCYPE', 'URL');
							$writer->writeAttribute('xlink:href', "http://numismatics.org/collectionimages/{$image_path}/{$collection_year}/{$accnum}.rev.width175.jpg");
						$writer->endElement();
					$writer->endElement();
				$writer->endElement();
			$writer->endElement();
		$writer->endElement();
	}
	//end nuds
	$writer->endElement();
	
	//close file
	$writer->endDocument();
	$writer->flush();
}

function generate_typeDesc($writer, $row, $department, $certainty){
	GLOBAL $deities_array;
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
	$objectType = normalize_objtype(trim(strtoupper($row['objtype'])));
	
	//begin typeDesc
	$writer->startElement('typeDesc');
	
		//object type
		$writer->startElement('objectType');
			$writer->writeAttribute('xlink:type', 'simple');
			if (isset($objectType['uri'])){
				$writer->writeAttribute('xlink:href', $objectType['uri']);
			}
			$writer->text($objectType['label']);
		$writer->endElement();
		
		//date	
		if (trim($row['startdate']) != '' || trim($row['enddate']) != ''){
			get_date($writer, $startdate_int, $enddate_int, $row['accnum'], $department);
		}
		
	//denomination
	if (count($denominations) > 0){
		foreach ($denominations as $denomination){
			$val = trim(str_replace('"', '', $denomination));
			$uncertain = substr($val, -1) == '?' ? true : false;
			$label = trim(str_replace('?', '', $val));
			
			$writer->startElement('denomination');
				$writer->writeAttribute('xlink:type', 'simple');
				if ($uncertain == true){
					$writer->writeAttribute('certainty', 'uncertain');
				}				
				$writer->text($label);
			$writer->endElement();
				
			//insert material
			$title_elements['denomination'] = $label;
		}
	}
	//manufacture
	if (count($manufactures) > 0){
		
		foreach ($manufactures as $manufacture){
			$val = trim(str_replace('"', '', $manufacture));
			$uncertain = substr($val, -1) == '?' ? true : false;
			$label = trim(str_replace('?', '', $val));
			
			$writer->startElement('denomination');
				$writer->writeAttribute('xlink:type', 'simple');
				if ($uncertain == true){
					$writer->writeAttribute('certainty', 'uncertain');
				}
				if (strstr(strtolower($label), 'struck')){
					$writer->writeAttribute('xlink:href', 'http://nomisma.org/id/struck');
					$writer->text('Struck');
				} else if (strstr(strtolower($label), 'cast')){
					$writer->writeAttribute('xlink:href', 'http://nomisma.org/id/cast');
					$writer->text('Cast');
				} else {
					$writer->text($label);
				}				
			$writer->endElement();
		}
	}
	//material
	if (count($materials) > 0){
		foreach ($materials as $material){
			$material_string = get_material_label(trim($material));
			$mat_array = normalize_material(trim($material));
			if (isset($mat_array['uri'])){
				$writer->startElement('material');
					$writer->writeAttribute('xlink:type', 'simple');
					$writer->writeAttribute('xlink:href', $mat_array['uri']);
					$writer->text($material_string);
				$writer->endElement();
			} else {
				$writer->writeElement('material', $material_string);
			}
				
			//insert material
			$title_elements['material'] = $material_string;
		}
	}
	//obverse
	if (strlen($row['obverselegend']) > 0 || strlen($row['obversesymbol']) > 0 || strlen($row['obversetype']) > 0 || count($artists_obv) > 0){
		$writer->startElement('obverse');
		//obverselegend
		if (strlen($row['obverselegend']) > 0){
			$writer->writeElement('legend', trim($row['obverselegend']));
		}
		//obversesymbol
		if (strlen($row['obversesymbol']) > 0){
			$writer->writeElement('symbol', trim($row['obversesymbol']));
		}
		//obversetype
		if (strlen($row['obversetype']) > 0){
			$writer->startElement('type');
				$writer->startElement('description');
					$writer->writeAttribute('xml:lang', 'en');
					$writer->text(trim($row['obversetype']));
				$writer->endElement();
			$writer->endElement();
		}
		//artist
		foreach ($artists_obv as $artist){
			//WORK ON ARTIST OBV/REV
			$uncertain = substr($artist, -1) == '?' ? true : false;
			$writer->startElement('persname');
				$writer->writeAttribute('xlink:type', 'simple');
				$writer->writeAttribute('xlink:role', 'artist');
				if ($uncertain == true){
					$writer->writeAttribute('certainty', 'uncertain');
				}
				$writer->text(str_replace('?', '', $artist));
			$writer->endElement();
		}
		if ($department == 'Greek' || $department == 'Roman'){
			$haystack = strtolower($row['obversetype']);
			foreach($deities_array as $deity){				
				if ($deity['name'] != 'Hera' && $deity['name'] != 'Sol' && strlen(strstr($haystack,strtolower($deity['matches'])))>0) {
					$writer->startElement('persname');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:role', 'deity');
						if (strlen($deity['bm_uri']) > 0) {
							$writer->writeAttribute('xlink:href', $deity['bm_uri']);
						}
						$writer->text($deity['name']);
					$writer->endElement();
				}
				//Hera and Sol need special cases because they are commonly part of other works, eg Herakles, soldiers
				elseif ($deity['name'] == 'Hera' && strlen(strstr($haystack,strtolower($deity['matches'] . ' ')))>0){
					$writer->startElement('persname');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:role', 'deity');
						if (strlen($deity['bm_uri']) > 0) {
							$writer->writeAttribute('xlink:href', $deity['bm_uri']);
						}
						$writer->text($deity['name']);
					$writer->endElement();
				}
				elseif ($deity['name'] == 'Sol' && strlen(strstr($haystack,strtolower($deity['matches'] . ' ')))>0){
					$writer->startElement('persname');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:role', 'deity');
						if (strlen($deity['bm_uri']) > 0) {
							$writer->writeAttribute('xlink:href', $deity['bm_uri']);
						}
						$writer->text($deity['name']);
					$writer->endElement();
				}
			}
		}
		$writer->endElement();
	}
	
	//reverse
	if (strlen($row['reverselegend']) > 0 || strlen($row['reversesymbol']) > 0 || strlen($row['reversetype']) > 0 || count($artists_rev) > 0){
		$writer->startElement('reverse');
		//reverselegend
		if (strlen($row['reverselegend']) > 0){
			$writer->writeElement('legend', trim($row['reverselegend']));
		}
		//reversesymbol
		if (strlen($row['reversesymbol']) > 0){
			$writer->writeElement('symbol', trim($row['reversesymbol']));
		}
		//reversetype
		if (strlen($row['reversetype']) > 0){
			$writer->startElement('type');
				$writer->startElement('description');
					$writer->writeAttribute('xml:lang', 'en');
					$writer->text(trim($row['reversetype']));
				$writer->endElement();
			$writer->endElement();
		}
		//artist
		foreach ($artists_rev as $artist){
			//WORK ON ARTIST OBV/REV
			$uncertain = substr($artist, -1) == '?' ? true : false;
			$writer->startElement('persname');
				$writer->writeAttribute('xlink:type', 'simple');
				$writer->writeAttribute('xlink:role', 'artist');
				if ($uncertain == true){
					$writer->writeAttribute('certainty', 'uncertain');
				}
				$writer->text(str_replace('?', '', $artist));
			$writer->endElement();
		}
	
		if ($department == 'Greek' || $department == 'Roman'){
			$haystack = strtolower($row['reversetype']);
			foreach($deities_array as $deity){				
				if ($deity['name'] != 'Hera' && $deity['name'] != 'Sol' && strlen(strstr($haystack,strtolower($deity['matches'])))>0) {
					$writer->startElement('persname');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:role', 'deity');
						if (strlen($deity['bm_uri']) > 0) {
							$writer->writeAttribute('xlink:href', $deity['bm_uri']);
						}
						$writer->text($deity['name']);
					$writer->endElement();
				}
				//Hera and Sol need special cases because they are commonly part of other works, eg Herakles, soldiers
				elseif ($deity['name'] == 'Hera' && strlen(strstr($haystack,strtolower($deity['matches'] . ' ')))>0){
					$writer->startElement('persname');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:role', 'deity');
						if (strlen($deity['bm_uri']) > 0) {
							$writer->writeAttribute('xlink:href', $deity['bm_uri']);
						}
						$writer->text($deity['name']);
					$writer->endElement();
				}
				elseif ($deity['name'] == 'Sol' && strlen(strstr($haystack,strtolower($deity['matches'] . ' ')))>0){
					$writer->startElement('persname');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:role', 'deity');
						if (strlen($deity['bm_uri']) > 0) {
							$writer->writeAttribute('xlink:href', $deity['bm_uri']);
						}
						$writer->text($deity['name']);
					$writer->endElement();
				}
			}
		}
		$writer->endElement();
	}
	//edge
	if (strlen(trim($row['edge'])) > 0){
		$writer->startElement('edge');
			$writer->writeElement('description', trim($row['edge']));
		$writer->endElement();
	}
	
	/***** GEOGRAPHICAL LOCATIONS *****/
	if (count($mints) > 0 || count($regions) > 0 || count($localities) > 0){
		$writer->startElement('geographic');
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
				
				if (isset($geography['mint'])){
					$writer->startElement('geogname');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:role', 'mint');
						if (isset($geography['mint']['uri'])){
							$writer->writeAttribute('xlink:href', $geography['mint']['uri']);
						}
						if (isset($geography['mint']['certainty'])){
							$writer->writeAttribute('certainty', $geography['mint']['certainty']);
						}
						$writer->text($geography['mint']['label']);
					$writer->endElement();
				}
				
				if (isset($geography['state'])){
					$geogAuthorities['state'] = $geography['state'];
				}
				if (isset($geography['authority'])){
					$geogAuthorities['authority'] = $geography['authority'];
				}				
				$mints_cleaned[] = $geography['mint']['label'];
			}
			$title_elements['location'] = implode('/', $mints_cleaned);
		}
		//region
		if (count($regions) > 0){
			$regions_cleaned = array();
			foreach ($regions as $region){
				$val = trim(str_replace('"', '', $region));
				$uncertain = substr($val, -1) == '?' ? true : false;
				
				$writer->startElement('geogname');
					$writer->writeAttribute('xlink:type', 'simple');
					$writer->writeAttribute('xlink:role', 'region');
					if ($uncertain == true){
						$writer->writeAttribute('certainty', 'uncertain');
					}
					$writer->text(trim(str_replace('?', '', $val)));
				$writer->endElement();
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
				$uncertain = substr($val, -1) == '?' ? true : false;
				
				$writer->startElement('geogname');
					$writer->writeAttribute('xlink:type', 'simple');
					$writer->writeAttribute('xlink:role', 'locality');
					if ($uncertain == true){
						$writer->writeAttribute('certainty', 'uncertain');
					}
					$writer->text(trim(str_replace('?', '', $val)));
				$writer->endElement();				
				$localities_cleaned[] = trim(str_replace('?', '', $val));
			}
			if (strlen(trim($row['mint'])) == 0 && strlen(trim($row['region'])) == 0){
				$title_elements['location'] = implode('/', $localities_cleaned);
			}
		}
		$writer->endElement();
	}
	
	/***** AUTHORITIES AND PERSONS *****/
	if (isset($geogAuthorities['state']) || isset($geogAuthorities['authority']) || count($persons) > 0 || count($issuers) > 0 || count($magistrates) > 0 || count($makers) > 0 ||  count($artists_none) > 0 || count($dynasties) > 0){
		$writer->startElement('authority');		
		
		//insert authorities parsed out from the mint lookups (applies primarily to Latin America)
		if (isset($geogAuthorities['state'])){
			$writer->startElement('corpname');
			$writer->writeAttribute('xlink:type', 'simple');
			$writer->writeAttribute('xlink:role', 'state');
			if (isset($geogAuthorities['state']['uri'])){
				$writer->writeAttribute('xlink:href', $geogAuthorities['state']['uri']);
			}
			if (isset($geogAuthorities['state']['certainty'])){
				$writer->writeAttribute('certainty', $geogAuthorities['state']['certainty']);
			}
			$writer->text($geogAuthorities['state']['label']);
			$writer->endElement();
		}
		if (isset($geogAuthorities['authority'])){
			$writer->startElement('corpname');
			$writer->writeAttribute('xlink:type', 'simple');
			$writer->writeAttribute('xlink:role', 'authority');
			if (isset($geogAuthorities['authority']['uri'])){
				$writer->writeAttribute('xlink:href', $geogAuthorities['authority']['uri']);
			}
			if (isset($geogAuthorities['authority']['certainty'])){
				$writer->writeAttribute('certainty', $geogAuthorities['authority']['certainty']);
			}
			$writer->text($geogAuthorities['authority']['label']);
			$writer->endElement();
		}
		//issuer
		if (count($issuers) > 0){
			$issuers_cleaned = array();
			foreach ($issuers as $issuer){
				$val = trim(str_replace('"', '', $issuer));
				$uncertain = substr($val, -1) == '?' ? true : false;
				$val = trim(str_replace('?', '', $val));
				if ($department == 'Medieval' || $department == 'Byzantine' || $department == 'Roman'){
					$writer->startElement('persname');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:role', 'issuer');
						if ($uncertain == true){
							$writer->writeAttribute('certainty', 'uncertain');
						}
						$writer->text($val);
					$writer->endElement();
				} elseif ($department == 'Greek' || $department == 'Islamic'){
					$writer->startElement('persname');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:role', 'authority');
						if ($uncertain == true){
							$writer->writeAttribute('certainty', 'uncertain');
						}
						$writer->text($val);
					$writer->endElement();
				}
				else {
					$writer->startElement('corpname');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:role', 'issuer');
						if ($uncertain == true){
							$writer->writeAttribute('certainty', 'uncertain');
						}
						$writer->text($val);
					$writer->endElement();
				}
				$issuers_cleaned[] = $val;
			}
			$title_elements['issuer'] = implode('/', $issuers_cleaned);
		}
		//artist
		foreach ($artists_none as $artist){
			$val = trim(str_replace('"', '', $artist));
			$uncertain = substr($val, -1) == '?' ? true : false;
			
			$writer->startElement('persname');
				$writer->writeAttribute('xlink:type', 'simple');
				$writer->writeAttribute('xlink:role', 'artist');
				if ($uncertain == true){
					$writer->writeAttribute('certainty', 'uncertain');
				}
				$writer->text(str_replace('?', '', $val));
			$writer->endElement();
		}
		//dynasty
		foreach ($dynasties as $dynasty){
			$val = trim(str_replace('"', '', $dynasty));
			$uncertain = substr($val, -1) == '?' ? true : false;
				
			$writer->startElement('famname');
				$writer->writeAttribute('xlink:type', 'simple');
				$writer->writeAttribute('xlink:role', 'dynasty');
				if ($uncertain == true){
					$writer->writeAttribute('certainty', 'uncertain');
				}
				$writer->text(str_replace('?', '', $val));
			$writer->endElement();
		}
		//maker
		if (count($makers) > 0){
			foreach ($makers as $maker){
				$val = trim(str_replace('"', '', $maker));
				$uncertain = substr($val, -1) == '?' ? true : false;
				
				$writer->startElement('corpname');
					$writer->writeAttribute('xlink:type', 'simple');
					$writer->writeAttribute('xlink:role', 'maker');
					if ($uncertain == true){
						$writer->writeAttribute('certainty', 'uncertain');
					}
					$writer->text(str_replace('?', '', $val));
				$writer->endElement();
			}
		}
		//magistrate
		if (count($magistrates) > 0){
			foreach ($magistrates as $magistrate){
				$val = trim(str_replace('"', '', $magistrate));
				$uncertain = substr($val, -1) == '?' ? true : false;
				
				$writer->startElement('persname');
					$writer->writeAttribute('xlink:type', 'simple');
					$writer->writeAttribute('xlink:role', 'issuer');
					if ($uncertain == true){
						$writer->writeAttribute('certainty', 'uncertain');
					}
					$writer->text(str_replace('?', '', $val));
				$writer->endElement();
			}
		}
		//person: portrait
		if (count($persons) > 0){			
			foreach ($persons as $person){
				$val = trim(str_replace('"', '', $person));
				$uncertain = substr($val, -1) == '?' ? true : false;
				
				$certainty = substr(trim(str_replace('"', '', $person)), -1) == '?' ? ' certainty="uncertain"' : '';
				if ($department == 'Roman' || $department == 'Byzantine' || $department == 'Medal' || $department == 'United States' || $department == 'Decoration'){
					$writer->startElement('persname');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:role', 'porrait');
						if ($uncertain == true){
							$writer->writeAttribute('certainty', 'uncertain');
						}
						$writer->text(str_replace('?', '', $val));
					$writer->endElement();
				}				
				if ($department == 'Roman' || $department == 'Byzantine' || $department == 'Medieval' || $department == 'Islamic' || $department == 'East Asian' || $department == 'South Asian' || $department == 'Greek' || $department == 'Modern' || $department == 'Latin American'){
					$writer->startElement('persname');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:role', 'authority');
						if ($uncertain == true){
							$writer->writeAttribute('certainty', 'uncertain');
						}
						$writer->text(str_replace('?', '', $val));
					$writer->endElement();
				}
			}
		}
		$writer->endElement();
	}
	//end typeDesc
	$writer->endElement();
	
	/***** TITLE *****/
	$title = '';
	if (array_key_exists('material', $title_elements)){
		$title .= $title_elements['material'];
	}
	if (array_key_exists('denomination', $title_elements)){
		$title .= ' ' .  $title_elements['denomination'];
	} else {
		$title .= ' ' . $objectType['label'];
	}
	if (array_key_exists('issuer', $title_elements)){
		$title .= ' of ' .  $title_elements['issuer'];
	}
	if (array_key_exists('location', $title_elements)){
		$title .= ', ' . $title_elements['location'];
	}
	
	
	if (is_int($startdate_int) || is_int($enddate_int)){
		$title .= ', ';
		$title .= get_title_date($startdate_int, $enddate_int);
	}
	$title .= '. ' . trim($row['accnum']);
	
	$writer->startElement('title');
		$writer->writeAttribute('xml:lang', 'en');
		$writer->text($title);
	$writer->endElement();
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

function normalize_objtype($objtype){
	$objectType = array();
	switch (trim($objtype)) {
		case 'C':
			$objectType['label'] = 'Coin';
			$objectType['uri'] = 'http://nomisma.org/id/coin';
			break;
		case 'DE':
			$objectType['label'] = 'Decoration';
			break;
		case 'INGOT':
			$objectType['label'] = 'Ingot';
			$objectType['uri'] = 'http://nomisma.org/id/ingot';
			break;
		case 'ME':
			$objectType['label'] = 'Medal';
			$objectType['uri'] = 'http://nomisma.org/id/medal';
			break;
		case 'P':
			$objectType['label'] = 'Paper Money';
			$objectType['uri'] = 'http://nomisma.org/id/paper_money';
			break;
		case 'T':
			$objectType['label'] = 'Token';
			$objectType['uri'] = 'http://nomisma.org/id/token';
			break;
		default:			
			$objectType['label'] = ucfirst(strtolower(trim($objtype)));
	}
	
	return $objectType;
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

function get_date($writer, $startdate, $enddate, $accnum, $department){
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
		$writer->startElement('date');
			if (strlen($end_gYear) > 0){
				$writer->writeAttribute('standardDate', $end_gYear);
			}
			$writer->text(get_date_textual($enddate));
		$writer->endElement();
	} elseif ($startdate != 0 && $enddate == 0) {
		$writer->startElement('date');
			if (strlen($start_gYear) > 0){
				$writer->writeAttribute('standardDate', $start_gYear);
			}
			$writer->text(get_date_textual($startdate));
		$writer->endElement();
	} elseif ($startdate == $enddate){
		$writer->startElement('date');
			if (strlen($end_gYear) > 0){
				$writer->writeAttribute('standardDate', $end_gYear);
			}
			$writer->text(get_date_textual($enddate));
		$writer->endElement();
	} elseif ($startdate != 0 && $enddate != 0){
		$writer->startElement('dateRange');
			$writer->startElement('fromDate');
				if (strlen($start_gYear) > 0){
					$writer->writeAttribute('standardDate', $start_gYear);
				}
				$writer->text(get_date_textual($startdate));
			$writer->endElement();
			$writer->startElement('toDate');
				if (strlen($end_gYear) > 0){
					$writer->writeAttribute('standardDate', $end_gYear);
				}
				$writer->text(get_date_textual($enddate));
			$writer->endElement();
		$writer->endElement();
	}
}

//pad integer value from Filemaker to create a year that meets the xs:gYear specification
function number_pad($number,$n) {
	if ($number > 0){
		$gYear = str_pad((int) $number,$n,"0",STR_PAD_LEFT);
	} elseif ($number < 0) {
		$bcNum = (int)abs($number);
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
	if (substr($mint, -1) == '?'){
		$certaintyType = 'uncertain';
		$mint = str_replace('?', '', $mint);
	} else if (substr($mint, -1) == "'" && substr($mint, 0, 1) == "'"){
		$certaintyType = 'attributed';
		$mint = str_replace("'", '', $mint);
	} else {
		$certaintyType = null;
	}
	
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

		if (isset($nomisma_value)){
			if (strpos($nomisma_value, 'nomisma.org') > 0 || strpos($nomisma_value, 'geonames.org') > 0){
				$mint_uri = $nomisma_value;
			}
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
				if (isset($nomisma_value)){
					if (strpos($nomisma_value, 'nomisma.org') > 0 || strpos($nomisma_value, 'geonames.org') > 0){
						$mint_uri = $nomisma_value;
					}
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

					if (isset($nomisma_value)){
						if (strpos($nomisma_value, 'nomisma.org') > 0 || strpos($nomisma_value, 'geonames.org') > 0){
							$mint_uri = $nomisma_value;
						}
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
			if (isset($nomisma_value)){
				if (strpos($nomisma_value, 'nomisma.org') > 0 || strpos($nomisma_value, 'geonames.org') > 0){
					$mint_uri = $nomisma_value;
				}
			}
		}
	}
	if (strlen($mint_uri) > 0){
		if (strlen($label) > 0){
			$label = $label;
		} else {
			$label = $mint;
		}
		
		$geography = get_mintNode($mint_uri, $label, $certaintyType);
	} else {
		
		$geography['mint'] = array();
		$geography['mint']['label'] = $mint;
		if (isset($certaintyType)){
			$geography['mint']['certainty'] = $certaintyType;
		}
	}
	return $geography;
}

function get_mintNode($mint_uri, $label, $certaintyType){
	if (strpos($mint_uri, 'nomisma.org') > 0){
		
		//generate the mint array
		$geography['mint'] = array();
		$geography['mint']['label'] = $label;
		$geography['mint']['uri'] = $mint_uri;
		if (isset($certaintyType)){
			$geography['mint']['certainty'] = $certaintyType;
		}
	} elseif (strpos($mint_uri, 'geonames.org') > 0){
		//explode the geonames id, particularly necessary for Latin American coins where the mint varies from country of issue
		$uris = explode('|', $mint_uri);
		$mintUri = trim($uris[0]);

		$geography['mint'] = process_label($mintUri, $label, 'mint', $certaintyType, 0);
		
		if (isset($uris[1])){
			$geography['state'] = process_label(trim($uris[1]), $label, 'state', null, 1);
		}
		if (isset($uris[2])){
			$geography['authority'] = process_label(trim($uris[2]), $label, 'authority', null, 2);
		}
	}
	return $geography;
}

/* process_label */
function process_label ($uri, $label, $role, $certaintyType, $pos){
	$uriPieces = explode('/', $uri);
	$geonameId = $uriPieces[3];
	$geonameUri = 'http://www.geonames.org/' . $geonameId;
	
	//explode label pieces, display correct one
	$labelPieces = explode('|', trim($label));
	$place_name = trim($labelPieces[$pos]);
	
	$geography = array();
	$geography['label'] = $place_name;
	$geography['uri'] = $geonameUri;
	$geography['role'] = $role;
	if (isset($certaintyType)){
		$geography['certainty'] = $certaintyType;
	}

	return $geography;
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

/*
 * Parse the NUDS/XML for the coin type to generate a title that conforms to MANTIS convention
 * and also return the coin type title for use in the reference field
 */
function generate_title_from_type($uri){
	$titlePieces = array();
	$reference = '';
	
	$doc = new DOMDocument('1.0', 'UTF-8');
	
	if ($doc->load($uri . '.xml') !== FALSE){		
		$xpath = new DOMXpath($doc);
		$xpath->registerNamespace('nuds', 'http://nomisma.org/nuds');
		$xpath->registerNamespace('xlink', 'http://www.w3.org/1999/xlink');
		
		$reference = $xpath->query("descendant::nuds:title[@xml:lang='en']")->item(0)->nodeValue;
	
		$fields = $xpath->query("descendant::nuds:typeDesc/*");
		foreach ($fields as $field){
			//process single nodes
			if ($field->nodeName == 'objectType' || $field->nodeName == 'denomination' || $field->nodeName == 'date' || $field->nodeName == 'material'){
				$titlePieces[$field->nodeName] = $field->nodeValue;
			} elseif ($field->nodeName == 'dateRange'){
				$date = array();
				foreach ($field->childNodes as $child){
					//if an element XML_ELEMENT_NODE
					if ($child->nodeType == 1){
						$date[] = $child->nodeValue;
					}
				}
				//implode the fromDate and toDate and add to titlePieces
				$titlePieces['date'] = implode(' - ', $date);
			} elseif ($field->nodeName == 'authority'){
				$authorities = array();
				foreach ($field->childNodes as $child){
					//if an element XML_ELEMENT_NODE
					if ($child->nodeType == 1){
						if ($child->getAttribute('xlink:role') == 'authority'){
							$authorities[] = $child->nodeValue;
						}
					}
				}
				//implode authorities
				if (count($authorities) > 0){
					$titlePieces['authority'] = implode (', ', $authorities);
				}
			} elseif ($field->nodeName == 'geographic'){
				$mints = array();
				foreach ($field->childNodes as $child){
					//if an element XML_ELEMENT_NODE
					if ($child->nodeType == 1){
						if ($child->getAttribute('xlink:role') == 'mint'){
							$mints[] = $child->nodeValue;
						}
					}
				}
				//implode authorities
				if (count($mints) > 0){
					$titlePieces['mint'] = implode ('/', $mints);
				}
			}
		}
	}
	
	//assemble $titlePieces
	$title = '';
	if (count($titlePieces) > 0){
		if (array_key_exists('material', $titlePieces)){
			$title .= $titlePieces['material'];
		}
		if (array_key_exists('denomination', $titlePieces)){
			$title .= ' ' .  $titlePieces['denomination'];
		} else {
			$title .= ' ' . $titlePieces['objectType'];
		}
		if (array_key_exists('authority', $titlePieces)){
			$title .= ' of ' .  $titlePieces['authority'];
		}
		if (array_key_exists('mint', $titlePieces)){
			$title .= ', ' . $titlePieces['mint'];
		}
		if (array_key_exists('date', $titlePieces)){
			$title .= ', ';
			$title .= $titlePieces['date'];
		}
	}
	
	//echo "title:{$title}\n";
	
	$titles = array();
	if (strlen($title) > 0) {
		$titles['title'] = $title;
	}
	
	$titles['reference'] = $reference;
	
	return $titles;
	
}

function get_current_ocre_uri($url){
	$doc = new DOMDocument('1.0', 'UTF-8');
	if ($doc->load($url . '.rdf') === FALSE){
		return "FAIL";
	} else {
		$replacements = $doc->getElementsByTagNameNS('http://purl.org/dc/terms/', 'isReplacedBy');
		//echo "LENGTH" . $replacements->length . "\n";
		if ($replacements->length == 0){
			return $url;
		} elseif ($replacements->length == 1){
			return $replacements->item(0)->getAttribute('rdf:resource');
		} elseif ($replacements->length > 1) {
			return "FAIL";
		}
	}
}

function get_title_from_rdf($url){
	$doc = new DOMDocument();
	//if the rdf cannot be loaded, return FAIL, proceed to generation of typeDesc from Filemaker data
	if ($doc->load($url . '.rdf') === FALSE){
		return "FAIL";
	} else {
		$xpath = new DOMXpath($doc);
		$xpath->registerNamespace('skos', 'http://www.w3.org/2004/02/skos/core#');
		$xpath->registerNamespace('dcterms', 'http://purl.org/dc/terms/');
		$title = $xpath->query("descendant::skos:prefLabel[@xml:lang='en']|descendant::dcterms:title")->item(0)->nodeValue;
		return $title;		
	}	
}

//generate the typeDesc for RIC by pulling some fields from OCRE, but carry on the obverse/reverse types, legends and symbols
function generate_typeDesc_from_OCRE($writer, $row, $currentUri, $uncertain) {
	GLOBAL $coinTypes;

	//create DOMDocument and load from OCRE
	$doc = new DOMDocument('1.0', 'UTF-8');
	$doc->load($currentUri . '.xml');
	$xpath = new DOMXpath($doc);
	$xpath->registerNamespace('nuds', 'http://nomisma.org/nuds');
	$xpath->registerNamespace('xlink', 'http://www.w3.org/1999/xlink');
	$fields = $xpath->query("descendant::nuds:typeDesc/*");
	$coinTypes[$currentUri]['object'] = $fields;
	process_typeDesc_object($writer, $row, $fields, $uncertain);
}

//this function processes the DOMDocument Object stored in an array to minimize HTTP lookups for batch processing of OCRE links
function process_typeDesc_object($writer, $row, $fields, $uncertain){
	$writer->startElement('typeDesc');
	if ($uncertain == true){
		$writer->writeAttribute('certainty', 'uncertain');
	}
	foreach ($fields as $field){
		if ($field->nodeName != 'authority' && $field->nodeName != 'geographic' && $field->nodeName != 'dateRange' && $field->nodeName != 'obverse' && $field->nodeName != 'reverse'){
			$writer->startElement($field->nodeName);
			if ($field->getAttribute('xlink:href')){
				$writer->writeAttribute('xlink:href', $field->getAttribute('xlink:href'));
			}
			if ($field->getAttribute('xlink:type')){
				$writer->writeAttribute('xlink:type', 'simple');
			}
			if ($field->getAttribute('xlink:role')){
				$writer->writeAttribute('xlink:role', $field->getAttribute('xlink:role'));
			}
			if ($field->getAttribute('standardDate')){
				$writer->writeAttribute('standardDate', $field->getAttribute('standardDate'));
			}
			$writer->text($field->nodeValue);
			$writer->endElement();
				
				
		} elseif ($field->nodeName == 'authority' || $field->nodeName == 'geographic'){
			$writer->startElement($field->nodeName);
			foreach ($field->childNodes as $child){
				//if an element XML_ELEMENT_NODE
				if ($child->nodeType == 1){
					$writer->startElement($child->nodeName);
					if ($child->getAttribute('xlink:href')){
						$writer->writeAttribute('xlink:href', $child->getAttribute('xlink:href'));
					}
					if ($child->getAttribute('xlink:type')){
						$writer->writeAttribute('xlink:type', 'simple');
					}
					if ($child->getAttribute('xlink:role')){
						$writer->writeAttribute('xlink:role', $child->getAttribute('xlink:role'));
					}
					$writer->text($child->nodeValue);
					$writer->endElement();
				}
			}
			$writer->endElement();
		} elseif ($field->nodeName == 'dateRange'){
			$writer->startElement('dateRange');
			foreach ($field->childNodes as $child){
				//if an element XML_ELEMENT_NODE
				if ($child->nodeType == 1){
					$writer->startElement($child->nodeName);
					if ($child->getAttribute('standardDate')){
						$writer->writeAttribute('standardDate', $child->getAttribute('standardDate'));
					}
					$writer->text($child->nodeValue);
					$writer->endElement();
				}
			}
			$writer->endElement();
		} elseif ($field->nodeName == 'obverse' || $field->nodeName == 'reverse') {
			$nodeName = $field->nodeName;
			$writer->startElement($nodeName);
			//insert legend, description, and symbol from filemaker
			if (strlen(trim($row[$nodeName . 'legend'])) > 0){
				$writer->startElement('legend');
				$writer->writeAttribute('scriptCode', 'Latn');
				$writer->text(trim($row[$nodeName. 'legend']));
				$writer->endElement();
	
			}
			if (strlen(trim($row[$nodeName . 'type'])) > 0){
				$writer->startElement('type');
				$writer->startElement('description');
				$writer->writeAttribute('xml:lang', 'en');
				$writer->text(trim($row[$nodeName. 'type']));
				$writer->endElement();
				$writer->endElement();
			}
			if (strlen(trim($row[$nodeName . 'symbol'])) > 0){
				$writer->startElement('symbol');
				$writer->text(trim($row[$nodeName. 'symbol']));
				$writer->endElement();
			}
				
			//pluck out entities
			foreach ($field->childNodes as $child){
				if ($child->nodeName == 'persname' || $child->nodeName == 'corpname' || $child->nodeName == 'famname'){
					$writer->startElement($child->nodeName);
					if ($child->getAttribute('xlink:href')){
						$writer->writeAttribute('xlink:href', $child->getAttribute('xlink:href'));
					}
					if ($child->getAttribute('xlink:type')){
						$writer->writeAttribute('xlink:type', 'simple');
					}
					if ($child->getAttribute('xlink:role')){
						$writer->writeAttribute('xlink:role', $child->getAttribute('xlink:role'));
					}
					$writer->text($child->nodeValue);
					$writer->endElement();
				}
			}
			$writer->endElement();
		}
	}
	$writer->endElement();
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
	$solrDocUrl = 'http://localhost:8080/orbeon/numishare/mantis/ingest?identifiers=' . implode('\|', $array);
	$solrUrl = 'http://localhost:8080/solr/numishare/update';

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
