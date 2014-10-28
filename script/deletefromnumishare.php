<?php 
	/************************
	AUTHOR: Ethan Gruber
	MODIFIED: April, 2011
	DESCRIPTION: Receive an accession number in a parameter and delete from Numishare:
	eXist database and Solr index.
	REQUIRED LIBRARIES: php5, php5-curl, php5-cgi
	************************/

	$accnum = $_GET['accnum'];

	if (strlen(trim($accnum)) > 0){
		$basename = $accnum . '.xml';
		//get accession year for supplying the correct eXist collection
		$collection = substr(trim($accnum), 0, 4);
		
		//echo $basename . '|' . $collection . '|' . $solrId . "\n";
		//PUT xml to eXist
		$deleteFromExist=curl_init();		
		//set curl opts
		curl_setopt($deleteFromExist,CURLOPT_URL,'http://localhost:8080/exist/rest/db/numishare/ead/' . $collection . '/' . $basename);
		curl_setopt($deleteFromExist,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8")); 
		curl_setopt($deleteFromExist,CURLOPT_CONNECTTIMEOUT,2);
		curl_setopt($deleteFromExist,CURLOPT_RETURNTRANSFER,1);
		curl_setopt($deleteFromExist,CURLOPT_CUSTOMREQUEST, "DELETE");
		curl_setopt($deleteFromExist,CURLOPT_USERPWD,"username:password");
		$response = curl_exec($deleteFromExist);
		
		$http_code = curl_getinfo($deleteFromExist,CURLINFO_HTTP_CODE); 
		
		//error and success logging
		if (curl_error($deleteFromExist) === false){
			error_log($basename . ' failed to delete from eXist at ' . date("d/m/y : H:i:s", time()) . "\n", 3, "/var/log/numishare/error.log");
		} else {
			error_log($basename . ' deleted at ' . date("d/m/y : H:i:s", time()) . "\n", 3, "/var/log/numishare/success.log");
				
			//DELETE FROM SOLR
			$solrId = 'ans' . str_replace('.', '_', $accnum);
			$solrDeleteXml = '<delete><id>' . $solrId . '</id></delete>';

			//post solr doc
			$deleteFromSolr=curl_init();
			curl_setopt($deleteFromSolr,CURLOPT_URL,'http://localhost:8080/solr/numishare/update/');
			curl_setopt($deleteFromSolr,CURLOPT_POST,1);				
			curl_setopt($deleteFromSolr,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8"));
			curl_setopt($deleteFromSolr,CURLOPT_POSTFIELDS, $solrDeleteXml);				
			
			$solrResponse = curl_exec($deleteFromSolr);
			echo $solrResponse;
			curl_close($deleteFromSolr);
				
			$commitToSolr=curl_init();
			curl_setopt($commitToSolr,CURLOPT_URL,'http://localhost:8080/solr/numishare/update/');
			curl_setopt($commitToSolr,CURLOPT_POST,1);				
			curl_setopt($commitToSolr,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8"));
			curl_setopt($commitToSolr,CURLOPT_POSTFIELDS, '<commit/>');
				
			$solrResponse = curl_exec($commitToSolr);
			echo $solrResponse;
			curl_close($commitToSolr);
		}
		//close eXist curl
		curl_close($deleteFromExist);
	}
?>