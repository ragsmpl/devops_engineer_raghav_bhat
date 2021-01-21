#!/bin/sh

# This script will update the artifactory properties with deletion_status=true (only to ova) and delete_artifacts will delete them when mode(m)=1
# prior to a specified date.
# When mode(m)=0, this will set the property of ovas before a particular date and mark then with deletion_status=dry_run and then revert the property
# Back to deletion_status=false and gives the list of files which might be deleted and total number of free up space upon deletion.
#
#
#

set +x
usage()
{
  echo "usage: $0 [-h] -u <username> -p <pass> -d <DATE> -f <FOLDER> -m <MODE>"
  echo "Options:"
  echo "   -u   NT User  "
  echo "   -p   NT Password  "
  echo "   -d   Delete till date(YYYY-MM-DD)"
  echo "   -f   Folder to delete(folder inside folder_name dir)"
  echo "   -m   Set deletion mode(1 to set or 0 for dry run)"
  echo "   -h   print this help and exit"

}

MYSQL="xx.xx.xx.xx"
PASSWORD="team"
    
validate_script()
{
  if [ -z ${username} ];then
    echo "username is not passed"
    usage; exit 1
  fi
  if [ -z ${pass} ];then
    echo "Error: pass is not passed as an argument"
    usage; exit 1
  fi
  if [ -z ${DATE} ];then
    echo "Error: DATE is not passed as an argument"
    usage; exit 1
  fi
  if [ -z ${FOLDER} ] || [ $FOLDER == "proname/releases" ] ;then
    echo "Error: FOLDER is not passed as an argument or cannot delete Relaeses"
    usage; exit 1
  fi
  if [ -z ${MODE} ] && ( [ "$MODE" != "0" ] || [ "$MODE" != "1" ] ) ;then
    echo "Error: MODE is not passed as an argument"
    usage; exit 1
  fi     
}

