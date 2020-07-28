<?php
/************************
AUTHOR: Ethan Gruber
MODIFIED: January, 2018
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

//include relevant functions stored in other files
include 'row-to-object.php';
include 'normalization.php';
include 'object-to-nuds.php';

define("INDEX_COUNT", 500);

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
//$csv_id = 'fm-us-test';
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
//store an array of all succesfully processed objects for batch indexing
$accnums = array();

//load Google Spreadsheets
$Byzantine_array = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vQBsPg2dHki4f-z2fq0wY4Cqcibkwk_RitLLyaAJ4S3VV0W5pF5dMpgUMfX_cVf2mw8EMZaJLn0h_XF/pub?output=csv');
$Decoration_array = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vRzXMfNbEQ1mhQD6N6pAApF3qiY7ZVUIVttEsenZIo16Kn2rLyyw-OyE82jwoXcf44amBcz1pzpOVg9/pub?output=csv');
$East_Asian_array = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vSEpksT55dnmRw32OPj4CbJnPbO5ycjksrn-9arFB9oF6wtOA3SUfKRVMyuWOqTFWEKYzvyTFzxOA-n/pub?output=csv');
$Greek_array = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vRoDROgTRe2oXfj5srWQm9xALt0ztV7745S90lbBWUi2j16UmMmYH2B2XbEhj1c3Sni3W7fDsNnM2BP/pub?output=csv');
$Islamic_array = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vQOpj_KPqLH0VtK3T5PUmFRBOC0j788nXhIIJw33Y50Iab_XSEzlLCfu4UrypaV8ZppjsidkWvVSvcz/pub?output=csv');
$Latin_American_array = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vSDbVOA3Sh0Zhhb13V4q3NPIA2N-fJiSgb2-c7Jf7XDJLUL2wO2vfgD5KjgbY72aC3j9aasb5ogC4-k/pub?output=csv');
$Medal_array = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vRegeOXLwQGoi9tSGXmd8B_eyCGC3gsuiUG7hCgJdvVr_zePhOLQ4ogkGcJHleP9o3S9e27xvyM0E2z/pub?output=csv');
$Medieval_array = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vQwKucfaQmyVVJMb0Ia_kDflx446U8CJ_O1kzbjimUOtOFDgPi4sy8M1s5BWNhZu9-q-WeA5hVtO9Bt/pub?output=csv');
$Modern_array = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vQbGr1pk3X9dTtJN_xox10Ze94nHCy1Q7qYHy0KPngCMiThTZhDtihyRPS3Mx2XVKsOSur3C1r7KURu/pub?output=csv');
$Roman_array = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vSy6fRVmhLRkJQcsWmxaQfch6oVGUtP3M_hjNDmuGNQXvF266PLi4vjsrXnxFDEo0I1KRoMjYZ815Xm/pub?output=csv');
$South_Asian_array = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vRuTGEVOB3v5qOigC1ubHJ82QDApxiPxRR8q7TFhVKLZTRJCwCMsk8_0VvekM_kUufwb646XPAuAdil/pub?output=csv');
$United_States_array = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vQLO452BttROCPIvTq5USc2SXxXYwxCVMK_nR3NUmPLiYG-cg-mejS5VtAEsd-W2IHSKSnfZo2ckIR8/pub?output=csv');
$Greek_authorities_array = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vSLKDSk4XUSnTyoYdvHTGPH906wnWtaHcZRxufR2BLRTdaira5m-LPvHsJCxV15dwGIk7NUevPmSDzl/pub?output=csv');
$Islamic_authorities_array = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vSBIAYUmxMxp_--jLHYcNoapdUiWCNc99ZcEo8Vo9fwZXK78TkK34fMzptZu5mLH3ylOYUXwCOI6bQY/pub?output=csv');

/*//SCO spreadsheet for mapping SC to the new SCO number
$sco_array = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vQLdeurX2qJZ6zN-uWLJex2DylQOx3wav5ZCMgAidsy6yilV4j8cco9WEuvXckxEJhuSnBTmJaF4zPj/pub?gid=998961995&single=true&output=csv');
//process full $sco spreadsheet into key=>value array
$sco = array();
foreach ($sco_array as $row){
	$uri = 'http://numismatics.org/sco/id/' . $row['ID'];
	$sco[$row['SC no.']] = $uri;
}*/

//deities
$deities_array = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdHk2ZXBuX0RYMEZzUlNJUkZOLXRUTmc&single=true&gid=0&output=csv');

//keep array of valid coin type URIs to reduce the number of lookups
$coinTypes = array();

//keep array of hoard (IGCH) URIs to reduce the number of lookups
$hoards = array();

