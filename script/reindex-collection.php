<?php 

/*******
 * Author: Ethan Gruber
 * Date: January 2021
 * Function: execute an XQuery of a a given collection and load the config in order to determine the number of documents to ingest
 * in each batch to re-index an entire collection outside of the XForms user interface (which is slower).
 * Execute script with `php reindex-collection.php $collection_name`
 *******/

define("NUMISHARE_URL", 'http://localhost:8080/orbeon/numishare/');
define("SOLR_URL", 'http://localhost:8983/solr/numishare/update/');

$eXist_config_path = '/usr/local/projects/numishare/exist-config.xml';
$xquery = "<?xml version='1.0' encoding='utf-8'?>
<exist:query xmlns:exist='http://exist.sourceforge.net/NS/exist'><exist:text>
<![CDATA[xquery version '1.0';
<report>
    {
        for \$i in collection()[descendant::*[local-name() = 'publicationStatus'] = 'approved' or descendant::*[local-name() = 'publicationStatus'] = 'approvedSubtype']
        return 
            <id>
                {data(\$i//*:recordId)}
            </id>
    }
</report>]]></exist:text></exist:query>";
$ids = array();


if (isset($argv[1])){
    $collection = $argv[1];
    
    if (file_exists($eXist_config_path)) {
        $eXist_config = simplexml_load_file($eXist_config_path);
        //$eXist_credentials = $eXist_config->username . ':' . $eXist_config->password;
        
        //read the Numishare config to parse the collection_type to discern the number of records to batch process
        $config = simplexml_load_file($eXist_config->url . $collection . '/config.xml');        
        switch($config->collection_type){
            case 'hoard':
                $perPage = 25;
                break;
            case 'object':
                $perPage = 1000;
                break;
            default:
                $perPage = 100;
        }
        
        //echo $perPage;
        echo "Querying eXist-db to get a list of publishable IDs\n";
        $ch=curl_init();
        curl_setopt($ch,CURLOPT_URL, $eXist_config->url . $collection);
        curl_setopt($ch,CURLOPT_POST,1);
        curl_setopt($ch,CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8"));
        curl_setopt($ch,CURLOPT_POSTFIELDS, $xquery);
        curl_setopt($ch,CURLOPT_USERPWD,$eXist_config->username . ':' . $eXist_config->password);
        
        $response = curl_exec($ch);        
        echo "IDs received. Processing now.\n";
        $list = simplexml_load_string($response);
        curl_close($ch);
        
        $page = 1;
        foreach ($list->report->id as $id){
            $total = count($list->report->id);
            $ids[] = trim($id->__toString());
            
            //begin processing batches
            
            if (count($ids) > 0 && count($ids) % $perPage == 0 ){
                echo "Indexing page {$page} of " . (ceil($total / $perPage)) . "\n";
                $start = count($ids) - $perPage;
                $toIndex = array_slice($ids, $start, $perPage);
                
                //POST TO SOLR
                post_to_solr($toIndex, $eXist_config, $collection);                
                $page++;
            }
        }
        
        //index final chunk
        echo "Indexing final page\n";
        $start = floor(count($ids) / $perPage) * $perPage;
        $toIndex = array_slice($ids, $start);
        
        //POST TO SOLR
        post_to_solr($toIndex, $eXist_config, $collection);
       
        
    } else {
        echo "eXist config not found at {$eXist_config_path}\n";
    }
} else {
    echo "No collection name set\n";
}

function post_to_solr($toIndex, $eXist_config, $collection){
    $identifiers = urlencode(implode('|', $toIndex));
    $url = NUMISHARE_URL . "{$collection}/ingest?identifiers={$identifiers}";
    
    $ch=curl_init();
    curl_setopt($ch,CURLOPT_URL, $url);
    curl_setopt($ch,CURLOPT_RETURNTRANSFER, true);
    $solrAddDoc = curl_exec($ch);    
    curl_close($ch);
    
    //post add doc to Solr
    $ch=curl_init();
    curl_setopt($ch,CURLOPT_URL, SOLR_URL);
    curl_setopt($ch,CURLOPT_POST,1);
    curl_setopt($ch,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8"));
    curl_setopt($ch,CURLOPT_RETURNTRANSFER, true); 
    curl_setopt($ch,CURLOPT_POSTFIELDS, $solrAddDoc);    
    $solrResponse = curl_exec($ch); 
    curl_close($ch);
    
    //post Solr commit
    $ch=curl_init();
    curl_setopt($ch,CURLOPT_URL, SOLR_URL);
    curl_setopt($ch,CURLOPT_POST,1);
    curl_setopt($ch,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8"));
    curl_setopt($ch,CURLOPT_RETURNTRANSFER, true); 
    curl_setopt($ch,CURLOPT_POSTFIELDS, '<commit/>');
    $solrResponse = curl_exec($ch);
    curl_close($ch);
}

?>