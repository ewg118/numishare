<?php 

//Berlin's list of LIDO XML files
$list = file_get_contents('http://ww2.smb.museum/mk_edit/coin_export/4/content.txt');
$files = explode(PHP_EOL, $list);

$csv = '"object_number","URI","ref"' . "\n";

$count = 1;
foreach ($files as $file){
	if (strlen($file) > 0){
		$fileArray = explode('/', $file);
		$objectNumber = str_replace('.xml', '', $fileArray[count($fileArray) - 1]);
		$dom = new DOMDocument('1.0', 'UTF-8');
		if ($dom->load($file) === FALSE){
			echo "{$file} failed to load.\n";
		} else {
			$xpath = new DOMXpath($dom);
			$xpath->registerNamespace("lido", "http://www.lido-schema.org");
			$refNodes = $xpath->query("descendant::lido:relatedWorkSet[lido:relatedWorkRelType/lido:term='reference']/lido:relatedWork/lido:object/lido:objectNote");
		
			if (count($refNodes) > 0){
				$ref = $refNodes->item(0)->nodeValue;
				if (strstr($ref, 'RRC') !== FALSE){
					$pieces = explode(',', $ref);
					
					$frag = array();
					$frag[] = ltrim(trim($pieces[1]), '0');
					if (isset($pieces[2])) {
						$frag[] = ltrim(trim($pieces[2]), '0');
					} else {
						$frag[] = '1';
					}
					
					$id = 'rrc-' . implode('.', $frag);
					//test which number matches in OCRE
					$csv .= '"' . $objectNumber . '","';
					
					$url = 'http://admin.numismatics.org/rrc/id/' . $id . '.xml';
					$file_headers = @get_headers($url);
					if ($file_headers[0] == 'HTTP/1.1 200 OK'){
						//create line in CSV
						$uri = 'http://numismatics.org/rrc/id/' . $id;
						$csv .= $uri;
						echo "{$count}: {$objectNumber} - {$uri}\n";
					}
						$csv .= '","' . $ref .'"' . "\n";
				}
				
			}			
		}		
	}
	$count++;
}

//write csv file
file_put_contents('berlin-concordances.csv', $csv);

?>