<?php 

/************
 * Author: Ethan Gruber
 * Date: September, 2013
 * Function: Receive 'id' request parameter and execute fm-to-nuds.php 
 * on the command line to process CSV file in the background.
 ***********/
//the line below is for passing request parameters from the command line.
//parse_str(implode('&', array_slice($argv, 1)), $_GET);
$csv_id = $_GET['id'];

if (($handle = fopen("/tmp/" . $csv_id . ".csv", "r")) !== FALSE) {
	error_log(date(DATE_W3C) . ": {$csv_id}.csv received via HTTP for processing.\n", 3, "/var/log/numishare/process.log");
	exec("php fm-to-nuds.php id={$csv_id} > /dev/null &");
	echo generate_html_response($csv_id, true);
} else {
	echo generate_html_response($csv_id, false);
}

function generate_html_response($csv_id, $success){
	if ($success == true){
		$body = "<html><head><title>Processing {$csv_id}.csv</title></head>";
		$body .= "<body><h1>Processing {$csv_id}.csv</h1>";
		$body .= '<p>The CSV file is now in process.</p>';
		$body .= '</body></html>';
	} else {
		$body = "<html><head><title>Error</title></head>";
		$body .= "<body><h1>File not found: {$csv_id}.csv</h1>";
		$body .= '<p>The file passed by the URL parameter was not found in /tmp</p>';
		$body .= '</body></html>';
	}

	return $body;
}

?>