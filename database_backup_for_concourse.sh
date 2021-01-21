#!/bin/bash
set +x


#Required psql version for concourse db dump to work is 9.3 and above. Below is the check to ensure system has right version.

currentver="$(psql --version | awk '{print $3}')"
requiredver="9.3.0"
 if [ "$(printf '%s\n' "$requiredver" "$currentver" | sort -V | head -n1)" = "$requiredver" ]; then
        echo "PSQL version is greater than or equal to 9.3.0"
 else
        echo "PSQL version is less than 9.3.0"
                echo "Installing required version 9.6.X"
                yum update -y
                yum install postgresql96 postgresql96-server postgresql96-libs postgresql96-contrib postgresql96-devel -y
                PATH=/usr/pgsql-9.6/bin:$PATH
                export PATH
 fi


#Get the IP address of concourse postgresql pod.

postgresql=$(kubectl get pods -o wide | grep concourse-postgresql | awk '{print $6}')
export PGPASSWORD="concourse"
cd /root/concourse_db_backup

#Remove old copy of db dump
if [ ! -f "conourse_db.bakold" ]; then
   rm -rf conourse_db.bakold
fi

#Take the backup of old dump
if [ ! -f "conourse_db.bak" ]; then
   mv conourse_db.bak conourse_db.bakold
fi

#Dump the concourse db in compressed format(-Fc)
pg_dump -h $postgresql -p 5432 concourse -U concourse -Fc > conourse_db.bak
