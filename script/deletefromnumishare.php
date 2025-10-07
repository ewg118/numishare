<?php 
	/************************
	AUTHOR: Ethan Gruber
	MODIFIED: October 2025
	DESCRIPTION: Receive an accession number in a parameter and delete from Numishare:
	eXist database and Solr index.
	REQUIRED LIBRARIES: php7, php7-curl, php7-cgi
	APACHE MODULES: sudo a2enmod cgi
	************************/
    $eXist_config_path = '/usr/local/projects/numishare/exist-config.xml';
	$accnum = trim($_GET['accnum']);
	$collection = trim($_GET['collection']);

	if (file_exists($eXist_config_path)) {
	    $eXist_config = simplexml_load_file($eXist_config_path);
	    $eXist_url = $eXist_config->url;
	    $eXist_credentials = $eXist_config->username . ':' . $eXist_config->password;
	    
	    //delete accnum
	    if (strlen($accnum) > 0){
	        $basename = $accnum . '.xml';	        
	        
	        if ($collection == 'mantis') {
	            //get accession year for supplying the correct eXist collection
	            $year = substr($accnum, 0, 4);
	            
	            $url = $eXist_url . 'mantis/objects/' . $year . '/' . $basename;	            
	        } else {
	            $url = $eXist_url . $collection . '/objects/' . $basename;
	        }
	        
	        //echo $basename . '|' . $collection . '|' . $solrId . "\n";
	        //PUT xml to eXist
	        $deleteFromExist=curl_init();
	        //set curl opts
	        curl_setopt($deleteFromExist,CURLOPT_URL, $url);
	        curl_setopt($deleteFromExist,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8"));
	        curl_setopt($deleteFromExist,CURLOPT_CONNECTTIMEOUT,2);
	        curl_setopt($deleteFromExist,CURLOPT_RETURNTRANSFER,1);
	        curl_setopt($deleteFromExist,CURLOPT_CUSTOMREQUEST, "DELETE");
	        curl_setopt($deleteFromExist,CURLOPT_USERPWD,$eXist_credentials);
	        $response = curl_exec($deleteFromExist);
	        
	        $http_code = curl_getinfo($deleteFromExist,CURLINFO_HTTP_CODE);
	        
	        //error and success logging
	        if (curl_error($deleteFromExist) === false){
	            error_log($basename . ' failed to delete from eXist at ' . date("d/m/y : H:i:s", time()) . "\n", 3, "/var/log/numishare/error.log");
	        } else {
	            error_log($basename . ' deleted at ' . date("d/m/y : H:i:s", time()) . "\n", 3, "/var/log/numishare/success.log");
	            
	            //DELETE FROM SOLR
	            $solrDeleteXml = '<delete><query>recordId:"' . $accnum . '" AND collection-name:"' . $collection . '"</query></delete>';
	            //post solr doc
	            $deleteFromSolr=curl_init();
	            curl_setopt($deleteFromSolr,CURLOPT_URL,'http://localhost:8983/solr/numishare/update/');
	            curl_setopt($deleteFromSolr,CURLOPT_POST,1);
	            curl_setopt($deleteFromSolr,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8"));
	            curl_setopt($deleteFromSolr,CURLOPT_POSTFIELDS, $solrDeleteXml);
	            
	            $solrResponse = curl_exec($deleteFromSolr);
	            echo $solrResponse;
	            curl_close($deleteFromSolr);
	            
	            $commitToSolr=curl_init();
	            curl_setopt($commitToSolr,CURLOPT_URL,'http://localhost:8983/solr/numishare/update/');
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
	} 
	
	
?>