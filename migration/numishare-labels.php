<?php 

/* This PHP script reads CSV from the Numishare Labels Google spreadsheet
 * and generates partial xsl:choose statements to be posted into Numishare's
 * functions.xsl
 */

$labels = generate_json('https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Avp6BVZhfwHAdFVocVZHUWpnZHMxaXZ2LWVEU25wUFE&single=true&gid=0&output=csv');

//declare dynamic array variables for each language
foreach ($labels[0] as $k=>$v){
	if ($k != 'field'){
		$$k = array();
	}
}

//populate arrays
foreach ($labels as $row){
	$key = $row['field'];
	foreach ($row as $k=>$v){
		if ($k != 'field' && strlen($row['en']) > 0){
			if (strlen($v) > 0){
				$new = array($key, $v);
				array_push($$k, $new);
			}			
			//$$k[$key] = $v;
		}
	}
}

//var_dump($labels);

//process into separate  xsl functions
$writer = new XMLWriter();
$writer->openURI('labels.xml');
//$writer->openURI('php://output');
$writer->startDocument('1.0','UTF-8');
$writer->setIndent(true);
//now we need to define our Indent string,which is basically how many blank spaces we want to have for the indent
$writer->setIndentString("    ");
$writer->startElement('xsl:stylesheet');
$writer->writeAttribute('xmlns:xsl', 'http://www.w3.org/1999/XSL/Transform');

	//begin the numishare:regularize_node function that normalizes NUDS for Solr field namess
	$writer->startElement('xsl:function');
		$writer->writeAttribute('name', 'numishare:regularize_node');
		$writer->startElement('xsl:param');
			$writer->writeAttribute('name', 'label');
		$writer->endElement();
		$writer->startElement('xsl:param');
			$writer->writeAttribute('name', 'lang');
		$writer->endElement();
		$writer->startElement('xsl:choose');
			foreach ($labels[0] as $k=>$v){
				if ($k != 'field'){
				    if ($k != 'en'){
    				    $writer->startElement('xsl:when');
    						$writer->writeAttribute('test', "\$lang='" . $k . "'");
    						$writer->startElement('xsl:choose');
    						$regularize_node = true;
    						foreach ($$k as $row){
    							if ($regularize_node == true){
    								//echo "{$row[0]}-{$row[1]}\n";
    								$writer->startElement('xsl:when');
    									$writer->writeAttribute('test', "\$label='" . $row[0] . "'");
    									$writer->text(trim($row[1]));
    								$writer->endElement();
    							}
    							if ($row[0] == 'year'){
    								$regularize_node = false;
    							}
    						}
    							//otherwise call the function for English
    							$writer->startElement('xsl:otherwise');
    								$writer->startElement('xsl:value-of');
    									$writer->writeAttribute('select', "numishare:regularize_node(\$label, 'en')");
    								$writer->endElement();
    							$writer->endElement();
    						//end choose
    						$writer->endElement();
    					$writer->endElement();		    
				    } else {
				        $writer->startElement('xsl:otherwise');
    				        $writer->startElement('xsl:choose');
    				        $regularize_node = true;
    				        foreach ($$k as $row){
    				            if ($regularize_node == true){
    				                //echo "{$row[0]}-{$row[1]}\n";
    				                $writer->startElement('xsl:when');
        				                $writer->writeAttribute('test', "\$label='" . $row[0] . "'");
        				                $writer->text(trim($row[1]));
    				                $writer->endElement();
    				            }
    				            if ($row[0] == 'year'){
    				                $regularize_node = false;
    				            }
    				        }
    				        //otherwise call the function for English
    				        $writer->startElement('xsl:otherwise');
        				        $writer->startElement('xsl:value-of');
        				            $writer->writeAttribute('select', "concat(upper-case(substring(\$label, 1, 1)), substring(\$label, 2))");
        				        $writer->endElement();
    				        $writer->endElement();
    				        //end choose
    				        $writer->endElement();
				        $writer->endElement();	
				    }
					
				}
			}			
		//end choose
		$writer->endElement();
	//end function
	$writer->endElement();
	
	//begin the numishare:normalizeLabel, which normalizes Numishare user interface labels
	$writer->startElement('xsl:function');
		$writer->writeAttribute('name', 'numishare:normalizeLabel');
		$writer->startElement('xsl:param');
			$writer->writeAttribute('name', 'label');
		$writer->endElement();
		$writer->startElement('xsl:param');
			$writer->writeAttribute('name', 'lang');
		$writer->endElement();
		$writer->startElement('xsl:choose');
			foreach ($labels[0] as $k=>$v){
				if ($k != 'field'){
				    if ($k != 'en'){
    				    $writer->startElement('xsl:when');
    						$writer->writeAttribute('test', "\$lang='" . $k . "'");
    						$writer->startElement('xsl:choose');
    						$regularize_node = true;
    						foreach ($$k as $row){
    							if ($regularize_node == false){
    								//echo "{$row[0]}-{$row[1]}\n";
    								$writer->startElement('xsl:when');
    									$writer->writeAttribute('test', "\$label='" . $row[0] . "'");
    									$writer->text(trim($row[1]));
    								$writer->endElement();
    							}
    							if ($row[0] == 'year'){
    								$regularize_node = false;
    							}
    						}
    							//otherwise call the function for English
    							$writer->startElement('xsl:otherwise');
    								$writer->startElement('xsl:value-of');
    									$writer->writeAttribute('select', "numishare:normalizeLabel(\$label, 'en')");
    								$writer->endElement();
    							$writer->endElement();
    						//end choose
    						$writer->endElement();
    					$writer->endElement();  				        
				    } else {
				        $writer->startElement('xsl:otherwise');
    				        $writer->startElement('xsl:choose');
    				        $regularize_node = true;
    				        foreach ($$k as $row){
    				            if ($regularize_node == false){
    				                //echo "{$row[0]}-{$row[1]}\n";
    				                $writer->startElement('xsl:when');
        				                $writer->writeAttribute('test', "\$label='" . $row[0] . "'");
        				                $writer->text(trim($row[1]));
    				                $writer->endElement();
    				            }
    				            if ($row[0] == 'year'){
    				                $regularize_node = false;
    				            }
    				        }
    				        //otherwise call the function for English
    				        $writer->startElement('xsl:otherwise');
        				        $writer->startElement('xsl:value-of');
        				            $writer->writeAttribute('select', "concat('[', \$label, ']')");
        				        $writer->endElement();
    				        $writer->endElement();
    				        //end choose
    				        $writer->endElement();
				        $writer->endElement();
				    }

				}
			}
			
		//end choose
		$writer->endElement();
	//end function
	$writer->endElement();

//close xsl:stylesheet
$writer->endElement();
$writer->flush();

//var_dump($en);

function generate_json($doc){
	$keys = array();
	$geoData = array();

	$data = csvToArray($doc, ',');

	// Set number of elements (minus 1 because we shift off the first row)
	$count = count($data) - 1;

	//Use first row for names
	$labels = array_shift($data);

	foreach ($labels as $label) {
		$keys[] = $label;
	}

	// Bring it all together
	for ($j = 0; $j < $count; $j++) {
		$d = array_combine($keys, $data[$j]);
		$geoData[$j] = $d;
	}
	return $geoData;
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