//get the eXist-db password from disk
$eXist_config_path = '/usr/local/projects/numishare/exist-config.xml';

if (file_exists($eXist_config_path)) {
	$eXist_config = simplexml_load_file($eXist_config_path);
	$eXist_credentials = $eXist_config->username . ':' . $eXist_config->password;
	echo $eXist_credentials . "\n";
	
	if (($handle = fopen("/tmp/" . $csv_id . ".csv", "r")) !== FALSE) {
		error_log(date(DATE_W3C) . ": {$csv_id}.csv successfully opened for processing.\n", 3, "/var/log/numishare/process.log");
		$startTime = date(DATE_W3C);
		$count = 1;
		
		//open CSV file from FileMaker and clean it, writing it back to /tmp
		$file = file_get_contents("/tmp/" . $csv_id . ".csv");
		$cleanFile = '/tmp/' . substr(md5(rand()), 0, 7) . '.csv';
		//escape conflicting XML characters
		$cleaned = preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F\x80-\x9F]/u', '', preg_replace("[\x1D]", "|", str_replace('>', '&gt;', str_replace('<', '&lt;', str_replace('&', 'and', preg_replace("[\x0D]", "\n", $file))))));
		file_put_contents($cleanFile, $cleaned);
		
		//open the cleaned CSV file for processing
		if (($cleanHandle = fopen($cleanFile, "r")) !== FALSE) {
			error_log(date(DATE_W3C) . ": {$csv_id}.csv cleaned. {$cleanFile} opened for processing.\n", 3, "/var/log/numishare/process.log");
			while (($data = fgetcsv($cleanHandle, 2500, ',', '"')) !== FALSE) {
				$row = array();
				foreach ($labels as $key=>$label){
					$row[$label] = preg_replace('/\s+/', ' ', $data[$key]);
				}
				if (strlen(trim($row['department'])) == 0){
				    //report a 0 length department as an error
				    $accnum = trim($row['accnum']);				   
				    error_log($accnum . ' does not contain a department value: ' . date(DATE_W3C) . "\n", 3, "/var/log/numishare/error.log");
				    $errors[] = $count . ': ' . $accnum . ' does not contain a department value';
				} else {
				    if (trim(strtoupper($row['department'])) != 'J'){
				        //create new filename path
				        $collection = 'mantis';
				        $department = get_department($row['department']);
				        
				        $accnum = trim($row['accnum']);
				        $accPieces = explode('.', $accnum);
				        $accYear = $accPieces[0];
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
				                
				                //generate a data object by parsing the contents of the Filemaker row
				                $record = parse_row($row, $count, $fileName);
				                //var_dump($record);
				                
				                //serialize the data object into a NUDS/XML document and write to /tmp
				                generate_nuds($record, $fileName);
				                
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
				                    curl_setopt($putToExist,CURLOPT_USERPWD,$eXist_credentials);
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
				                            $accnums[] = $accnum;
				                            
				                            //index records into Solr in increments of the INDEX_COUNT constant
				                            if (count($accnums) > 0 && count($accnums) % INDEX_COUNT == 0 ){
				                                $start = count($accnums) - INDEX_COUNT;
				                                $toIndex = array_slice($accnums, $start, INDEX_COUNT);
				                                
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
		$start = floor(count($accnums) / INDEX_COUNT) * INDEX_COUNT;
		$toIndex = array_slice($accnums, $start);
		
		//POST TO SOLR
		generate_solr_shell_script($toIndex);
		
		fclose($handle);
		//unlink("/tmp/" . $csv_id . ".csv");
		error_log(date(DATE_W3C) . ": Processing completed. /tmp/{$csv_id}.csv has been deleted.\n", 3, "/var/log/numishare/process.log");
	} else {
		$errors[] = date(DATE_W3C) . ": Unable to open {$csv_id}.csv.\n";
		error_log(date(DATE_W3C) . ": Unable to open {$csv_id}.csv.\n", 3, "/var/log/numishare/process.log");
	}
} else {
	$errors[] = date(DATE_W3C) . ": Unable to open the Numishare exist-config.xml";
	error_log(date(DATE_W3C) . ": Unable to open the Numishare exist-config.xml\n", 3, "/var/log/numishare/process.log");
}

//send email report
generate_email_report($csv_id, $accnums, $errors, $warnings, $startTime, $endTime);

/***** JSON PARSING FUNCTIONS *****/
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

/***** PUBLICATION AND REPORTING FUNCTIONS *****/
//generate a shell script to activate batch ingestion
function generate_solr_shell_script($array){
	$uniqid = uniqid();
	$solrDocUrl = 'http://localhost:8080/orbeon/numishare/mantis/ingest?identifiers=' . implode('%7C', $array);
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

//send an email report
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
?>
