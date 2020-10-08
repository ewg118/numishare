<?php 

/************************
 AUTHOR: Ethan Gruber
 MODIFIED: June, 2020
 DESCRIPTION: Functions for processing the row from the Filemaker export CSV into a data object for later 
 processing into NUDS/XML
 ************************/

/****** PROCESS CSV INTO DATA OBJECT ******/
function parse_row($row, $count, $fileName){
	GLOBAL $warnings;
	GLOBAL $coinTypes;
	GLOBAL $hoards;
	GLOBAL $sco;
	
	$record = array();
	
	//generate collection year for images
	$accnum = trim($row['accnum']);
	$record['accnum'] = $accnum;
	$accession_array = explode('.', $accnum);
	$collection_year = $accession_array[0];
	
	//department
	$department = get_department($row['department']);
	$record['department'] = $department;
	
	//references; used to check for 'ric.' for pointing typeDesc to OCRE
	$refs = array_filter(explode('|', $row['refs']));
	
	/************ BEGIN TYPEDESC ***************/
	//first evaluate all of the refs and perform coin type URI lookups
	foreach ($refs as $ref){
		$id = substr(trim($ref), -1) == '?' ? str_replace('?', '', trim($ref)) : trim($ref);
		$uncertain = substr(trim($ref), -1) == '?' ? true : false;
		
		if (preg_match('/^https?:\/\//', $ref)){
		    //first, look for URIs (currently for Tokens of the Roman Empire)
		    $uri = $id;
		    $pieces = explode('/', $uri);
		    $domain = $pieces[2];
		    
		    //get info from $coinTypes array if the coin type has been verified already
		    
		    //ignore volume 1 for RPC Online (URIs not active yet, as of Sept. 2019)
		    if ($domain == 'rpc.ashmus.ox.ac.uk' && $pieces[4] == '1'){
		    	echo "Ignored {$uri}\n";
		    } elseif (array_key_exists($uri, $coinTypes)){
		        echo "Matched {$uri}\n";
		        $coinType= array('label'=>$coinTypes[$uri]['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
		        $record['types'][$domain] = $coinType;
		        $record['title'] = $coinTypes[$uri]['title'] . '. ' . $accnum;
		    } else {
		        $file_headers = @get_headers($uri);
		        if ($file_headers[0] == 'HTTP/1.1 200 OK'){
		            echo "Found {$uri}\n";
		            //generate the title from the NUDS
		            $titles = generate_title_from_type($uri);
		            $coinTypes[$uri] = array('title'=>$titles['title'], 'reference'=>$titles['reference']);
		            
		            $record['title'] = $titles['title'] . ' ' . $accnum;
		            $coinType= array('label'=>$titles['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
		            $record['types'][$domain] = $coinType;
		        } else {
		            $record['refs'][] = array('label'=>$id, 'uncertain'=>$uncertain);
		        }
		    }
		} elseif (preg_match('/pella\.philip_ii\.\d+[A-Z]?$/', $ref) || preg_match('/lerider\.philip_ii\./', $ref) || preg_match('/LeRider\.\d\./', $ref)){
		   //LeRider or PELLA numbers		   
		    
		    if (strpos($id, 'LeRider') !== FALSE){
		        //if the ID matches the 'LeRider' string, then replace it with the proper ID
		        $id = str_replace('LeRider', 'lerider.philip_ii', $id);
		    }
		    
		    $uri = 'http://numismatics.org/pella/id/' . $id;
		    
		    //get info from $coinTypes array if the coin type has been verified already
		    if (array_key_exists($uri, $coinTypes)){
		        echo "Matched {$uri}\n";
		        $coinType= array('label'=>$coinTypes[$uri]['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
		        $record['types']['PELLA'] = $coinType;
		        $record['title'] = $coinTypes[$uri]['title'] . '. ' . $accnum;
		    } else {
		        $file_headers = @get_headers($uri);		        
		        if ($file_headers[0] == 'HTTP/1.1 200 OK'){
		            echo "Found {$uri}\n";
		            //generate the title from the NUDS
		            $titles = generate_title_from_type($uri);
		            $coinTypes[$uri] = array('title'=>$titles['title'], 'reference'=>$titles['reference']);
		            
		            $record['title'] = $titles['title'] . ' ' . $accnum;
		            $coinType = array('label'=>$titles['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
		            $record['types']['PELLA'] = $coinType;
		        } elseif ($file_headers[0] == 'HTTP/1.1 303 See Other'){
		            //redirect Svoronos references to CPE URIs
		            $cointype = str_replace('Location: ', '', $file_headers[7]);
		            echo "Matching: {$uri} -> {$cointype}\n";
		            
		            //make Le Rider URI the new $uri variable
		            $uri = $cointype;
		            
		            //generate the title from the NUDS
		            $titles = generate_title_from_type($uri);
		            $coinTypes[$uri] = array('title'=>$titles['title'], 'reference'=>$titles['reference']);
		            
		            $record['title'] = $titles['title'] . ' ' . $accnum;
		            $coinType= array('label'=>$titles['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
		            $record['types']['PELLA'] = $coinType;
		        } else {
		            $record['refs'][] = array('label'=>$id, 'uncertain'=>$uncertain);
		        }
		    }
		} elseif (preg_match('/ric\.[1-9]/', $ref)){
		    //match OCRE		    
			//only continue process if the reference is not variant
			if (strpos(strtolower($row['info']), 'variant') === FALSE){
				//if the $id is from RIC 9, capitalize final letter
				if (strpos($id, 'ric.9') !== FALSE){
					$pieces = explode('.', $id);
					$pieces[3] = strtoupper($pieces[3]);
					
					//reassemble $id
					$id = implode('.', $pieces);
					$uri = 'http://numismatics.org/ocre/id/' . $id;
				} else {
					$uri = 'http://numismatics.org/ocre/id/' . $id;
				}
				
				//reduce lookups
				if (array_key_exists($uri, $coinTypes)){
					echo "Matched {$uri}\n";
					
					$coinType = array('label'=>$coinTypes[$uri]['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
					$record['types']['OCRE'] = $coinType;
					$record['title'] = $coinTypes[$uri]['title'] . '. ' . $accnum;
					
					//insert legend and type description from FileMaker
					if (strlen($row['obverselegend']) > 0 || strlen($row['obversesymbol']) > 0 || strlen($row['obversetype']) > 0){
						$obverse = array();
						
						//obverselegend
						if (strlen($row['obverselegend']) > 0){
							$obverse['legend'] = trim($row['obverselegend']);
						}
						//obversesymbol
						if (strlen($row['obversesymbol']) > 0){
							$obverse['symbol'] = trim($row['obversesymbol']);
						}
						//obversetype
						if (strlen($row['obversetype']) > 0){
							$obverse['type'] = trim($row['obversetype']);
						}
						$record['typeDesc']['obverse'] = $obverse;
						
					}
					if (strlen($row['reverselegend']) > 0 || strlen($row['reversesymbol']) > 0 || strlen($row['reversetype']) > 0){
						$reverse = array();
						
						//reverselegend
						if (strlen($row['reverselegend']) > 0){
							$reverse['legend'] = trim($row['reverselegend']);
						}
						//reversesymbol
						if (strlen($row['reversesymbol']) > 0){
							$reverse['symbol'] = trim($row['reversesymbol']);
						}
						//reversetype
						if (strlen($row['reversetype']) > 0){
							$reverse['type'] = trim($row['reversetype']);
						}
						$record['typeDesc']['reverse'] = $reverse;
						
					}
				} else {
					$file_headers = @get_headers($uri);
					if ($file_headers[0] == 'HTTP/1.1 200 OK'){
						echo "Found {$uri}\n";
						//generate the title from the NUDS
						$titles = generate_title_from_type($uri);
						$coinTypes[$uri] = array('title'=>$titles['title'], 'reference'=>$titles['reference'], 'object'=>$titles['object']);
						
						$record['title'] = $titles['title'] . ' ' . $accnum;
						$coinType = array('label'=>$titles['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
						$record['types']['OCRE'] = $coinType;
						
						//insert legend and type description from FileMaker
						if (strlen($row['obverselegend']) > 0 || strlen($row['obversesymbol']) > 0 || strlen($row['obversetype']) > 0){
							$obverse = array();
							
							//obverselegend
							if (strlen($row['obverselegend']) > 0){
								$obverse['legend'] = trim($row['obverselegend']);
							}
							//obversesymbol
							if (strlen($row['obversesymbol']) > 0){
								$obverse['symbol'] = trim($row['obversesymbol']);
							}
							//obversetype
							if (strlen($row['obversetype']) > 0){
								$obverse['type'] = trim($row['obversetype']);
							}
							$record['typeDesc']['obverse'] = $obverse;
							
						}
						if (strlen($row['reverselegend']) > 0 || strlen($row['reversesymbol']) > 0 || strlen($row['reversetype']) > 0){
							$reverse = array();
							
							//reverselegend
							if (strlen($row['reverselegend']) > 0){
								$reverse['legend'] = trim($row['reverselegend']);
							}
							//reversesymbol
							if (strlen($row['reversesymbol']) > 0){
								$reverse['symbol'] = trim($row['reversesymbol']);
							}
							//reversetype
							if (strlen($row['reversetype']) > 0){
								$reverse['type'] = trim($row['reversetype']);
							}
							$record['typeDesc']['reverse'] = $reverse;
							
						}
					} else {
						$record['refs'][] = array('label'=>$id, 'uncertain'=>$uncertain);
						
					}
				}
			} else {
				//otherwise simply generate typeDesc for variants
				$record['refs'][] = array('label'=>$id, 'uncertain'=>$uncertain);
			}
		} elseif ($department=='Roman' && preg_match('/C\.[1-9]/', $ref)){
		    //handle Roman Republican			
		    if (strpos(trim($ref), 'var') === FALSE){
		        $uri = 'http://numismatics.org/crro/id/' . str_replace('C.', 'rrc-', $id);
		        
		        //get info from $coinTypes array if the coin type has been verified already
		        if (array_key_exists($uri, $coinTypes)){
		            echo "Matched {$uri}\n";
		            $coinType= array('label'=>$coinTypes[$uri]['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
		            $record['types']['CRRO'] = $coinType;
		            $record['title'] = $coinTypes[$uri]['title'] . '. ' . $accnum;
		        } else {
		            $file_headers = @get_headers($uri);
		            if ($file_headers[0] == 'HTTP/1.1 200 OK'){
		                echo "Found {$uri}\n";
		                //generate the title from the NUDS
		                $titles = generate_title_from_type($uri);
		                $coinTypes[$uri] = array('title'=>$titles['title'], 'reference'=>$titles['reference']);
		                
		                $record['title'] = $titles['title'] . ' ' . $accnum;
		                $coinType= array('label'=>$titles['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
		                $record['types']['CRRO'] = $coinType;
		            } else {
		                $record['refs'][] = array('label'=>$id, 'uncertain'=>$uncertain);
		            }
		        }
		    } else {
		        $record['refs'][] = array('label'=>$id, 'uncertain'=>$uncertain);
		    }
		} elseif ($department=='Greek' && preg_match('/Price\.[L|P]?\d+[A-Z]?$/', $ref)){
			//handle Price references for Pella
			$uri = 'http://numismatics.org/pella/id/' . str_replace('Price.', 'price.', $id);
			
			//get info from $coinTypes array if the coin type has been verified already
			if (array_key_exists($uri, $coinTypes)){
				echo "Matched {$uri}\n";
				$coinType= array('label'=>$coinTypes[$uri]['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
				$record['types']['PELLA'] = $coinType;
				$record['title'] = $coinTypes[$uri]['title'] . '. ' . $accnum;
			} else {
				$file_headers = @get_headers($uri);
				if ($file_headers[0] == 'HTTP/1.1 200 OK'){
					echo "Found {$uri}\n";
					//generate the title from the NUDS
					$titles = generate_title_from_type($uri);
					$coinTypes[$uri] = array('title'=>$titles['title'], 'reference'=>$titles['reference']);
					
					$record['title'] = $titles['title'] . ' ' . $accnum;
					$coinType = array('label'=>$titles['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
					$record['types']['PELLA'] = $coinType;
				} else {
					$record['refs'][] = array('label'=>$id, 'uncertain'=>$uncertain);
				}
			}
		} elseif ($department=='Greek' && preg_match('/^newell\.demetrius\.\d+$/', $ref)){
		    $uri = 'http://numismatics.org/agco/id/' . $id;
		    //get info from $coinTypes array if the coin type has been verified already
		    if (array_key_exists($uri, $coinTypes)){
		        echo "Matched {$uri}\n";
		        $coinType= array('label'=>$coinTypes[$uri]['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
		        $record['types']['AGCO'] = $coinType;
		        $record['title'] = $coinTypes[$uri]['title'] . '. ' . $accnum;
		    } else {
		        $file_headers = @get_headers($uri);
		        if ($file_headers[0] == 'HTTP/1.1 200 OK'){
		            echo "Found {$uri}\n";
		            //generate the title from the NUDS
		            $titles = generate_title_from_type($uri);
		            $coinTypes[$uri] = array('title'=>$titles['title'], 'reference'=>$titles['reference']);
		            
		            $record['title'] = $titles['title'] . ' ' . $accnum;
		            $coinType= array('label'=>$titles['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
		            $record['types']['AGCO'] = $coinType;
		        } else {
		            $record['refs'][] = array('label'=>$id, 'uncertain'=>$uncertain);
		        }
		    }
		} elseif ($department=='Greek' && preg_match('/SC\./', $ref)){			
		    $uri = 'http://numismatics.org/sco/id/' . str_replace('SC.', 'sc.1.', $id);
			
		    //get info from $coinTypes array if the coin type has been verified already
		    if (array_key_exists($uri, $coinTypes)){
		        echo "Matched {$uri}\n";
		        $coinType= array('label'=>$coinTypes[$uri]['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
		        $record['types']['SCO'] = $coinType;
		        $record['title'] = $coinTypes[$uri]['title'] . '. ' . $accnum;
		    } else {
		        $file_headers = @get_headers($uri);
		        if ($file_headers[0] == 'HTTP/1.1 200 OK'){
		            echo "Found {$uri}\n";
		            //generate the title from the NUDS
		            $titles = generate_title_from_type($uri);
		            $coinTypes[$uri] = array('title'=>$titles['title'], 'reference'=>$titles['reference']);
		            
		            $record['title'] = $titles['title'] . ' ' . $accnum;
		            $coinType= array('label'=>$titles['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
		            $record['types']['SCO'] = $coinType;
		        } else {
		            $record['refs'][] = array('label'=>$id, 'uncertain'=>$uncertain);
		        }
		    }
		} elseif ($department == 'Greek' && preg_match('/^Sv[\s|\.](\d+[A-Za-z]?)$/', $ref, $matches)){
		    if (isset($matches[1])){
		        $uri = 'http://numismatics.org/pco/id/svoronos-1904.' . $matches[1];
		        
		        //get info from $coinTypes array if the coin type has been verified already
		        if (array_key_exists($uri, $coinTypes)){
		            echo "Matched {$uri}\n";
		            $coinType= array('label'=>$coinTypes[$uri]['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
		            $record['types']['PCO'] = $coinType;
		            $record['title'] = $coinTypes[$uri]['title'] . '. ' . $accnum;
		        } else {
		            $file_headers = @get_headers($uri);
		            if ($file_headers[0] == 'HTTP/1.1 303 See Other'){
		                //redirect Svoronos references to CPE URIs
		                $cointype = str_replace('Location: ', '', $file_headers[7]);
		                echo "Matching: {$uri} -> {$cointype}\n";
		                
		                //make CPE URI the new $uri variable
		                $uri = $cointype;
		                
		                //generate the title from the NUDS
		                $titles = generate_title_from_type($uri);
		                $coinTypes[$uri] = array('title'=>$titles['title'], 'reference'=>$titles['reference']);
		                
		                $record['title'] = $titles['title'] . ' ' . $accnum;
		                $coinType= array('label'=>$titles['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
		                $record['types']['PCO'] = $coinType;		                
		            } else {
		                $record['refs'][] = array('label'=>$id, 'uncertain'=>$uncertain);
		            }
		        }
		    } else {
		        $record['refs'][] = array('label'=>$id, 'uncertain'=>$uncertain);
		    }
		} elseif ($department == 'Greek' && preg_match('/^(cpe\..*)$/', $ref, $matches)){
		    if (isset($matches[1])){
		        $uri = 'http://numismatics.org/pco/id/' . $matches[1];
		        
		        //get info from $coinTypes array if the coin type has been verified already
		        if (array_key_exists($uri, $coinTypes)){
		            echo "Matched {$uri}\n";
		            $coinType= array('label'=>$coinTypes[$uri]['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
		            $record['types']['PCO'] = $coinType;
		            $record['title'] = $coinTypes[$uri]['title'] . '. ' . $accnum;
		        } else {
		            $file_headers = @get_headers($uri);
		            if ($file_headers[0] == 'HTTP/1.1 200 OK'){
		                echo "Found {$uri}\n";
		                //generate the title from the NUDS
		                $titles = generate_title_from_type($uri);
		                $coinTypes[$uri] = array('title'=>$titles['title'], 'reference'=>$titles['reference']);
		                
		                $record['title'] = $titles['title'] . ' ' . $accnum;
		                $coinType= array('label'=>$titles['reference'], 'uri'=>$uri, 'uncertain'=>$uncertain);
		                $record['types']['PCO'] = $coinType;
		            } else {
		                $record['refs'][] = array('label'=>$id, 'uncertain'=>$uncertain);
		            }
		        }
		    } else {
		        $record['refs'][] = array('label'=>$id, 'uncertain'=>$uncertain);
		    }
		} else {
			$record['refs'][] = array('label'=>$id, 'uncertain'=>$uncertain);
		}
	}
	
	//evaluate medals for AOD, which do not include IDs in $refs
	if ($row['privateinfo'] == 'WW I project ready') {
	    $refs = array_filter(explode('|', trim($row['published'])));
	    foreach ($refs as $ref){
	        if (preg_match('/^(\d+\..*)$/', $ref)){
	            $id = $ref;
	            
	            $uri = 'http://numismatics.org/aod/id/' . $id;
	            
	            //get info from $coinTypes array if the coin type has been verified already
	            if (array_key_exists($uri, $coinTypes)){
	                echo "Matched {$uri}\n";
	                $coinType = array('label'=>$coinTypes[$uri]['reference'], 'uri'=>$uri, 'uncertain'=>false);
	                $record['types']['AOD'] = $coinType;
	                $record['title'] = $coinTypes[$uri]['title'] . '. ' . $accnum;
	                
	            } else {
	                $file_headers = @get_headers($uri);
	                if ($file_headers[0] == 'HTTP/1.1 200 OK'){
	                    echo "Found {$uri}\n";
	                    //generate the title from the NUDS
	                    $titles = generate_title_from_type($uri);
	                    $coinTypes[$uri] = array('title'=>$titles['title'], 'reference'=>$titles['reference']);
	                    
	                    $record['title'] = $titles['title'] . ' ' . $accnum;
	                    $coinType = array('label'=>$titles['reference'], 'uri'=>$uri, 'uncertain'=>false);
	                    $record['types']['AOD'] = $coinType;
	                } else {
	                    $record['citations'][] = array('label'=>$id, 'uncertain'=>false);
	                }
	            }
	        } else {
	            $record['citations'][] = array('label'=>$id, 'uncertain'=>false);
	        }
	    }
	}
	
	//if no coin types have been connected, then parse the typological metadata
	if (!array_key_exists('types', $record)){
		$record['typeDesc'] = parse_typology($accnum, $count, $row, $department);
		
		//generate the title by parsing elements from the typeDesc
		$title = generate_title($record['typeDesc'], $department) . '. ' . $accnum;
		$record['title'] = $title;
	}
	
	/***** END TYPESDESC *****/
	
	/***** UNDERTYPE DESCRIPTION *****/
	if (strlen(trim($row['undertype'])) > 0){
		$record['undertype'] = trim($row['undertype']);
	}
	
	/***** PHYSICAL DESCRIPTION *****/
	//axis: only create if it's an integer
	$axis = (int) $row['axis'];
	if (is_int($axis) && $axis <= 12 && $axis >= 0){
		$record['axis'] = $axis;
	} elseif((strlen($axis) > 0 && !is_int($axis)) || $axis > 12){
		$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-integer axis or value exceeding 12.';
	}
	
	//color
	if (strlen($row['color']) > 0){
		$colors = array_filter(explode('|', $row['color']));
		if (count($colors) > 0){
			$record['color'] = array();
			foreach ($colors as $color){
				$record['color'][] = trim($color);
			}
		}
		
	}	

	//sernum
	if (strlen(trim($row['sernum'])) > 0){
		$record['sernum'] = trim($row['sernum']);
	}
	//watermark
	if (strlen(trim($row['watermark'])) > 0){
		$record['watermark'] = trim($row['watermark']);
	}
	//shape
	if (strlen(trim($row['shape'])) > 0){
		$record['shape'] = trim($row['shape']);
	}
	//signature
	if (strlen(trim($row['signature'])) > 0){
		$record['signature'] = trim($row['signature']);
	}
	//counterstamp
	if (strlen(trim($row['counterstamp'])) > 0){
		$record['counterstamp'] = trim($row['counterstamp']);
	}
	
	//parse measurements
	if ((is_numeric(trim($row['weight'])) && trim($row['weight']) > 0) || (is_numeric(trim($row['diameter'])) && trim($row['diameter']) > 0) || (is_numeric(trim($row['height'])) && trim($row['height']) > 0) || (is_numeric(trim($row['width'])) && trim($row['width']) > 0) || (is_numeric(trim($row['depth'])) && trim($row['depth']) > 0)){
		$record['measurements'] = array();
		$measurements = array();
		
		//weight
		$weight = trim($row['weight']);
		if (is_numeric($weight) && $weight > 0){
			$measurements['weight'] = $weight;
		} elseif(!is_numeric($weight) && strlen($weight) > 0){
			$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-numeric weight.';
		}
		//diameter
		$diameter = trim($row['diameter']);
		if (is_numeric($diameter) && $diameter > 0){
			$measurements['diameter'] = $diameter;
		} elseif(!is_numeric($diameter) && strlen($diameter) > 0){
			$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-numeric diameter.';
		}
		//height
		$height = trim($row['height']);
		if (is_numeric($height) && $height > 0){
			$measurements['height'] = $height;
		} elseif(!is_numeric($height) && strlen($height) > 0){
			$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-numeric height.';
		}
		//width
		$width = trim($row['width']);
		if (is_numeric($width) && $width > 0){
			$measurements['width'] = $width;
		} elseif(!is_numeric($width) && strlen($width) > 0){
			$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-numeric width.';
		}
		//depth
		$depth = trim($row['depth']);
		if (is_numeric($depth) && $depth > 0){
			$measurement['thickness'] = $depth;
		} elseif(!is_numeric($depth) && strlen($depth) > 0){
			$warnings[] = 'Line ' . $count . ': ' . $accnum . ' (' . $department . ') has non-numeric depth.';
		}
		//end measurements
		$record['measurements'] = $measurements;
		
	}
	
	if (strlen(trim($row['Authenticity'])) > 0){
		$array = array_filter(explode('|', $row['Authenticity']));
		if (count($array) > 0){
			$record['authenticity'] = array();
			foreach ($array as $val){
				$uncertain = substr($val, -1) == '?' ? true : false;
				$label = str_replace('?', '', trim($val));
				$record['authenticity'][] = array('label'=>$label, 'uncertain'=>$uncertain);
			}
		}
	}
	
	//conservationState
	if (strlen(trim($row['conservation'])) > 0){
		$record['wear'] = trim($row['conservation']);
	}
	
	if (strlen(trim($row['PostManAlt'])) > 0){
		$array = array_filter(explode('|', $row['PostManAlt']));
		if (count($array) > 0){
			$record['secondaryTreatment'] = array();
			foreach ($array as $val){
				$uncertain = substr($val, -1) == '?' ? true : false;
				$label = str_replace('?', '', trim($val));
				$record['secondaryTreatment'][] = array('label'=>$label, 'uncertain'=>$uncertain);
			}
		}
	}
	
	/***** ADMINSTRATIVE DESCRIPTION *****/
	//image sponsor: acknowledgement with localType
	if (strlen(trim($row['imagesponsor'])) > 0){
		$record['imageSponsor'] = trim($row['imagesponsor']);
	}
	
	//custhodhist || strlen(trim($row['donor'])) > 0
	if (strlen(trim($row['prevcoll'])) > 0 || strlen(trim($row['acknowledgment'])) > 0){
		$provenance = array();
		if (strlen(trim($row['acknowledgment'])) > 0){
			$provenance['acquiredFrom'] = trim($row['acknowledgment']);
		}
		
		$prevcolls = array_filter(explode('|', $row['prevcoll']));
		foreach ($prevcolls as $prevcoll){
			if (!is_int($prevcoll) && strlen(trim($prevcoll)) > 0){
				$provenance[] = trim($prevcoll);
			}
		}
		$record['provenance'] = $provenance;
	}
	
	/***** BIBLIOGRAPHIC DESCRIPTION *****/
	//refs are already handled above in the coin type parsing
	
	//ignore WWI objects, which were processed above
	if ($row['privateinfo'] != 'WW I project ready') {
	    $citations = array_filter(explode('|', trim($row['published'])));
	    if (count($citations) > 0){
	        foreach ($citations as $val){
	            $uncertain = substr($val, -1) == '?' ? true : false;
	            $label = str_replace('?', '', trim($val));
	            $record['citations'][] = array('label'=>$label, 'uncertain'=>$uncertain);
	        }
	    }
	}
	
	/***** SUBJECTS *****/
	if (strlen(trim($row['series'])) > 0 || strlen(trim($row['subjevent'])) > 0 || strlen(trim($row['subjissuer'])) > 0 || strlen(trim($row['subjperson'])) > 0 || strlen(trim($row['subjplace'])) > 0 || strlen(trim($row['degree'])) > 0 || strlen(trim($row['era'])) > 0){
		$subjects = array();
		if (strlen(trim($row['series'])) > 0){
			$serieses = array_filter(explode('|', $row['series']));
			foreach ($serieses as $series){
				$subjects[] = array('element'=>'subject', 'label'=>trim($series), 'localType'=>'series');
			}
		}
		if (strlen(trim($row['subjevent'])) > 0){
			$subjEvents = array_filter(explode('|', $row['subjevent']));
			foreach ($subjEvents as $subjEvent){
				$subjects[] = array('element'=>'subject', 'label'=>trim($subjEvent), 'localType'=>'subjectEvent');
			}
		}
		if (strlen(trim($row['subjissuer'])) > 0){
			$subjIssuers = array_filter(explode('|', $row['subjissuer']));
			foreach ($subjIssuers as $subjIssuer){
				$subjects[] = array('element'=>'subject', 'label'=>trim($subjIssuer), 'localType'=>'subjectIssuer');
			}
		}
		if (strlen(trim($row['subjperson'])) > 0){
			$subjPersons = array_filter(explode('|', $row['subjperson']));
			foreach ($subjPersons as $subjPerson){
				$subjects[] = array('element'=>'subject', 'label'=>trim($subjPerson), 'localType'=>'subjectPerson');
			}
		}
		if (strlen(trim($row['subjplace'])) > 0){
			$subjPlaces = array_filter(explode('|', $row['subjplace']));
			foreach ($subjPlaces as $subjPlace){
				$subjects[] = array('element'=>'subject', 'label'=>trim($subjPlace), 'localType'=>'subjectPlace');
			}
		}
		if (strlen(trim($row['era'])) > 0){
			$eras = array_filter(explode('|', $row['era']));
			foreach ($eras as $era){
				$subjects[] = array('element'=>'subject', 'label'=>trim($era), 'localType'=>'era');
			}
		}
		//degree
		if (strlen(trim($row['degree'])) > 0){
			$degrees = array_filter(explode('|', $row['degree']));
			foreach ($degrees as $degree){
				$subjects[] = array('element'=>'subject', 'label'=>trim($degree), 'localType'=>'degree');
			}
		}
		$record['subjects'] = $subjects;
	}
	
	//notes
	if (strlen(trim($row['info'])) > 0){
		$infos = array_filter(explode('|', $row['info']));
		if (count($infos) > 0){
			$notes = array();
			foreach ($infos as $info){
				$notes[] = trim($info);
			}
			$record['notes'] = $notes;
		}
	}
	
	/***** FINDSPOT DESCRIPTION *****/
	if (strpos($row['privateinfo'], 'coinhoards.org') !== FALSE){
		$url = trim($row['privateinfo']);
		
		//see if the hoard URI has already been checked and verified
		if (in_array($url, $hoards)){
			echo "Matched {$url}\n";
			$record['hoard'] = $url;
		} else {
			$file_headers = @get_headers($url);
			if ($file_headers[0] == 'HTTP/1.1 200 OK'){
				echo "Found {$url}\n";
				$record['hoard'] = $url;
				$hoards[] = $url;
			}
		}
	} elseif (strlen(trim($row['findspot'])) > 0){
		$record['findspot'] = trim($row['findspot']);
	}
	
	if (strlen(trim($row['imageavailable'])) > 0){
		$record['imageavailable'] = true;
	} else {
		$record['imageavailable'] = false;
	}
	
	//rights and license
	if (trim($row['startdate']) != '' || trim($row['enddate']) != ''){
	    $year = (int) date("Y") - 96;
	    
		//use the start or end date from filemaker since some coins may be connected to type URIs and lack the typeDesc object
	    $startdate = (is_digit(trim($row['startdate'])) == true ? intval(trim($row['startdate'])) : false);
	    $enddate = (is_digit(trim($row['enddate'])) == true ? intval(trim($row['enddate'])) : false);
	    
	    //if neither start nor end date are valid integers, use default rights and license
	    if ($startdate == false && $enddate == false){
	        $record['license'] = 'https://creativecommons.org/licenses/by-nc/4.0/';
	        $record['rights'] = 'http://rightsstatements.org/page/UND/1.0/';
	    } else {
	        //prefer to evaluate end date over start date
	        if ($enddate != false){
	            if ($enddate <= $year){
	                $record['license'] = 'https://creativecommons.org/choose/mark/';
	                $record['rights'] = 'http://rightsstatements.org/vocab/NoC-US/1.0/';
	            } else {
	                $record['license'] = 'https://creativecommons.org/licenses/by-nc/4.0/';
	                $record['rights'] = 'http://rightsstatements.org/page/UND/1.0/';
	            }
	        } else if ($startdate != false){
	            if ($startdate <= $year){
	                $record['license'] = 'https://creativecommons.org/choose/mark/';
	                $record['rights'] = 'http://rightsstatements.org/vocab/NoC-US/1.0/';
	            } else {
	                $record['license'] = 'https://creativecommons.org/licenses/by-nc/4.0/';
	                $record['rights'] = 'http://rightsstatements.org/page/UND/1.0/';
	            }
	        }
	    }
	} else {
	    //set default rights and licenses when there's no date at all
	    $record['license'] = 'https://creativecommons.org/licenses/by-nc/4.0/';
	    $record['rights'] = 'http://rightsstatements.org/page/UND/1.0/';	      
	}
	
	return $record;
}

//generate title from metadata stored in the typeDesc object
function generate_title($typeDesc, $department){
	$title = '';
	
	if (array_key_exists('material', $typeDesc)){
		$materials = array();
		foreach($typeDesc['material'] as $mat){
			$materials[] = $mat['label'];
		}
		$title .= implode('/', $materials);
	}
	
	if (array_key_exists('denomination', $typeDesc)){
		$materials = array();
		foreach($typeDesc['denomination'] as $mat){
			$denominations[] = $mat['label'];
		}
		$title .= ' ' . implode('/', $denominations);
	} else {
		$title .= ' ' . $typeDesc['objectType']['label'];
	}
	
	//parse authorities, issuers, and states in order.
	if (array_key_exists('authority', $typeDesc)){
		$authorities = array();
		$issuers = array();
		$states = array();
		foreach ($typeDesc['authority'] as $auth){
			if ($auth['role'] == 'authority'){
				$authorities[] = $auth['label'];
			} elseif ($auth['role'] == 'issuer'){
				$issuers[] = $auth['label'];
			} elseif ($auth['role'] == 'state'){
				$states[] = $auth['label'];
			}		
		}		
		if (count($authorities) > 0){
			$title .= ' of ' . implode('/', $authorities);
		} elseif (count($issuers) > 0){
			$title .= ' of ' . implode('/', $issuers);
		} elseif (count($states) > 0){
			$title .= ' of ' . implode('/', $states);
		}			
	}
	
	//geographic parsing
	if (array_key_exists('geographic', $typeDesc)){	    
	    if ($department == 'Medieval' || $department == 'Modern'){
	        if (array_key_exists('locality', $typeDesc['geographic'])){
	            $localities = array();
	            foreach ($typeDesc['geographic']['locality'] as $array){
	                $localities[] = $array['label'];
	            }	            
	            $title .= ", " . implode('/', $localities);
	            if (array_key_exists('mint', $typeDesc['geographic'])){
	                $mints = array();
	                foreach ($typeDesc['geographic']['mint'] as $array){
	                    $mints[] = $array['label'];
	                }
	                
	               $title .= " (" . implode('/', $mints) . ")";   
	            }
	        } elseif (array_key_exists('region', $typeDesc['geographic'])){
	            $regions = array();
	            foreach ($typeDesc['geographic']['region'] as $array){
	                $regions[] = $array['label'];
	            }
	            
	            $title .= ", " . implode('/', $regions);
	        }
	    } else {
	        foreach ($typeDesc['geographic'] as $k=>$array){
	            if ($k == 'mint' || $k == 'region' || $k == 'locality'){
	                $places = array();
	                foreach ($array as $item){
	                    $places[] = $item['label'];
	                }
	                $title .= ', ' . implode('/', $places);
	                break;
	            }
	        }
	    }
	}
	
	//date: prefer the date on object for the title over fromDate/toDate, if available
	if (array_key_exists('title_dob', $typeDesc)){
	    $title .= ', ' . $typeDesc['title_dob'];
	} elseif (array_key_exists('fromDate', $typeDesc) && array_key_exists('toDate', $typeDesc)){
		$title .= ', ';
		$title .= get_title_date($typeDesc['fromDate'], $typeDesc['toDate']);
	}
	
	//return the title
	if (strlen($title) > 0){
		return $title;
	} else {
		return 'Undescribed object';
	}	
}

function parse_typology ($accnum, $count, $row, $department){
	GLOBAL $deities_array;
	GLOBAL $warnings;
	
	$year = (int) date("Y");
	
	//define typeDesc array
	$typeDesc = array();
	
	$geogAuthorities = array();
	$title_elements = array();
	
	//facets
	$denominations = array_filter(explode('|', $row['denomination']));
	$materials = array_filter(explode('|', $row['material']));
	$mints = array_filter(explode('|', $row['mint']));
	$regions = array_filter(explode('|', $row['region']));
	$localities = array_filter(explode('|', $row['locality']));
	$issuers = array_filter(explode('|', $row['issuer']));
	$artists = array_filter(explode('|', $row['artist']));
	$manufactures = array_filter(explode('|', $row['manufacture']));
	$persons = array_filter(explode('|', $row['person']));
	$magistrates = array_filter(explode('|', $row['magistrate']));
	$makers = array_filter(explode('|', $row['maker']));
	$dynasties = array_filter(explode('|', $row['dynasty']));
	
	//define obv., rev., and unspecified artists
	$artists_none = array();
	$artists_obv = array();
	$artists_rev = array();
	foreach ($artists as $artist){
		if (strlen(trim($artist)) > 0){
			if (strpos($artist, '(obv.)') !== false && strpos($artist, '(rev.)') !== false){
				$artists_obv[] = trim(str_replace('(rev.)', '', str_replace('(obv.)', '', str_replace('"', '', $artist))));
				$artists_rev[] = trim(str_replace('(rev.)', '', str_replace('(obv.)', '', str_replace('"', '', $artist))));
			} else if (strpos($artist, '(obv.)') !== false && strpos($artist, '(rev.)') !== true){
				$artists_obv[] = trim(str_replace('(rev.)', '', str_replace('(obv.)', '', str_replace('"', '', $artist))));
			} else if (strpos($artist, '(obv.)') !== true && strpos($artist, '(rev.)') !== false){
				$artists_rev[] = trim(str_replace('(rev.)', '', str_replace('(obv.)', '', str_replace('"', '', $artist))));
			} else if (strpos($artist, '(obv.)') !== true && strpos($artist, '(rev.)') !== true){
				$artists_none[] = str_replace('"', '', $artist);
			}
		}
	}
	
	//object type
	$objectType = normalize_objtype($row['objtype']);
	$typeDesc['objectType'] = $objectType;
	
	//parse integer date on object for certain departments
	if (strlen(trim($row['dob'])) > 0){
	    $num = trim($row['dob']);	    
	    $dob_num = (is_digit($num) == true ? intval($num) : false);
	    
	    //only begin the evaluation of the date on object if it's an integer value	    
        if ($department == 'United States' || $department == 'Modern' || $department == 'Latin American'){
            if ($dob_num == true){
                $typeDesc['title_dob'] = $num;
            }
            
            $typeDesc['dob'] = $num;
        } elseif ($department == 'Islamic' || $department == 'South Asian'){
            //for Islamic coinage, ensure that the era has been set	            
            $era = trim($row['era']);
            
            if ($era == 'H' || strtolower($era) == 'hijra'){
                //add Hijra data into the title DoB
                $typeDesc['title_dob'] = $num . ' H';
                $typeDesc['ah_date'] = $num;
            } else {
                $typeDesc['dob'] = $num;
            }
        } else {
            $typeDesc['dob'] = $num;
        }
    }
	
	//date
	if (strlen(trim($row['startdate'])) > 0){
	    $num = trim($row['startdate']);
	    
	    $startdate = (is_digit($num) == true ? intval($num) : false);
	    
	    //validate dates
	    if ($startdate == false){
	        $warnings[] = "Line {$count}: {$accnum} ({$department}) contains invalid startdate (non-integer: {$startdate}).";
	    } else {
	        if ($startdate == 0 || $startdate > $year){
	            $warnings[] = "Line {$count}: {$accnum} ({$department}) contains invalid startdate (0 or greater than the current year: {$startdate}).";
	        } else {
	            $typeDesc['fromDate'] = $startdate;
	        }
	    }
	}
	
	if (strlen(trim($row['enddate'])) > 0){
	    $num = trim($row['enddate']);
	    
	    $enddate = (is_digit($num) == true ? intval($num) : false);
	    
	    //validate dates
	    if ($enddate == false){
	        $warnings[] = "Line {$count}: {$accnum} ({$department}) contains invalid enddate (non-integer: {$enddate}).";
	    } else {
	        if ($enddate == 0 || $enddate > $year){
	            $warnings[] = "Line {$count}: {$accnum} ({$department}) contains invalid enddate (0 or greater than the current year: {$enddate}).";
	        } elseif (isset($startdate) && (is_int($startdate) && $enddate < $startdate)) {
	            $warnings[] = "Line {$count}: {$accnum} ({$department}) contains invalid enddate (integer value greater than startdate).";
	        } else {
	            $typeDesc['toDate'] = $enddate;
	        }
	    }
	}
	
	//set toDate or fromDate if it doesn't exist, but the latter does
	if (array_key_exists('toDate', $typeDesc) && !array_key_exists('fromDate', $typeDesc)){
	    $typeDesc['fromDate'] = $typeDesc['toDate'];
	}
	if (array_key_exists('fromDate', $typeDesc) && !array_key_exists('toDate', $typeDesc)){
	    $typeDesc['toDate'] = $typeDesc['fromDate'];
	}
	
	//denomination
	if (count($denominations) > 0){
		$typeDesc['denomination'] = array();
		foreach ($denominations as $denomination){
			$val = trim(str_replace('"', '', $denomination));
			$uncertain = substr($val, -1) == '?' ? true : false;
			$label = trim(str_replace('?', '', $val));
			
			$typeDesc['denomination'][] = array('label'=>$label, 'uncertain'=>$uncertain);
		}
	}
	//manufacture
	if (count($manufactures) > 0){
		$typeDesc['manufacture'] = array();
		foreach ($manufactures as $manufacture){
			$val = trim(str_replace('"', '', $manufacture));
			$uncertain = substr($val, -1) == '?' ? true : false;
			$label = trim(str_replace('?', '', $val));
			if (strstr(strtolower($label), 'struck')){
				$typeDesc['manufacture'][] = array('label'=>'Struck', 'uncertain'=>$uncertain, 'uri'=>'http://nomisma.org/id/struck');
			} else if (strstr(strtolower($label), 'cast')){
				$typeDesc['manufacture'][] = array('label'=>'Cast', 'uncertain'=>$uncertain, 'uri'=>'http://nomisma.org/id/cast');
			} else {
				$typeDesc['manufacture'][] = array('label'=>$label, 'uncertain'=>$uncertain);
			}
		}
	}
	//material
	if (count($materials) > 0){
		$typeDesc['material'] = array();
		foreach ($materials as $material){;
		$mat_array = parse_material(trim($material));
		if (isset($mat_array['uri'])){
			$typeDesc['material'][] = array('label'=>$mat_array['label'], 'uncertain'=>$mat_array['uncertain'], 'uri'=>$mat_array['uri']);
		} else {
			$typeDesc['material'][] = array('label'=>$mat_array['label'], 'uncertain'=>$mat_array['uncertain']);
		}
		}
	}
	//obverse
	if (strlen($row['obverselegend']) > 0 || strlen($row['obversesymbol']) > 0 || strlen($row['obversetype']) > 0 || count($artists_obv) > 0){
		$typeDesc['obverse'] = array();
		$obverse = array();
		
		//obverselegend
		if (strlen($row['obverselegend']) > 0){
			$obverse['legend'] = trim($row['obverselegend']);
		}
		//obversesymbol
		if (strlen($row['obversesymbol']) > 0){
			$obverse['symbol'] = trim($row['obversesymbol']);
		}
		//obversetype
		if (strlen($row['obversetype']) > 0){
			$obverse['type'] = trim($row['obversetype']);
		}
		//artist
		if (count($artists_obv) > 0){
			$obverse['entities'] = array();
			foreach ($artists_obv as $artist){
				//WORK ON ARTIST OBV/REV
				$uncertain = substr($artist, -1) == '?' ? true : false;
				$label = str_replace('?', '', $artist);
				
				$obverse['entities'][] = array('label'=>$label, 'uncertain'=>$uncertain, 'element'=>'persname', 'role'=>'artist');
			}
		}
		
		//deities
		if ($department == 'Greek' || $department == 'Roman'){
			$haystack = strtolower($row['obversetype']);
			foreach($deities_array as $deity){
				if ($deity['name'] != 'Hera' && $deity['name'] != 'Sol' && strlen(strstr($haystack,strtolower($deity['matches'])))>0) {
					if (strlen($deity['bm_uri']) > 0) {
						$obverse['entities'][] = array('label'=>$deity['name'], 'uri'=>$deity['bm_uri'], 'element'=>'persname', 'role'=>'deity');
					} else {
						$obverse['entities'][] = array('label'=>$deity['name'], 'element'=>'persname', 'role'=>'deity');
					}
				}
				//Hera and Sol need special cases because they are commonly part of other works, eg Herakles, soldiers
				elseif ($deity['name'] == 'Hera' && strlen(strstr($haystack,strtolower($deity['matches'] . ' '))) >0){
					if (strlen($deity['bm_uri']) > 0) {
						$obverse['entities'][] = array('label'=>$deity['name'], 'uri'=>$deity['bm_uri'], 'element'=>'persname', 'role'=>'deity');
					} else {
						$obverse['entities'][] = array('label'=>$deity['name'], 'element'=>'persname', 'role'=>'deity');
					}
				}
				elseif ($deity['name'] == 'Sol' && strlen(strstr($haystack,strtolower($deity['matches'] . ' ')))>0){
					if (strlen($deity['bm_uri']) > 0) {
						$obverse['entities'][] = array('label'=>$deity['name'], 'uri'=>$deity['bm_uri'], 'element'=>'persname', 'role'=>'deity');
					} else {
						$obverse['entities'][] = array('label'=>$deity['name'], 'element'=>'persname', 'role'=>'deity');
					}
				}
			}
		}
		$typeDesc['obverse'] = $obverse;
	}
	
	//reverse
	if (strlen($row['reverselegend']) > 0 || strlen($row['reversesymbol']) > 0 || strlen($row['reversetype']) > 0 || count($artists_rev) > 0){
		$typeDesc['reverse'] = array();
		$reverse = array();
		
		//reverselegend
		if (strlen($row['reverselegend']) > 0){
			$reverse['legend'] = trim($row['reverselegend']);
		}
		//reversesymbol
		if (strlen($row['reversesymbol']) > 0){
			$reverse['symbol'] = trim($row['reversesymbol']);
		}
		//reversetype
		if (strlen($row['reversetype']) > 0){
			$reverse['type'] = trim($row['reversetype']);
		}
		//artist
		if (count($artists_rev) > 0){
			$reverse['artist'] = array();
			foreach ($artists_rev as $artist){
				//WORK ON ARTIST OBV/REV
				$uncertain = substr($artist, -1) == '?' ? true : false;
				$label = str_replace('?', '', $artist);
				
				$reverse['entities'][] = array('label'=>$label, 'uncertain'=>$uncertain, 'element'=>'persname', 'role'=>'artist');
			}
		}
		
		//deities
		if ($department == 'Greek' || $department == 'Roman'){
			$haystack = strtolower($row['reversetype']);
			foreach($deities_array as $deity){
				if ($deity['name'] != 'Hera' && $deity['name'] != 'Sol' && strlen(strstr($haystack,strtolower($deity['matches'])))>0) {
					if (strlen($deity['bm_uri']) > 0) {
						$reverse['entities'][] = array('label'=>$deity['name'], 'uri'=>$deity['bm_uri'], 'element'=>'persname', 'role'=>'deity');
					} else {
						$reverse['entities'][] = array('label'=>$deity['name'], 'element'=>'persname', 'role'=>'deity');
					}
				}
				//Hera and Sol need special cases because they are commonly part of other works, eg Herakles, soldiers
				elseif ($deity['name'] == 'Hera' && strlen(strstr($haystack,strtolower($deity['matches'] . ' '))) >0){
					if (strlen($deity['bm_uri']) > 0) {
						$reverse['entities'][] = array('label'=>$deity['name'], 'uri'=>$deity['bm_uri'], 'element'=>'persname', 'role'=>'deity');
					} else {
						$reverse['entities'][] = array('label'=>$deity['name'], 'element'=>'persname', 'role'=>'deity');
					}
				}
				elseif ($deity['name'] == 'Sol' && strlen(strstr($haystack,strtolower($deity['matches'] . ' ')))>0){
					if (strlen($deity['bm_uri']) > 0) {
						$reverse['entities'][] = array('label'=>$deity['name'], 'uri'=>$deity['bm_uri'], 'element'=>'persname', 'role'=>'deity');
					} else {
						$reverse['entities'][] = array('label'=>$deity['name'], 'element'=>'persname', 'role'=>'deity');
					}
				}
			}
		}
		
		$typeDesc['reverse'] = $reverse;
	}
	
	//edge
	if (strlen(trim($row['edge'])) > 0){
		$typeDesc['edge'] = trim($row['edge']);
	}
	
	/***** GEOGRAPHICAL LOCATIONS *****/
	if (count($mints) > 0 || count($regions) > 0 || count($localities) > 0){
		$typeDesc['geographic'] = array();
		$geographic = array();
		if (strlen(trim($row['mint'])) > 0){
			foreach ($mints as $mint){
				//normalize mint by stripping bad characters
				if (substr($mint, 1, 1) == '('){
					$mint_normalized = trim(preg_replace('/\(|\)|\"|\{|\}|\[|\]|\#/', "", $mint));
				} else {
					$mint_normalized = trim(preg_replace('/\"|\{|\}|\[|\]|\#/', "", $mint));
				}
				$geography = parse_mint($department, $mint_normalized, $regions, $localities);
				
				if (isset($geography['mint'])){
					$mint = array();
					$mint['label'] = $geography['mint']['label'];
					if (isset($geography['mint']['certainty'])){
						$mint['certainty'] = $geography['mint']['certainty'];
					}
					if (isset($geography['mint']['uri'])){
						$mint['uri'] = $geography['mint']['uri'];
					}
					
					$geographic['mint'][] = $mint;
				}
				
				if (isset($geography['state'])){
					$geogAuthorities['state'] = $geography['state'];
				}
				if (isset($geography['authority'])){
					$geogAuthorities['authority'] = $geography['authority'];
				}
			}
		}
		//region
		if (count($regions) > 0){
			foreach ($regions as $region){
				$val = trim(str_replace('"', '', $region));
				$uncertain = substr($val, -1) == '?' ? true : false;
				$label =trim(str_replace('?', '', $val));
				
				$geographic['region'][] = array('label'=>$label, 'uncertain'=>$uncertain);
			}
		}
		//locality
		if (count($localities) > 0){
			foreach ($localities as $locality){
				$val = trim(str_replace('"', '', $locality));
				$uncertain = substr($val, -1) == '?' ? true : false;
				$label =trim(str_replace('?', '', $val));
				
				$geographic['locality'][] = array('label'=>$label, 'uncertain'=>$uncertain);
			}
		}
		
		$typeDesc['geographic'] = $geographic;
	}
	
	/***** AUTHORITIES AND PERSONS *****/
	if (isset($geogAuthorities['state']) || isset($geogAuthorities['authority']) || count($persons) > 0 || count($issuers) > 0 || count($magistrates) > 0 || count($makers) > 0 ||  count($artists_none) > 0 || count($dynasties) > 0){
		$authority = array();
		
		//insert authorities parsed out from the mint lookups (applies primarily to Latin America)
		if (isset($geogAuthorities['state'])){
			$entity= array('label'=>$geogAuthorities['state']['label'], 'element'=>'corpname', 'role'=>'state');
			
			if (isset($geogAuthorities['state']['uri'])){
				$entity['uri'] = $geogAuthorities['state']['uri'];
			}
			if (isset($geogAuthorities['state']['certainty'])){
				$entity['certainty'] = $geogAuthorities['state']['certainty'];
			}
			$authority[] = $entity;
		}
		
		if (isset($geogAuthorities['authority'])){
			$entity= array('label'=>$geogAuthorities['authority']['label'], 'element'=>'corpname', 'role'=>'authority');
			
			if (isset($geogAuthorities['authority']['uri'])){
				$entity['uri'] = $geogAuthorities['authority']['uri'];
			}
			if (isset($geogAuthorities['authority']['certainty'])){
				$entity['certainty'] = $geogAuthorities['authority']['certainty'];
			}
			$authority[] = $entity;
		}
		
		//issuer
		if (count($issuers) > 0){
			foreach ($issuers as $issuer){
				$val = trim(str_replace('"', '', $issuer));
				$uncertain = substr($val, -1) == '?' ? true : false;
				$val = trim(str_replace('?', '', $val));
				
				if ($department == 'Medieval' || $department == 'Byzantine' || $department == 'Roman'){
					$entity = array('label'=>$val, 'uncertain'=>$uncertain, 'element'=>'persname', 'role'=>'issuer');
				} elseif ($department == 'Islamic'){
				    $entity = lookup_entity($department, $val, $uncertain, 'authority');
					//$entity = array('label'=>$val, 'uncertain'=>$uncertain, 'element'=>'persname', 'role'=>'authority');
				} elseif ($department == 'Greek'){
				    //attempt to to normalize the $val to a URI and preferred label in the Greek authorities spreadsheet
				    $entity = lookup_entity($department, $val, $uncertain, 'authority');
				}
				else {
					$entity = array('label'=>$val, 'uncertain'=>$uncertain, 'element'=>'corpname', 'role'=>'issuer');
				}
				
				if (isset($entity)){
				    $authority[] = $entity;
				}				
			}
		}
		//artist
		if (count($artists_none) > 0){
			foreach ($artists_none as $artist){
				$val = trim(str_replace('"', '', $artist));
				$uncertain = substr($val, -1) == '?' ? true : false;
				$val = trim(str_replace('?', '', $val));
				
				$entity = array('label'=>$val, 'uncertain'=>$uncertain, 'element'=>'persname', 'role'=>'artist');
				$authority[] = $entity;
			}
		}
		
		
		//dynasty
		if ($department != "Greek"){
		    if (count($dynasties) > 0){
		        foreach ($dynasties as $dynasty){
		            $val = trim(str_replace('"', '', $dynasty));
		            $uncertain = substr($val, -1) == '?' ? true : false;
		            $val = trim(str_replace('?', '', $val));
		            
		            $entity = array('label'=>$val, 'uncertain'=>$uncertain, 'element'=>'famname', 'role'=>'dynasty');
		            $authority[] = $entity;
		        }
		    }
		}		
		
		//maker
		if (count($makers) > 0){
			foreach ($makers as $maker){
				$val = trim(str_replace('"', '', $maker));
				$uncertain = substr($val, -1) == '?' ? true : false;
				$val = trim(str_replace('?', '', $val));
				
				$entity = array('label'=>$val, 'uncertain'=>$uncertain, 'element'=>'corpname', 'role'=>'maker');
				$authority[] = $entity;
			}
		}
		//magistrate
		if (count($magistrates) > 0){
			foreach ($magistrates as $magistrate){
				$val = trim(str_replace('"', '', $magistrate));
				$uncertain = substr($val, -1) == '?' ? true : false;
				$val = trim(str_replace('?', '', $val));
				
				$entity = array('label'=>$val, 'uncertain'=>$uncertain, 'element'=>'persname', 'role'=>'issuer');
				$authority[] = $entity;
			}
		}
		//person: portrait
		if (count($persons) > 0){
			foreach ($persons as $person){
				$val = trim(str_replace('"', '', $person));
				$uncertain = substr($val, -1) == '?' ? true : false;
				$val = trim(str_replace('?', '', $val));
				
				if ($department == 'Roman' || $department == 'Byzantine' || $department == 'Medal' || $department == 'United States' || $department == 'Decoration'){
					$entity = array('label'=>$val, 'uncertain'=>$uncertain, 'element'=>'persname', 'role'=>'portrait');
				}
				if ($department == 'Roman' || $department == 'Byzantine' || $department == 'Medieval'|| $department == 'East Asian' || $department == 'South Asian' || $department == 'Modern' || $department == 'Latin American'){
					$entity = array('label'=>$val, 'uncertain'=>$uncertain, 'element'=>'persname', 'role'=>'authority');
				} elseif ($department == 'Islamic'){
				    $entity = lookup_entity($department, $val, $uncertain, 'authority');
				} elseif ($department == 'Greek'){
				    //attempt to to normalize the $val to a URI and preferred label in the Greek authorities spreadsheet
				    
				    //if there are values in issuer, then person is a portrait
				    if (count($issuers) > 0){
				        $entity = lookup_entity($department, $val, $uncertain, 'portrait');
				    } else {
				        $entity = lookup_entity($department, $val, $uncertain, 'authority');
				    }				    
				}
				
				if (isset($entity)){
				    $authority[] = $entity;
				}	
			}
		}
		$typeDesc['authority'] = $authority;
	}
	
	return $typeDesc;
}

?>
