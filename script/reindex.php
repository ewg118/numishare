<?php 

$master = 'http://localhost:8080/exist/rest/db/mantis/objects';
$accnums = array();

$doc = new DOMDocument('1.0', 'UTF-8');
$doc->load($master);
$xpath = new DOMXpath($doc);
$xpath->registerNamespace('exist', 'http://exist.sourceforge.net/NS/exist');

$collections = $xpath->query("//exist:collection[not(child::node())]");

foreach ($collections as $year){
	$collection = $master . '/' . $year->getAttribute('name');
	
	$newDoc = new DOMDocument('1.0', 'UTF-8');
	$newDoc->load($collection);
	$files = $newDoc->getElementsByTagNameNS('http://exist.sourceforge.net/NS/exist', 'resource');		
	
	foreach ($files as $file){
		$accnums[] = str_replace('.xml', '', $file->getAttribute('name'));
		
		//index records into Solr in increments of 1,000
		if (count($accnums) > 0 && count($accnums) % 1000 == 0 ){
			$start = count($accnums) - 1000;
			$toIndex = array_slice($accnums, $start, 1000);
			
			//POST TO SOLR
			generate_solr_shell_script($toIndex);
		}
	}
}

//index final chunk
$start = floor(count($accnums) / 1000) * 1000;
$toIndex = array_slice($accnums, $start);

//POST TO SOLR
generate_solr_shell_script($toIndex);


/**** FUNCTIONS ****/
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

?>