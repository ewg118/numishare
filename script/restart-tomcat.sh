#!/bin/sh

#restarts tomcat after a timeout. the script should be run in cron as root

service=tomcat10

curl -m 10 http://localhost:8080/orbeon/numishare/

if [ $? -eq 0 ]; then
    echo "Tomcat request was successful"
    
    #read HTTP code to ensure the HTTP response is correct, not just a timeout
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/orbeon/numishare/)    
    
    if [ $HTTP_STATUS != "200" ]; then
        echo "Tomcat is not hanging, but Orbeon is non-responsive"
        echo $(date --utc +%FT%T.%3NZ) "Restarted Tomcat due to Orbeon Forms error" >> /var/log/$service/restart.log
        service $service stop
        service $service start
        service apache2 restart
    else   
        #if Tomcat is successful, try Apache
        curl -m 10 http://localhost/
        if [ $? -eq 0 ]; then
            echo "Apache request was successful"
        else
            echo "Restarting Apache"
            echo $(date --utc +%FT%T.%3NZ) "Restarted Apache" >> /var/log/$service/restart.log
            service apache2 stop
            service apache2 start
        fi    
    fi
else
    echo "Restarting Apache"
    service apache2 restart
    echo "Restarting Tomcat"
    echo $(date --utc +%FT%T.%3NZ) "Restarted Tomcat" >> /var/log/$service/restart.log
    service $service stop
    service $service start
fi