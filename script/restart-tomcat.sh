#!/bin/sh

service=tomcat10
max_retries=3
retry_count=0

while [ $retry_count -lt $max_retries ]; do
  curl -m 10 http://localhost:8080/orbeon/numishare/

  if [ $? -eq 0 ]; then
    echo "Request was successful"
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