<?php 

//Berlin's list of LIDO XML files
$list = file_get_contents('http://ww2.smb.museum/mk_edit/coin_export/2/content.txt');
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
					case 'IV-1':
					case 'IV-2':
					case 'IV-3':
						$nomismaId[] = '4';
						break;
					case 'V-1':
						$nomismaId[] = '5';
						break;
					default:
						$nomismaId[null];
				}
					
				//normalize authority
				$names = array_slice($pieces, 2, count($pieces) - 3);
				$authority = str_replace(',', '', implode(' ', $names));
				switch ($authority) {
					case 'Augustus':
						$nomismaId[] = 'aug';
						break;
					case 'Tiberius':
						$nomismaId[] = 'tib';
						break;
					case 'Caligula':
						$nomismaId[] = 'gai';
						break;
					case 'Claudius':
						$nomismaId[] = 'cl';
						break;
					case 'Nero':
						$nomismaId[] = 'ner';
						break;
					case 'Galba':
						$nomismaId[] = 'gal';
						break;
					case 'Otho':
						$nomismaId[] = 'ot';
						break;
					case 'Vitellius':
						$nomismaId[] = 'vit';
						break;
					case 'Macer':
						$nomismaId[] = 'clm';
						break;
					case 'Civil Wars':
						$nomismaId[] = 'cw';
						break;
					case 'Vespasianus':
						$nomismaId[] = 'ves';
						break;
					case 'Titus':
						$nomismaId[] = 'tit';
						break;
					case 'Domitianus':
						$nomismaId[] = 'dom';
						break;
					case 'Nerva':
						$nomismaId[] = 'ner';
						break;
					case 'Traianus':
						$nomismaId[] = 'tr';
						break;
					case 'Hadrianus':
						$nomismaId[] = 'hdn';
						break;
					case 'Pius':
						$nomismaId[] = 'ant';
						break;
					case 'Aurelius':
						$nomismaId[] = 'm_aur';
						break;
					case 'Commodus':
						$nomismaId[] = 'com';
						break;
					case 'Pertinax':
						$nomismaId[] = 'pert';
						break;
					case 'Didius Iulianus':
						$nomismaId[] = 'dj';
						break;
					case 'Niger':
						$nomismaId[] = 'pn';
						break;
					case 'Clodius Albinus':
						$nomismaId[] = 'ca';
						break;
					case 'Septimius Severus':
						$nomismaId[] = 'ss';
						break;
					case 'Caracalla':
						$nomismaId[] = 'crl';
						break;
					case 'Geta':
						$nomismaId[] = 'ge';
						break;
					case 'Macrinus':
						$nomismaId[] = 'mcs';
						break;
					case 'Elagabalus':
						$nomismaId[] = 'el';
						break;
					case 'Severus Alexander':
						$nomismaId[] = 'sa';
						break;
					case 'Maximinus Thrax':
						$nomismaId[] = 'max_i';
						break;
					case 'Maximus':
						$nomismaId[] = 'mxs';
						break;
					case 'Diva Paulina':
						$nomismaId[] = 'pa';
						break;
					case 'Gordianus I.':
						$nomismaId[] = 'gor_i';
						break;
					case 'Gordianus II.':
						$nomismaId[] = 'gor_ii';
						break;
					case 'Pupienus':
						$nomismaId[] = 'pup';
						break;
					case 'Balbinus':
						$nomismaId[] = 'balb';
						break;
					case 'Gordianus III. Caesar':
						$nomismaId[] = 'gor_iii_caes';
						break;
					case 'Gordianus III.':
						$nomismaId[] = 'gor_iii';
						break;
					case 'Philippus I.':
						$nomismaId[] = 'ph_i';
						break;
					case 'Pacatianus':
						$nomismaId[] = 'pac';
						break;
					case 'Iotapianus':
						$nomismaId[] = 'jot';
						break;
					case 'Decius':
						$nomismaId[] = 'tr_d';
						break;
					case 'Trebonianus':
						$nomismaId[] = 'tr_g';
						break;
					case 'Aemilianus':
						$nomismaId[] = 'aem';
						break;
					case 'Uranus':
						$nomismaId[] = 'uran_ant';
						break;
					default:
						$nomismaId[] = null;
				}
					
				//add number
				$num = ltrim($pieces[count($pieces) - 1], '0');
					
				//test which number matches in OCRE
				$csv .= '"' . $objectNumber . '","';
				if ($nomismaId[1] != null && $nomismaId[2] != null && strlen($num) > 0){
					$url = 'http://numismatics.org/ocre/id/' . implode('.', $nomismaId) . '.' . strtoupper($num) . '.xml';
					$file_headers = @get_headers($url);
					if ($file_headers[0] == 'HTTP/1.1 200 OK'){
						$nomismaId[] = strtoupper($num);
					} else {
						$url = 'http://numismatics.org/ocre/id/' . implode('.', $nomismaId) .  '.' . $num . '.xml';
						$file_headers = @get_headers($url);
						if ($file_headers[0] == 'HTTP/1.1 200 OK'){
							$nomismaId[] = $num;
						}
					}
				
					//create line in CSV
					$uri = 'http://numismatics.org/ocre/id/' . implode('.', $nomismaId);
					$csv .= $uri;
					echo "{$count}: {$objectNumber} - {$uri}\n";
				}
				$csv .= '","' . $ref .'"' . "\n";
			}			
		}		
	}
	$count++;
}

//write csv file
file_put_contents('berlin-concordances.csv', $csv);

?>