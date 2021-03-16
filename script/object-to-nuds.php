<?php 
/************************
 AUTHOR: Ethan Gruber
 MODIFIED: January, 2018
 DESCRIPTION: Processes the data object/associative array for a coin into NUDS/XML
 ************************/

//generate NUDS/XML from the $record data object
function generate_nuds($record, $fileName){
	GLOBAL $coinTypes;
	
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
	$writer->writeAttribute('xmlns:tei', "http://www.tei-c.org/ns/1.0");
	$writer->writeAttribute('xmlns:xsi', "http://www.w3.org/2001/XMLSchema-instance");
	$writer->writeAttribute('xsi:schemaLocation', 'http://nomisma.org/nuds http://nomisma.org/nuds.xsd');
	$writer->writeAttribute('recordType', "physical");
	
	//start control
	$writer->startElement('control');
		$writer->writeElement('recordId', $record['accnum']);
		$writer->writeElement('publicationStatus', 'approved');		
		$writer->writeElement('maintenanceStatus', 'derived');
		$writer->startElement('maintenanceAgency');
			$writer->writeElement('agencyName', 'American Numismatic Society');
		$writer->endElement();
		
		//maintenanceHistory
		$writer->startElement('maintenanceHistory');
			$writer->startElement('maintenanceEvent');
				$writer->writeElement('eventType', 'derived');
				$writer->startElement('eventDateTime');
					$writer->writeAttribute('standardDateTime', date(DATE_W3C));
					$writer->text(date("D, d M Y", time()));
				$writer->endElement();
				$writer->writeElement('agentType', 'machine');
				$writer->writeElement('agent', 'PHP');
				$writer->writeElement('eventDescription', 'Exported from Filemaker');
			$writer->endElement();
		$writer->endElement();
		
		//rightsStmt
		$writer->startElement('rightsStmt');
			$writer->writeElement('copyrightHolder', 'American Numismatic Society');
			
			//data and image licenses
			$writer->startElement('license');
				$writer->writeAttribute('for', 'data');
				$writer->writeAttribute('xlink:type', 'simple');
				$writer->writeAttribute('xlink:href', 'http://opendatacommons.org/licenses/odbl/');
				$writer->text('Metadata are openly licensed with a Open Data Commons Open Database License (ODbL)');
			$writer->endElement();			
			
			$writer->startElement('license');
				$writer->writeAttribute('for', 'images');
				$writer->writeAttribute('xlink:type', 'simple');
				$writer->writeAttribute('xlink:href', $record['license']);
				if ($record['license'] == 'https://creativecommons.org/choose/mark/'){
					$writer->text('Public Domain Mark');
				} else {
					$writer->text('Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)');
				}
				
			$writer->endElement();
			
			//rights statement about physical object
			$writer->startElement('rights');
				$writer->writeAttribute('xlink:type', 'simple');
				$writer->writeAttribute('xlink:href', $record['rights']);
				if ($record['rights'] == 'http://rightsstatements.org/vocab/NoC-US/1.0/'){
					$writer->text('No Copyright - United States');
				} else {
					$writer->text('Copyright Undetermined');
				}
			$writer->endElement();
			
			//rights statement
		$writer->endElement();
		
		//semanticDeclaration
		$writer->startElement('semanticDeclaration');
			$writer->writeElement('prefix', 'nmo');
			$writer->writeElement('namespace', 'http://nomisma.org/ontology#');
		$writer->endElement();
	$writer->endElement();
	//end control
	
	//begin descMeta
	$writer->startElement('descMeta');	
		//title
		$writer->startElement('title');
			$writer->writeAttribute('xml:lang', 'en');
			$writer->text($record['title']);
		$writer->endElement();
		
		/***** NOTES *****/
		if (array_key_exists('notes', $record)){
			$writer->startElement('noteSet');
				foreach ($record['notes'] as $note){
					$writer->writeElement('note', $note);
				}
			$writer->endElement();
		}
		
		/***** SUBJECTS *****/
		if (array_key_exists('subjects', $record)){
			$writer->startElement('subjectSet');
			foreach ($record['subjects'] as $subject){
				generate_entity_element($writer, $subject, null);
			}
			$writer->endElement();
		}
		
		/***** TYPEDESC *****/
		//assign the typeDesc URI
		//evaluate cointypes. Use stored XML object for OCRE or point to a URI for any other URI except when SCO and PELLA co-exist
		if (array_key_exists('types', $record)){
			if (count($record['types']) == 1){
				if (array_key_exists('OCRE', $record['types'])){
					$uri = $record['types']['OCRE']['uri'];
					$uncertain = $record['types']['OCRE']['uncertain'];
					
					//process XML object
					generate_typeDesc_from_OCRE($writer, $record['typeDesc'], $coinTypes[$uri]['object'], $uncertain);
				} else {
					//assign the typeDesc URI
					foreach ($record['types'] as $type){
						$writer->startElement('typeDesc');
							$writer->writeAttribute('xlink:type', 'simple');
							$writer->writeAttribute('xlink:href', $type['uri']);
						$writer->endElement();
					}
				}
			} else {
				//if there are two or more URIs, then (at the moment), they are PELLA/SCO/PCO: favor SCO, PCO > PELLA.
				//also create a typeDesc if there is an OCRE URI along with RPC Online
				if (array_key_exists('OCRE', $record['types'])){
					$uri = $record['types']['OCRE']['uri'];
					$uncertain = $record['types']['OCRE']['uncertain'];
					
					//process XML object
					generate_typeDesc_from_OCRE($writer, $record['typeDesc'], $coinTypes[$uri]['object'], $uncertain);
				} elseif (array_key_exists('SCO', $record['types'])){
					$writer->startElement('typeDesc');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:href', $record['types']['SCO']['uri']);
					$writer->endElement();
				} elseif (array_key_exists('PCO', $record['types'])){
					$writer->startElement('typeDesc');
						$writer->writeAttribute('xlink:type', 'simple');
						$writer->writeAttribute('xlink:href', $record['types']['PCO']['uri']);
					$writer->endElement();
				}
			}
		} else {
			//process the typeDesc associative array into NUDS
			if (array_key_exists('typeDesc', $record)){
				generate_typeDesc_from_object($writer, $record['typeDesc']);
			}
		}
		/***** END TYPEDESC *****/
		
		/***** PHYSICAL DESCRIPTION *****/
		$writer->startElement('physDesc');
			if (array_key_exists('authenticity', $record)){
				foreach ($record['authenticity'] as $entity){
					generate_entity_element($writer, $entity, 'authenticity');
				}
			}
			if (array_key_exists('axis', $record)){
				$writer->writeElement('axis', $record['axis']);
			}
			if (array_key_exists('color', $record)){
				foreach($record['color'] as $color){
					$writer->writeElement('color', $color);
				}
			}
			if (array_key_exists('wear', $record) || array_key_exists('secondaryTreatment', $record)){
				$writer->startElement('conservationState');
					if (array_key_exists('wear', $record)){
						$writer->writeElement('wear', $record['wear']);
					}
					if (array_key_exists('secondaryTreatment', $record)){
						foreach ($record['secondaryTreatment'] as $entity){
							generate_entity_element($writer, $entity, 'secondaryTreatment');
						}
					}
				$writer->endElement();
			}
			if (array_key_exists('countermark', $record)){
				$writer->startElement('countermark');
					$writer->writeElement('symbol', $record['countermark']);
				$writer->endElement();
			}			
			if (array_key_exists('measurements', $record)){
				$writer->startElement('measurementsSet');
					foreach($record['measurements'] as $k=>$v){
						$writer->startElement($k);
							if ($k == 'weight') {
								$writer->writeAttribute('units', 'g');
							} else {
								$writer->writeAttribute('units', 'mm');
							}
							$writer->text($v);
						$writer->endElement();
					}
				$writer->endElement();
			}
			if (array_key_exists('sernum', $record)){
				$writer->writeElement('serialNumber', $record['sernum']);
			}			
			if (array_key_exists('shape', $record)){
				$writer->writeElement('shape', $record['shape']);
			}
			if (array_key_exists('watermark', $record)){
				$writer->startElement('watermark');
					$writer->writeElement('symbol', $record['watermark']);
				$writer->endElement();
			}
		$writer->endElement();
		
		/***** UNDERTYPE DESCRIPTION *****/
		if (array_key_exists('undertype', $record)){
			$writer->startElement('undertypeDesc');
				$writer->startElement('description');
					$writer->writeAttribute('xml:lang', 'en');
					$writer->text($record['undertype']);
				$writer->endElement();
			$writer->endElement();
		}
		
		/***** FINDSPOT DESCRIPTION *****/
		if (array_key_exists('hoard', $record) || array_key_exists('findspot', $record)){
			$writer->startElement('findspotDesc');
				if (array_key_exists('hoard', $record)){
					$writer->writeAttribute('xlink:type', 'simple');
					$writer->writeAttribute('xlink:href', $record['hoard']);
				}
				if (array_key_exists('findspot', $record)){
					$writer->startElement('findspot');
						$writer->startElement('geogname');
							$writer->writeAttribute('xlink:type', 'simple');
							$writer->writeAttribute('xlink:role', 'findspot');
							$writer->text($record['findspot']);
						$writer->endElement();
					$writer->endElement();
				}
			$writer->endElement();
		}
		
		/***** BIBLIOGRAPHIC DESCRIPTION *****/
		//create refDesc if there are refs, citations, an OCRE coin type, or both SCO and PELLA types
		if (array_key_exists('refs', $record) || array_key_exists('citations', $record) || array_key_exists('types', $record)){
			$writer->startElement('refDesc');
				//always insert a reference to a coin type URI
				if (array_key_exists('types', $record)){
				    foreach ($record['types'] as $type){
				        //create a reference[@xlink:arcole='nmo:hasTypeSeriesItem'] for any URI that isn't PELLA (used in typeDesc/@xlink:href)
				    	$type['arcrole'] = 'nmo:hasTypeSeriesItem';
				    	generate_entity_element($writer, $type, 'reference');
				    }					
				}
				
				//process other textual references and citations
				if (array_key_exists('refs', $record)){
					foreach ($record['refs'] as $ref){
						//generate_entity_element($writer, $entity, 'reference');
						
						//attempt to parse the ref into TEI elements
						if (strpos($ref['label'], '.') !== FALSE){
							$pieces = explode('.', $ref['label']);
							
							$writer->startElement('reference');
								if ($ref['uncertain'] == true){
									$writer->writeAttribute('certainty', 'uncertain');
								}
								$writer->writeElement('tei:title', $pieces[0]);
								
								//remove first index from array
								array_shift($pieces);
								$writer->writeElement('tei:idno', implode('.', $pieces));
							$writer->endElement();
						} else {
							generate_entity_element($writer, $ref, 'reference');
						}
					}
				}
				if (array_key_exists('citations', $record)){
					foreach ($record['citations'] as $entity){
						generate_entity_element($writer, $entity, 'citation');
					}
				}				
			$writer->endElement();
		}
		
		/***** ADMINSTRATIVE DESCRIPTION *****/
		$writer->startElement('adminDesc');
			$writer->writeElement('identifier', $record['accnum']);
			$writer->writeElement('department', $record['department']);
			$writer->startElement('collection');
				$writer->writeAttribute('xlink:type', 'simple');
				$writer->writeAttribute('xlink:href', 'http://nomisma.org/id/ans');
				$writer->text('American Numismatic Society');
			$writer->endElement();
			if (array_key_exists('imageSponsor', $record)){
				$writer->startElement('acknowledgment');
					$writer->writeAttribute('localType', 'imageSponsor');
					$writer->text($record['imageSponsor']);
				$writer->endElement();
			}			
			//provenance
			if (array_key_exists('provenance', $record)){
				$writer->startElement('provenance');
					$writer->startElement('chronList');
						foreach($record['provenance'] as $k=>$item){
							$writer->startElement('chronItem');
								if ($k == 'acquiredFrom'){
									$writer->writeElement('acquiredFrom', $item);
								} else {
									$writer->writeElement('previousColl', $item);
								}
							$writer->endElement();
						}
					$writer->endElement();
				$writer->endElement();
			}
		$writer->endElement();
		
		//end descMeta
		$writer->endElement();
		
		/***** IMAGES AVAILABLE *****/
		if ($record['imageavailable'] == true){
			$accnum = $record['accnum'];
			$accession_array = explode('.', $accnum);
			$collection_year = $accession_array[0];
			
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
						//archive
						$writer->startElement('mets:file');
    						$writer->writeAttribute('USE', 'archive');
        						$writer->writeAttribute('MIMETYPE', 'image/jpeg');
        						$writer->startElement('mets:FLocat');
        						  $writer->writeAttribute('LOCYPE', 'URL');
        						  $writer->writeAttribute('xlink:href', "http://numismatics.org/collectionimages/{$image_path}/{$collection_year}/{$accnum}.obv.noscale.jpg");
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
						//archive
						$writer->startElement('mets:file');
    						$writer->writeAttribute('USE', 'archive');
        						$writer->writeAttribute('MIMETYPE', 'image/jpeg');
        						$writer->startElement('mets:FLocat');
        						  $writer->writeAttribute('LOCYPE', 'URL');
        						  $writer->writeAttribute('xlink:href', "http://numismatics.org/collectionimages/{$image_path}/{$collection_year}/{$accnum}.rev.noscale.jpg");
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

//generate the typeDesc element from the associative array stored in the $record object
function generate_typeDesc_from_object ($writer, $typeDesc){
	$writer->startElement('typeDesc');
	//construct typeDesc elements in order according the the NUDS XSD
	if (array_key_exists('objectType', $typeDesc)){
		generate_entity_element($writer, $typeDesc['objectType'], 'objectType');
	}
	//date
	if (array_key_exists('fromDate', $typeDesc) && array_key_exists('toDate', $typeDesc)){
		get_date($writer, $typeDesc['fromDate'], $typeDesc['toDate']);
	}
	
	//dateOnObject now in typeDesc. Include AH when possible
	if (array_key_exists('ah_date', $typeDesc)){
	    $writer->startElement('dateOnObject');
	       $writer->writeAttribute('calendar', 'ah');
	       $writer->startElement('date');
    	       if (ctype_digit($typeDesc['ah_date'])) {
    	           $writer->writeAttribute('standardDate', $typeDesc['ah_date']);
    	       }
    	       $writer->text($typeDesc['ah_date']);
	       $writer->endElement();
	    $writer->endElement();
	} elseif (array_key_exists('dob', $typeDesc)){
	    $writer->startElement('dateOnObject');
	       $writer->startElement('date');
    	       if (ctype_digit($typeDesc['dob'])) {
    	           $writer->writeAttribute('standardDate', $typeDesc['dob']);
    	       }
	           $writer->text($typeDesc['dob']);
	       $writer->endElement();
	    $writer->endElement();
	}
	
	if (array_key_exists('denomination', $typeDesc)){
		foreach ($typeDesc['denomination'] as $entity){
			generate_entity_element($writer, $entity, 'denomination');
		}
	}
	if (array_key_exists('manufacture', $typeDesc)){
		foreach ($typeDesc['manufacture'] as $entity){
			generate_entity_element($writer, $entity, 'manufacture');
		}
	}
	if (array_key_exists('material', $typeDesc)){
		foreach ($typeDesc['material'] as $entity){
			generate_entity_element($writer, $entity, 'material');
		}
	}
	
	//authority
	if (array_key_exists('authority', $typeDesc)){
		$writer->startElement('authority');
		foreach ($typeDesc['authority'] as $entity){
			generate_entity_element($writer, $entity, null);
		}
		$writer->endElement();
	}
	
	//geographic
	if (array_key_exists('geographic', $typeDesc)){
		$writer->startElement('geographic');
		foreach ($typeDesc['geographic'] as $role=>$places){
			foreach ($places as $entity){
				$entity['role'] = $role;
				generate_entity_element($writer, $entity, 'geogname');
			}
		}
		$writer->endElement();
	}
	
	//side descriptions
	if (array_key_exists('obverse', $typeDesc)){
		generate_side($writer, $typeDesc['obverse'], 'obverse');
	}
	if (array_key_exists('reverse', $typeDesc)){
		generate_side($writer, $typeDesc['reverse'], 'reverse');
	}
	if (array_key_exists('edge', $typeDesc)){
		$writer->startElement('edge');
			$writer->startElement('description');
				$writer->writeAttribute('xml:lang', 'en');
				$writer->text($typeDesc['edge']);
			$writer->endElement();
		$writer->endElement();
	}
	$writer->endElement();
}

//this function processes the DOMDocument Object stored in an array to minimize HTTP lookups for batch processing of OCRE links
function generate_typeDesc_from_OCRE($writer, $typeDesc, $fields, $uncertain){
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
			
			if (array_key_exists('legend', $typeDesc[$nodeName])){
				$writer->startElement('legend');
					$writer->writeAttribute('scriptCode', 'Latn');
					$writer->text($typeDesc[$nodeName]['legend']);
				$writer->endElement();
				
			}
			if (array_key_exists('type', $typeDesc[$nodeName])){
				$writer->startElement('type');
					$writer->startElement('description');
						$writer->writeAttribute('xml:lang', 'en');
						$writer->text($typeDesc[$nodeName]['type']);
					$writer->endElement();
				$writer->endElement();
			}
			if (array_key_exists('symbol', $typeDesc[$nodeName])){
				$writer->startElement('symbol');
					$writer->text($typeDesc[$nodeName]['symbol']);
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

//create nuds:date or nuds:dateRange based on start and end dates
function get_date($writer, $fromDate, $toDate){
	if ($fromDate == $toDate){
		$writer->startElement('date');
			$writer->writeAttribute('standardDate', number_pad($toDate, 4));
			$writer->text(get_date_textual($toDate));
		$writer->endElement();
	} elseif ($fromDate != 0 && $toDate != 0){
		$writer->startElement('dateRange');
			$writer->startElement('fromDate');
				$writer->writeAttribute('standardDate', number_pad($fromDate, 4));
				$writer->text(get_date_textual($fromDate));
			$writer->endElement();
			$writer->startElement('toDate');
				$writer->writeAttribute('standardDate', number_pad($toDate, 4));
				$writer->text(get_date_textual($toDate));
			$writer->endElement();
		$writer->endElement();
	}
}

function generate_side ($writer, $side, $element){
	$writer->startElement($element);
		if (array_key_exists('legend', $side)){
			$writer->writeElement('legend', $side['legend']);
		}
		if (array_key_exists('type', $side)){
			$writer->startElement('type');
				$writer->startElement('description');
					$writer->writeAttribute('xml:lang', 'en');
					$writer->text($side['type']);
				$writer->endElement();
			$writer->endElement();
		}
		if (array_key_exists('symbol', $side)){
			$writer->writeElement('symbol', $side['symbol']);
		}
		//insert other entities
		if (array_key_exists('entities', $side)){
			foreach ($side['entities'] as $entity){
				generate_entity_element($writer, $entity, null);
			}
		}	
	$writer->endElement();
}

//function for rendering an entity object into a NUDS element, based on various conditions
function generate_entity_element ($writer, $array, $element){
	if (array_key_exists('element', $array)){
		$element = $array['element'];
	}
	
	$writer->startElement($element);
	//conditionals for other attributes
	if (array_key_exists('uri', $array)){
		$writer->writeAttribute('xlink:href', $array['uri']);
	}
	if (array_key_exists('role', $array)){
		$writer->writeAttribute('xlink:role', $array['role']);
	}
	if (array_key_exists('arcrole', $array)){
		$writer->writeAttribute('xlink:arcrole', $array['arcrole']);
	}
	if (array_key_exists('uri', $array) || array_key_exists('role', $array)){
		$writer->writeAttribute('xlink:type', 'simple');
	}
	if(array_key_exists('localType', $array)){
		$writer->writeAttribute('localType', $array['localType']);
	}
	if (array_key_exists('uncertain', $array)){
		if ($array['uncertain'] == true){
			$writer->writeAttribute('certainty', 'uncertain');
		}
	}
	if (array_key_exists('certainty', $array)){
		$writer->writeAttribute('certainty', $array['certainty']);
	}
	//human readable label
	$writer->text($array['label']);
	$writer->endElement();
}

?>