set_property()
{      	
  DATE="${DATE}T01:08:52.054-05:00"
  URL="https://server:443/artifactory"
  property_list=($(jfrog rt s --user $username --password $pass --url $URL --sort-by "created" --sort-order "asc" folder_name/$FOLDER/*  | jq -r --arg DATE "$DATE" '.[] | select ((.created <= $DATE)) | .path' | grep ".ova"))
        
  for item in "${property_list[@]}"
    do      
      ovaname=$(echo "$item" | cut -d'/' -f4)
      #rc_check goes to the build dashboard and checks if the ova belongs to a RC build, if yes, it will be retained.
      rc_check=$(mysql -h "$BUILD_DASHBOARD_MYSQL" -u admin --password=$tool_PASSWORD -D folder_name_db -e "select rc_name from tool_ui_app_type_name where ovaname='$ovaname'" | grep -v rc_name)
      check_loc1=$(echo "$item" | grep "loc1")
      #check_loc1 will update url varaible accordingly either loc11 or loc2 based on path to the ova(folder_name-loc2 or folder_name-loc1)
      if [ ! -z "$check_loc1" ]; then
        URL="https://server:443/artifactory"
      else     
        URL="https://server:443/artifactory"
      fi
      if [ ! -z "$rc_check" ]; then 
        echo "Setting property deletion_status=false as RC build for $item"
        jfrog rt sp --user $username --password $pass --url "$URL" $item "deletion_status=false"
      else    
        echo "Setting property deletion_status=true for $item"
        jfrog rt sp --user $username --password $pass --url "$URL" $item "deletion_status=true"
      fi       
                	 
  done
        
  echo "Files marked for deletion are:"
  jfrog rt s --user $username --password $pass --props "deletion_status=true" --url $URL --sort-by "created" --sort-order "asc" folder_name/$FOLDER/* | jq -r --arg DATE "$DATE" '.[] | select ((.created <= $DATE)) | .path' | grep ova
  echo "Total free space after deletion will be"
  jfrog rt s --user $username --password $pass --props "deletion_status=true" --url $URL --sort-by "created" --sort-order "asc" folder_name/$FOLDER/* | jq -r --arg DATE "$DATE" '.[] | select ((.created <= $DATE)) | .size' | grep -v 'null' | awk -F '|' '{sum += $1} END {print sum}'

}

delete_artifacts()
{
        	
  DATE="${DATE}T01:08:52.054-05:00"
  echo "y" > sayyes.txt		 
  URL="https://server:443/artifactory"
  delete_list=($(jfrog rt s --user $username --password $pass  --props "deletion_status=true" --url $URL --sort-by "created" --sort-order "asc" folder_name/$FOLDER/*  | jq -r --arg DATE "$DATE" '.[] | select ((.created <= $DATE)) | .path'| grep ".ova"))
		
  for item in "${delete_list[@]}"
    do
      check_loc1=$(echo "$item" | grep "loc1")
      if [ ! -z "$check_loc1" ]; then
        URL="https://server:443/artifactory"
      else     
        URL="https://server:443/artifactory"
      fi     
      echo "Deleting $item from $URL"
      check_type_name=$(echo "$item" | cut -d'/' -f4 | grep "type_name")
      if [ ! -z "$check_type_name" ] ; then
      	mysql -h "$BUILD_DASHBOARD_MYSQL" -u admin --password=$tool_PASSWORD -D folder_name_db -e "update tool_ui_app_type_name set ova_deleted='Yes' where ovaname='$ovaname'"
      fi
      jfrog rt del --user $username --password $pass --url "$URL" $item 
  done
}

dry_run()

{
        
  DATE="${DATE}T01:08:52.054-05:00"
  URL="https://server:443/artifactory"
  property_list=($(jfrog rt s --user $username --password $pass --url $URL --sort-by "created" --sort-order "asc" folder_name/$FOLDER/*  | jq -r --arg DATE "$DATE" '.[] | select ((.created <= $DATE)) | .path' | grep ".ova"))
        
  for item in "${property_list[@]}"
    do      
      ovaname=$(echo "$item" | cut -d'/' -f4)
      #rc_check goes to the build dashboard and checks if the ova belongs to a RC build, if yes, it will be retained.
      rc_check=$(mysql -h "$BUILD_DASHBOARD_MYSQL" -u admin --password=$tool_PASSWORD -D folder_name_db -e "select rc_name from tool_ui_app_type_name where ovaname='$ovaname'" | grep -v rc_name)
      #check_loc1 will update url varaible accordingly either loc11 or loc2 based on path to the ova(folder_name-loc2 or folder_name-loc1)
      check_loc1=$(echo "$item" | grep "loc1")
      if [ ! -z "$check_loc1" ]; then
        URL="https://server:443/artifactory"
      else     
        URL="https://server:443/artifactory"
      fi
      if [ ! -z "$rc_check" ]; then 
        echo "Setting property deletion_status=false as RC build for $item"
        jfrog rt sp --user $username --password $pass --url "$URL" $item "deletion_status=false"
      else    
        echo "Setting property deletion_status=dry_run for $item"
        jfrog rt sp --user $username --password $pass --url "$URL" $item "deletion_status=dry_run"
      fi       
  done
  echo "Files marked with dry_run are:"
  jfrog rt s --user $username --password $pass --props "deletion_status=dry_run" --url $URL --sort-by "created" --sort-order "asc" folder_name/$FOLDER/* | jq -r --arg DATE "$DATE" '.[] | select ((.created <= $DATE)) | .path' | grep ova
  echo "Total free space after deletion will be"
  jfrog rt s --user $username --password $pass --props "deletion_status=dry_run" --url $URL --sort-by "created" --sort-order "asc" folder_name/$FOLDER/* | jq -r --arg DATE "$DATE" '.[] | select ((.created <= $DATE)) | .size' | grep -v 'null' | awk -F '|' '{sum += $1} END {print sum}'
  echo "Since it is dry run, reverting back the property to 'deletion_status=false'"
  property_list=($(jfrog rt s --user $username --password $pass --props "deletion_status=dry_run" --url $URL --sort-by "created" --sort-order "asc" folder_name/$FOLDER/* | jq -r --arg DATE "$DATE" '.[] | select ((.created <= $DATE)) | .path' | grep ova))
  for item in "${property_list[@]}"
    do 
      check_loc1=$(echo "$item" | grep "loc1")
      if [ ! -z "$check_loc1" ]; then
        URL="https://server:443/artifactory"
      else     
        URL="https://server:443/artifactory"
      fi
      echo "Setting property deletion_status=false as RC build for $item"
      jfrog rt sp --user $username --password $pass --url "$URL" $item "deletion_status=false"
  done

}

while getopts "u:p:d:f:m:h" option; do
  case $option in
    h) usage && exit ;;
    u) username=$OPTARG ;;
    p) pass=$OPTARG ;;
    d) DATE=$OPTARG ;;
    f) FOLDER=$OPTARG ;;
    m) MODE=$OPTARG ;;
    ?) echo -e "${RED}ERROR : option -$OPTARG is not implemented ${NOCOLOR}"; usage; exit 1 ;;
  esac
done
echo "Running validate script function..."
validate_script
if [ "$MODE" == "1" ]; then
   echo "Running setting property function..."
   set_property
   echo "Running deleting artifactory function..."
   delete_artifacts
else
   echo "Running dry run function to list files which will be cleaned up..."
   dry_run
fi   
