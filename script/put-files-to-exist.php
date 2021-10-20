<?php 

/*****
 * Author: Ethan Gruber
 * Date: October 2021
 * Function: puts NUDS XML files in the files folder into eXist-db
 */

//get the eXist-db password from disk
$eXist_config_path = '/usr/local/projects/numishare/exist-config.xml';

if (file_exists($eXist_config_path)) {
    $eXist_config = simplexml_load_file($eXist_config_path);
    $eXist_url = $eXist_config->url;
    $eXist_credentials = $eXist_config->username . ':' . $eXist_config->password;
    
    $collection = 'mantis';
    
    if ($handle = opendir('files')) {
        echo "Reading folder.\n";
        while (false !== ($file = readdir($handle))) {
            
            if (strpos($file, '.xml') !== FALSE){
                $accnum = str_replace('.xml', '', $file);
                $accPieces = explode('.', $accnum);
                $accYear = $accPieces[0];
                
                $fileName = "files/{$file}";
                
                //read file back into memory for PUT to eXist
                if (($readFile = fopen($fileName, 'r')) === FALSE){
                    error_log($accnum . ' failed to open temporary file (accnum likely broken) at ' . date(DATE_W3C) . "\n", 3, "/var/log/numishare/error.log");
                } else {
                    
                    //PUT xml to eXist
                    $putToExist=curl_init();
                    
                    //set curl opts
                    curl_setopt($putToExist,CURLOPT_URL, $eXist_url . $collection . '/objects/' . $accYear . '/' . $accnum . '.xml');
                    curl_setopt($putToExist,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8"));
                    curl_setopt($putToExist,CURLOPT_CONNECTTIMEOUT,2);
                    curl_setopt($putToExist,CURLOPT_RETURNTRANSFER,1);
                    curl_setopt($putToExist,CURLOPT_PUT,1);
                    curl_setopt($putToExist,CURLOPT_INFILESIZE,filesize($fileName));
                    curl_setopt($putToExist,CURLOPT_INFILE,$readFile);
                    curl_setopt($putToExist,CURLOPT_USERPWD,$eXist_credentials);
                    $response = curl_exec($putToExist);
                    
                    $http_code = curl_getinfo($putToExist,CURLINFO_HTTP_CODE);
                    
                    //error and success logging
                    if (curl_error($putToExist) === FALSE){
                        error_log($accnum . ' failed to upload to eXist at ' . date(DATE_W3C) . "\n", 3, "/var/log/numishare/error.log");
                    } else {
                        if ($http_code == '201'){
                            $datetime = date(DATE_W3C);
                            echo "Writing {$accnum}.\n";
                            error_log("{$accnum}: {$datetime}\n", 3, "/var/log/numishare/success.log");                            
                        }
                    }
                    //close eXist curl
                    curl_close($putToExist);
                    
                    //close files and delete from /tmp
                    fclose($readFile);
                    //unlink($fileName);
                }
            }
        }        
        closedir($handle);
    }
}



?>