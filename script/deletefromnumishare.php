<?php 
	/************************
	AUTHOR: Ethan Gruber
	MODIFIED: April, 2011
	DESCRIPTION: Receive an accession number in a parameter and delete from Numishare:
	eXist database and Solr index.
	REQUIRED LIBRARIES: php7, php7-curl, php7-cgi
	APACHE MODULES: sudo a2enmod cgi
	************************/

	$accnum = trim($_GET['accnum']);

	if (strlen($accnum) > 0){
		$basename = $accnum . '.xml';
		//get accession year for supplying the correct eXist collection
		$collection = substr($accnum, 0, 4);
		
		//echo $basename . '|' . $collection . '|' . $solrId . "\n";
		//PUT xml to eXist
		$deleteFromExist=curl_init();		
		//set curl opts
		curl_setopt($deleteFromExist,CURLOPT_URL,'http://localhost:8080/exist/rest/db/mantis/objects/' . $collection . '/' . $basename);
		curl_setopt($deleteFromExist,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8")); 
		curl_setopt($deleteFromExist,CURLOPT_CONNECTTIMEOUT,2);
		curl_setopt($deleteFromExist,CURLOPT_RETURNTRANSFER,1);
		curl_setopt($deleteFromExist,CURLOPT_CUSTOMREQUEST, "DELETE");
		curl_setopt($deleteFromExist,CURLOPT_USERPWD,"admin:");
		$response = curl_exec($deleteFromExist);
		
		$http_code = curl_getinfo($deleteFromExist,CURLINFO_HTTP_CODE); 
		
		//error and success logging
		if (curl_error($deleteFromExist) === false){
			$message = $basename . ' failed to delete from eXist at ' . date("d/m/y : H:i:s", time());
			error_log($message . "\n", 3, "/var/log/numishare/error.log");
			generate_response($message, 'Error');
			
		} else {
			error_log($basename . ' deleted at ' . date("d/m/y : H:i:s", time()) . "\n", 3, "/var/log/numishare/success.log");
			//close eXist curl
			curl_close($deleteFromExist);
			
			//DELETE FROM SOLR
			$solrDeleteXml = '<delete><query>recordId:"' . $accnum . '"</query></delete>';

			//post solr doc
			$deleteFromSolr=curl_init();
			curl_setopt($deleteFromSolr,CURLOPT_URL,'http://localhost:8080/solr/numishare/update/');
			curl_setopt($deleteFromSolr,CURLOPT_POST,1);				
			curl_setopt($deleteFromSolr,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8"));
			curl_setopt($deleteFromSolr,CURLOPT_POSTFIELDS, $solrDeleteXml);				
			
			$solrResponse = curl_exec($deleteFromSolr);
			if (curl_error($deleteFromSolr) === false){ 
				curl_close($deleteFromSolr);
				$message = $accnum . ' failed to delete from Solr at ' . date("d/m/y : H:i:s", time());
				error_log($message . "\n", 3, "/var/log/numishare/error.log");
				generate_response($message, 'Error');
			} else {				
				curl_close($deleteFromSolr);				
				$commitToSolr=curl_init();
				curl_setopt($commitToSolr,CURLOPT_URL,'http://localhost:8080/solr/numishare/update/');
				curl_setopt($commitToSolr,CURLOPT_POST,1);
				curl_setopt($commitToSolr,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8"));
				curl_setopt($commitToSolr,CURLOPT_POSTFIELDS, '<commit/>');
				
				$solrResponse = curl_exec($commitToSolr);
				if (curl_error($deleteFromSolr) === false){ 
					curl_close($commitToSolr);
					$message = 'Solr commit failed.';
					error_log($message . "\n", 3, "/var/log/numishare/error.log");
					generate_response($message, 'Error');
				} else {
					$message = $accnum . ' successfully deleted from Mantis at ' . date("d/m/y : H:i:s", time());
					generate_response($message, 'Success');
					curl_close($commitToSolr);
				}
			}
		}		
	}
	
	function generate_response($message, $type){
		$body = "<html><head><title>{$type}</title></head>";
		$body .= "<body><h1>{$type}</h1>";
		$body .= "<p>{$message}</p>";
		$body .= '</body></html>';
		
		echo $body;
	}
?>