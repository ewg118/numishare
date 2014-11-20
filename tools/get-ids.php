<?php 
/************************
 AUTHOR: Ethan Gruber
MODIFIED: November, 2012
DESCRIPTION: Query a Numishare atom feed with the Search API to download resources.
DIRECTIONS: edit the $format, $searchUrl, and $q variables and execute the PHP script
************************/

/************************
 * DEFINITION OF VARIABLES
 * $format = data format to return as a response; options are 'xml' (default), 'kml', 'rdf', 'ttl', 'jsonld'
 * $searchURL = URL to the search API
 * $q = query, conforming to Lucene query syntax
 * $sort = sort field and direction, 'timestamp+desc' default.  this will not have to be changed under most circumstances
 ************************/
$format = 'xml';
$searchUrl = 'http://localhost:8080/orbeon/numishare/apis/search';
$q = '*:*';
$sort = 'timestamp desc';
$feed = "{$searchUrl}?q={$q}&sort={$sort}&format=atom";

//load DOMDocument
$dom = new DOMDocument('1.0', 'UTF-8');
if ($dom->load($feed) === FALSE){
	echo "Feed failed to load: check query validity and search API URL.";
} else {
	processFeed($dom, $format);
}

function processFeed($dom, $format){
	$xpath = new DOMXpath($dom);
	$xpath->registerNamespace('atom', 'http://www.w3.org/2005/Atom');
	
	//download all alternate data streams on the current page of the Atom feed
	$entries = $xpath->query("descendant::atom:entry");
	
	foreach ($entries as $entry){
		$links = $entry->getElementsByTagNameNS('http://www.w3.org/2005/Atom', 'link');
		$id = $entry->getElementsByTagNameNS('http://www.w3.org/2005/Atom', 'id')->item(0)->nodeValue;
		
		//get associated atom:link
		foreach ($links as $link){
			if ($link->getAttribute('rel') == "alternate {$format}"){
				$data = getData($link->getAttribute('href'));
				
				//write file
				$file = fopen($id . '.' . $format, 'w') or die("can't open file");			
				fwrite($file, $data);
				fclose($file);
				echo "Wrote {$id}.\n";
			}
		}
	}
	
	//process NEXT page, if applicable
	$links = $xpath->query("descendant::atom:link[@rel='next']");
	foreach ($links as $link){
		$href = $link->getAttribute('href');
		$newDom = new DOMDocument('1.0', 'UTF-8');
		if ($newDom->load($href) === FALSE){
			echo "Feed failed to load: check query validity and search API URL.";
		} else {
			processFeed($newDom, $format);
		}
	}
}

/* gets the data from a URL */
function getData($url) {
	$curl = curl_init();
	$timeout = 5;
	curl_setopt($curl, CURLOPT_URL, $url);
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, $timeout);
	$data = curl_exec($curl);
	curl_close($curl);
	return $data;
}

?>
