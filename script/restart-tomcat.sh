#!/bin/sh

#restarts tomcat after a timeout. the script should be run in cron as root

service=tomcat10
max_retries=3
retry_count=0

while [ $retry_count -lt $max_retries ]; do
  curl -m 10 http://localhost:8080/orbeon/numishare/

  if [ $? -eq 0 ]; then
    echo "Tomcat request was successful"
    
    #if Tomcat is successful, try Apache
    curl -m 10 http://localhost/
    if [ $? -eq 0 ]; then
        echo "Apache request was successful"
        break
    else
        echo "Restarting Apache"
        service apache2 stop
        service apache2 start
    fi
    
    
    break
  else
    echo "Request failed with exit code $?. Retrying..."
    retry_count=$((retry_count + 1))
    sleep 2 # Wait for 2 seconds before retrying
  fi
done

if [ $retry_count -eq $max_retries ]; then
  echo "Restarting Tomcat"
  service $service stop
  service $service start
fi