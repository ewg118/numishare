<?php 

$ids = array("18207926","18207928","18207929","18207922","18207919","18207924","18207925","18207655","18202547","18207653","18207654","18207656","18207657","18207658","18207649","18207650","18207651","18207652","18207648","18202546","18207659","18207660","18207661","18207662","18200444","18207586","18202551","18207589","18207590","18207536","18207537","18207534","18207535","18207553","18207554","18207555","18207538","18207552","18202566","18202552","18207511","18207512","18207513","18207514","18202554","18207515","18200525","18207516","18207336","18207337","18207584","18207585","18207587","18207588","18207578","18207580","18207582","18207583","18207579","18206797","18207574","18207575","18207576","18207577","18207591","18202549","18207531","18207532","18207533","18207527","18207529","18202559","18207530","18207485","18207486","18207487","18207489","18207488","18207483","18206798","18207490","18207491","18207492","18207493","18207496","18207495","18207497","18207499","18207498","18206801","18207520","18202553","18207519","18207521","18207500","18207502","18207503","18207504","18207505","18207506");

$xml = "<?xml version='1.0' encoding='utf-8'?>";
$xml .= '<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/">';

foreach ($ids as $id){
	$url = 'http://www.smb.museum/ikmk/object.php?id=' . $id;
	$data = array();
	
	$doc = new DOMDocument('1.0', 'utf-8');
	$doc->loadHTMLFile($url);
	$xpath = new DOMXpath($doc);
	$divs = $xpath->query('descendant::div[@class="absatz"]');
	$images = $xpath->query('descendant::div[@id="objektAnsicht"]/descendant::img');
	$title = $xpath->query('descendant::h3')->item(0)->nodeValue;
	
	foreach ($divs as $div){	
		$key = NULL;
		$value= NULL;
		foreach($div->getElementsByTagName('div') as $node){
			//echo $node->nodeValue;
			$class = $node->getAttribute('class');
			if ($class == 'beschreibung'){
				$value = trim($node->nodeValue);
			} elseif ($class == 'parameter'){
				$key = trim($node->nodeValue);
			}
		}
		
		//clean up certain values
		if ($key == 'Gewicht'){
			$vals = explode(' ', str_replace(',', '.', $value));
			$data[$key] = $vals[0];
		} elseif ($key == 'Durchmesser'){
			$vals = explode(' ', $value);
			$data[$key] = $vals[0];
		} elseif ($key == 'Stempelstg.'){
			$vals = explode(' ', $value);
			$data[$key] = $vals[0];
		} elseif ($key == 'Literatur'){
			$refs = explode(';', $value);
			
			//pinpoint the RIC reference
			foreach ($refs as $ref){
				if (substr($ref, 0, 3) == "RIC"){
					$pieces = explode(' ', $ref);
						
					//assemble id
					$nomismaId = array();
					$nomismaId[] = 'ric';
						
					//volume
					switch ($pieces[1]) {
						case 'I²':
							$nomismaId[] = '1(2)';
							break;
						case 'II-1²':
							$nomismaId[] = '2_1(2)';
							break;
						case 'II':
							$nomismaId[] = '2';
							break;
						case 'III':
							$nomismaId[] = '3';
							break;
					}
					
					//authority
					$authority = $data['Münzherr'];
					if (strpos($authority,'Augustus') !== FALSE){
						$nomismaId[] = 'aug';
					} elseif (strpos($authority,'Tiberius') !== FALSE){
						$nomismaId[] = 'tib';
					} elseif (strpos($authority,'Caligula') !== FALSE){
						$nomismaId[] = 'gai';
					} elseif (strpos($authority,'Claudius') !== FALSE){
						$nomismaId[] = 'cl';
					} elseif (strpos($authority,'Nero') !== FALSE){
						$nomismaId[] = 'ner';
					} elseif (strpos($authority,'Galba') !== FALSE){
						$nomismaId[] = 'gal';
					} elseif (strpos($authority,'Otho') !== FALSE){
						$nomismaId[] = 'ot';
					} elseif (strpos($authority,'Vitellius') !== FALSE){
						$nomismaId[] = 'vit';
					} elseif (strpos($authority,'Macer') !== FALSE){
						$nomismaId[] = 'clm';
					} elseif (strpos($authority,'Vespasianus') !== FALSE){
						$nomismaId[] = 'ves';
					} elseif (strpos($authority,'Titus') !== FALSE){
						$nomismaId[] = 'tit';
					} elseif (strpos($authority,'Domitianus') !== FALSE){
						$nomismaId[] = 'dom';
					} elseif (strpos($authority,'Nerva') !== FALSE){
						$nomismaId[] = 'ner';
					} elseif (strpos($authority,'Traianus') !== FALSE){
						$nomismaId[] = 'tr';
					} elseif (strpos($authority,'Hadrianus') !== FALSE){
						$nomismaId[] = 'hdn';
					} elseif (strpos($authority,'Pius') !== FALSE){
						$nomismaId[] = 'ant';
					} else {
						$nomismaId[] = 'cw';
					}
											
					//number
					if (strlen($pieces[4]) == 1){
						//first try capitalization of the letter
						$url = 'http://numismatics.org/ocre/id/' . implode('.', $nomismaId) . '.' . $pieces[3] . strtoupper($pieces[4]);
						$file_headers = @get_headers($url);
						if ($file_headers[0] == 'HTTP/1.1 200 OK'){
							$nomismaId[] = $pieces[3] . strtoupper($pieces[4]);
						} else {
							$url = 'http://numismatics.org/ocre/id/' . implode('.', $nomismaId) .  '.' . $pieces[3] . $pieces[4];
							$file_headers = @get_headers($url);
							if ($file_headers[0] == 'HTTP/1.1 200 OK'){
								$nomismaId[] = $pieces[3] . $pieces[4];
							}
						}
						
					} else {
						$nomismaId[] = $pieces[3];
					}						
					$uri = 'http://numismatics.org/ocre/id/' . implode('.', $nomismaId);
				}				
			}
		} else {
			$data[$key] = $value;
		}
	}
	
	//output document	
	$xml .= '<nm:coin rdf:about="http://www.smb.museum/ikmk/object.php?id=' . $data['Objektnummer'] . '">';
	$xml .=	 '<nm:type_series_item rdf:resource="' . $uri . '"/>';
	$xml .= '<dcterms:title xml:lang="de">' . $title . '</dcterms:title>';
	$xml .= '<dcterms:identifier>' . $data['Objektnummer'] . '</dcterms:identifier>';
	$xml .= '<dcterms:publisher>MK Berlin</dcterms:publisher>';
	$xml .= '<nm:collection rdf:resource="http://nomisma.org/id/mk_berlin"/>';
	$xml .= '<nm:axis rdf:datatype="xs:integer">' . $data['Stempelstg.'] . '</nm:axis>';
	$xml .= '<nm:diameter rdf:datatype="xs:decimal">' . $data['Durchmesser'] . '</nm:diameter>';
	$xml .= '<nm:weight rdf:datatype="xs:decimal">' . $data['Gewicht'] . '</nm:weight>';
	
	//insert images
	foreach ($images as $img){
		$src = $img->getAttribute('src');
		$resource = 'http://www.smb.museum/' . substr($src, 3);
		if (strpos($src,'vs_') !== FALSE){
			$xml .= '<nm:obverseReference rdf:resource="' . $resource . '"/>';
		} elseif (strpos($src,'rs_') !== FALSE){
			$xml .= '<nm:reverseReference rdf:resource="' . $resource . '"/>';
		}
	}
	//close description
	$xml .= '</nm:coin>';
}

$xml .= '</rdf:RDF>';

$dom = new DOMDocument('1.0', 'UTF-8');
if ($dom->loadXML($xml) === FALSE){
	echo "{$id} failed to validate.\n";
} else {
$dom->preserveWhiteSpace = FALSE;
$dom->formatOutput = TRUE;
echo $dom->saveXML() . "\n";
$dom->save('berlin.rdf');
}

?>