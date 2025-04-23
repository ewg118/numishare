#!/bin/sh

#restarts tomcat after a timeout. the script should be run in cron as root

service=tomcat10

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
        echo $(date --utc +%FT%T.%3NZ) "Restarted Apache" >> /var/log/$service/restart.log
        service apache2 stop
        service apache2 start
    fi    
    
    break
else
    echo "Restarting Apache"
    service apache2 restart
    echo "Restarting Tomcat"
    echo $(date --utc +%FT%T.%3NZ) "Restarted Tomcat" >> /var/log/$service/restart.log
    service $service stop
    service $service start
fi