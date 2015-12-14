<?php 

/* Author: Ethan Gruber
 * Date: December 2015
 * Function: To process CSV files exported from the Portable Antiquities Scheme SPARQL endpoint 
 * and link these coins to URIs in OCRE by highest score from the OCRE Atom feed.
 * See SPARQL query at https://gist.github.com/ewg118/9fbfc71772deb5e71964
 */

$data = generate_json("queryResults.csv");
$feed = 'http://numismatics.org/ocre/feed/';

$results = array();
$results[] = array('object', 'authority', 'mint', 'denomination', 'obvType', 'obvLegend', 'revType', 'revLegend', 'altMint', 'altAuthority', 'match1', 'score1', 'match2', 'score2', 'match3', 'score3', 'match4', 'score4', 'match5', 'score5','match6','score6','match7','score7','match8','score8');

foreach ($data as $row){
	echo "Processing {$row['s']}\n";
	
	//generate the Solr query
	$query = array();
	$query['mint_uri'] = trim($row['mint']);
	$query['authority_uri'] = trim($row['authority']);
	if (strlen($row['denomination']) > 0){
		$query['denomination_uri'] = trim($row['denomination']);
	}
	
	/* Legend parsing rules:
	 * 1. replace U with V
	 * 2. replace line break forward slashes with whitespace
	 * 3. strip left and right square brackets
	 * 4. replace elipses with an asterisk for wildcard searches on incomplete legends
	 * 5. do the same for multiple hyphens
	 */
	
	//parse obverse legend
	$obvLegend = trim(str_replace('U', 'V', str_replace('/', ' ', trim($row['obvLegend']))));
	$obvLegend = str_replace('[', '', str_replace(']', '', preg_replace("/[\r|\n]/","",trim($obvLegend))));
	$obvLegend = preg_replace('/\.+/', '*', $obvLegend);
	$obvLegend = preg_replace('/[-]+/', '*', $obvLegend);
	preg_match_all('/([A-Z]+)/', $obvLegend, $obvWords);
	if (count($obvWords[0]) > 0){
		$query['obv_leg_text'] = implode('+', $obvWords[0]);
	}	
	
	//parse reverse legend
	$revLegend = trim(str_replace('U', 'V', str_replace('/', ' ', trim($row['revLegend']))));
	$revLegend = str_replace('[', '', str_replace(']', '', preg_replace("/[\r|\n]/","",trim($revLegend))));
	$revLegend = preg_replace('/\.+/', '*', $revLegend);
	$revLegend = preg_replace('/[-]+/', '*', $revLegend);
	preg_match_all('/([A-Z]+)/', $revLegend, $revWords);
	if (count($revWords[0]) > 0){
		$query['rev_leg_text'] = implode('+', $revWords[0]);
	}	
	$altMint = '';
	$altAuthority = '';
	
	//only execute query if there are obverse and reverse legends
	$matches = array();
	if (count($obvWords[0]) > 0 && count($revWords[0]) > 0){
		$frags = array();
		foreach ($query as $k=>$v){
			$frags[] = $k . ':' . (strpos($k, '_uri') !== FALSE ? '"' . $v . '"' : $v);
		}
		
		$q = implode(' AND ', $frags);
		
		$dom = new DOMDocument();
		$dom->load("{$feed}?q={$q}&sort=score desc");
		
		$xpath = new DOMXpath($dom);
		$xpath->registerNamespace('atom', 'http://www.w3.org/2005/Atom');
		
		$entries = $xpath->query("descendant::atom:entry");
		$count = $entries->length;
		
		//if there is no response, then re-issue the query minus the mint
		if ($count == 0){
			$altMint = 'true';
			unset($frags[0]);
			$q = implode(' AND ', $frags);
			$dom = new DOMDocument();
			$dom->load("{$feed}?q={$q}&sort=score desc");
			
			$xpath = new DOMXpath($dom);
			$xpath->registerNamespace('atom', 'http://www.w3.org/2005/Atom');
			
			$entries = $xpath->query("descendant::atom:entry");
			$count = $entries->length;
			
			
			//if there are no matches, then remove the authority
			if ($count == 0){
				$altAuthority = 'true';
				unset($frags[1]);
				$q = implode(' AND ', $frags);
				$dom = new DOMDocument();
				$dom->load("{$feed}?q={$q}&sort=score desc");
					
				$xpath = new DOMXpath($dom);
				$xpath->registerNamespace('atom', 'http://www.w3.org/2005/Atom');
					
				$entries = $xpath->query("descendant::atom:entry");
				$count = $entries->length;
				if ($count > 0){
					foreach ($entries as $entry){
						$position = $entry->getNodePath();
						if ($position <= 5){
							$id = $entry->getElementsByTagNameNS('http://www.w3.org/2005/Atom', 'id')->item(0)->nodeValue;
							$score = $entry->getElementsByTagNameNS('http://a9.com/-/opensearch/extensions/relevance/1.0/', 'score')->item(0)->nodeValue;
							$matches[$id] = $score;
						}
					}
				}
			} else {
				foreach ($entries as $entry){
					$position = $entry->getNodePath();
					if ($position <= 5){
						$id = $entry->getElementsByTagNameNS('http://www.w3.org/2005/Atom', 'id')->item(0)->nodeValue;
						$score = $entry->getElementsByTagNameNS('http://a9.com/-/opensearch/extensions/relevance/1.0/', 'score')->item(0)->nodeValue;
						$matches[$id] = $score;
					}
				}
			}
				
		} else {
			foreach ($entries as $entry){
				$position = $entry->getNodePath();
				if ($position <= 5){
					$id = $entry->getElementsByTagNameNS('http://www.w3.org/2005/Atom', 'id')->item(0)->nodeValue;
					$score = $entry->getElementsByTagNameNS('http://a9.com/-/opensearch/extensions/relevance/1.0/', 'score')->item(0)->nodeValue;
					$matches[$id] = $score;					
				}
			}
		}
	}
	
	$record = array(trim($row['s']), trim($row['authority']), trim($row['mint']), trim($row['denomination']), preg_replace("/[\r|\n]/","",trim($row['obvType'])), preg_replace("/[\r|\n]/","",trim($row['obvLegend'])), preg_replace("/[\r|\n]/","",trim($row['revType'])), preg_replace("/[\r|\n]/","",trim($row['revLegend'])), $altMint, $altAuthority);
	$count = 1;
	foreach ($matches as $k=>$v){
		$record[] = $k;
		$record[] = $v;
		$count++;
	}
	
	$results[] = $record;
}

$fp = fopen("pas-concordances.csv", 'w');
foreach ($results as $record) {
	fputcsv($fp, $record);
}
fclose($fp);


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
		$keys[] = trim($label);
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

?>