<?php 

/************************
 AUTHOR: Ethan Gruber
 MODIFIED: June, 2020
 DESCRIPTION: Contains all of the functions for parsing and normalizing fields to standardized labels and URIs from internal or external 
 (Google Spreadsheets) lookup mechanisms
 ************************/

/***** GEOGRAPHY *****/
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
			$uri = $result['uri'];
			$label = $result['label'];
		}
		
		if (isset($uri)){
			if (strpos($uri, 'nomisma.org') > 0 || strpos($uri, 'geonames.org') > 0){
				$mint_uri = $uri;
			}
		}
	}
	//if there is a region: test for available of locality
	if (count($regions_array) > 0){
		if (count($localities_array) == 0){
			foreach ($regions_array as $rv){
				$results = array_filter($$geoData, array(new filterGeo($mint, $rv, ''), 'matches'));
				
				foreach ($results as $result){
					$uri = $result['uri'];
					$label = $result['label'];
				}
				if (isset($uri)){
					if (strpos($uri, 'nomisma.org') > 0 || strpos($uri, 'geonames.org') > 0){
						$mint_uri = $uri;
					}
				}
			}
		} else {
			foreach ($regions_array as $rv){
				foreach ($localities_array as $lv) {
					$results = array_filter($$geoData, array(new filterGeo($mint, $rv, $lv), 'matches'));
					
					foreach ($results as $result){
						$uri = $result['uri'];
						$label = $result['label'];
					}
					
					if (isset($uri)){
						if (strpos($uri, 'nomisma.org') > 0 || strpos($uri, 'geonames.org') > 0){
							$mint_uri = $uri;
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
				$uri = $result['uri'];
				$label = $result['label'];
			}
			if (isset($uri)){
				if (strpos($uri, 'nomisma.org') > 0 || strpos($uri, 'geonames.org') > 0){
					$mint_uri = $uri;
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

//evaluate geographic label based on source of URI
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

//process the geographic label into an array depending on field context
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

/***** NORMALIZING NON-GEOGRAPHIC ENTITIES TO URIS *****/
function lookup_entity ($department, $val, $uncertain, $role){    
    GLOBAL $Greek_authorities_array;
    
    $found = false;
    
    foreach ($Greek_authorities_array as $row){
        if ($row['match'] == $val){
            if (strlen($row['uri']) > 0){
                //if it's a deity, return null. The deity will already be parsed from the type description, so it should not be indexed as an authority.
                if ($row['type'] == 'deity'){
                    return null;
                } else {
                    return array('label'=>$row['prefLabel_en'], 'uri'=>$row['uri'], 'uncertain'=>$uncertain, 'element'=>$row['type'], 'role'=>$role);
                }                
            } else {
                return array('label'=>$val, 'uncertain'=>$uncertain, 'element'=>'persname', 'role'=>$role);
            }
        }
    }
    
    //if the key has not been found after checking the spreadsheet, return the default values
    return array('label'=>$val, 'uncertain'=>$uncertain, 'element'=>'persname', 'role'=>$role);
}

/***** DATES *****/
//evaluate the fromDate and toDate for use in the nuds:title
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

//generate human-readable date based on the integer value
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

/**
 * Check input for existing only of digits (numbers)
 * @author Guilherme Nascimento <brcontainer@yahoo.com.br>
 * @param $digit
 * @return bool
 */
//better way to evaluate if the start or end date is actually an integer
function is_digit($digit)
{
    return preg_match('#^-?\d+$#', $digit) && is_int((int) $digit);
}

/***** MISCELLANEOUS *****/
//parse department abbreviations into human-readable text
function get_department($department){
	
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
	return $dept_string;
}

//normalize common object types to Nomisma URIs and preferred labels
function normalize_objtype($objtype){
	$val = trim(strtolower($objtype));
	$objectType = array();
	switch ($val) {
		case 'coin':
		case 'c':
			$objectType['label'] = 'Coin';
			$objectType['uri'] = 'http://nomisma.org/id/coin';
			break;
		case 'decoration':
		case 'de':
			$objectType['label'] = 'Decoration';
			break;
		case 'ingot':
			$objectType['label'] = 'Ingot';
			$objectType['uri'] = 'http://nomisma.org/id/ingot';
			break;
		case 'medal':
		case 'me':
			$objectType['label'] = 'Medal';
			$objectType['uri'] = 'http://nomisma.org/id/medal';
			break;
		case 'paper':
		case 'p':
			$objectType['label'] = 'Paper Money';
			$objectType['uri'] = 'http://nomisma.org/id/paper_money';
			break;
		case 'token':
		case 't':
			$objectType['label'] = 'Token';
			$objectType['uri'] = 'http://nomisma.org/id/token';
			break;
		default:
			$objectType['label'] = ucfirst(strtolower(trim($objtype)));
	}
	
	return $objectType;
}

//parse combined materials (separated by - or / depending on semantic meaning) into individual material entries in the data object
function parse_material($material){
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
		return $mat_array;
	}
}

//normalize common material strings into Nomisma URIs and preferred labels
function normalize_material($material){
	$val = trim(str_replace('"', '', $material));
	$uncertain = substr($val, -1) == '?' ? true : false;
	$label = trim(str_replace('?', '', $val));
	
	$mat_array = array('uncertain'=>$uncertain);
	switch (strtoupper($label)) {
		case 'AE':
		case 'BRONZE':
			$mat_array['label'] = 'Bronze';
			$mat_array['uri'] = 'http://nomisma.org/id/ae';
			break;
		case 'AL':
		case 'ALUMINUM':
			$mat_array['label'] = 'Aluminum';
			$mat_array['uri'] = 'http://nomisma.org/id/al';
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

/*
 * Parse the NUDS/XML for the coin type to generate a title that conforms to MANTIS convention
 * and also return the coin type title for use in the reference field
 */
function generate_title_from_type($uri){
	$titlePieces = array();
	$reference = '';
	
	//get the NUDS XML URL based on domain
	if (strpos($uri, 'rpc.ashmus') !== FALSE){
		$pieces = explode('/', $uri);
		
		$xml_url = 'https://rpc.ashmus.ox.ac.uk/id/rpc-' . $pieces[4] . '-' . $pieces[5] . '.xml';
	} else {
		$xml_url = $uri . '.xml';
	}
	
	$doc = new DOMDocument('1.0', 'UTF-8');
	
	if ($doc->load($xml_url) !== FALSE){
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
	$titles['object']  = $fields;
	
	return $titles;
	
}

?>