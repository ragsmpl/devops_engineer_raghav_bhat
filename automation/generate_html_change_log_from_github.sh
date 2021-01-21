##################################################################################################################
################# This script generates release notes for the prod_name builds #########################################
##################################################################################################################
#!/bin/bash

#pass username and passwored to the script

user_name=$1
user_pass=$2
BUILD_DASHBOARD_MYSQL=$3
tool_pass=$4
BRANCH=$5

oldbuildname=$(mysql -h "$BUILD_DASHBOARD_MYSQL" -u admin --password=$tool_pass -D db_name -e "select ovaname  from table_name where build_status='PASSED' AND branch_name='$BRANCH' ORDER BY SLNO DESC LIMIT 2" | grep prod_name | tail -1 )

newbuildname=$(mysql -h "$BUILD_DASHBOARD_MYSQL" -u admin --password=$tool_pass -D db_name -e "select ovaname  from table_name where build_status='PASSED' AND branch_name='$BRANCH' ORDER BY SLNO DESC LIMIT 2" | grep prod_name | head -1 )
oldmanifest=$(mysql -h "$BUILD_DASHBOARD_MYSQL" -u admin --password=$tool_pass -D db_name -e "select manifest_commit from table_name where ovaname='$oldbuildname'" | grep -v manifest_commit | tail -1 )
newmanifest=$(mysql -h "$BUILD_DASHBOARD_MYSQL" -u admin --password=$tool_pass -D db_name -e "select manifest_commit from table_name where ovaname='$newbuildname'" | grep -v manifest_commit | tail -1 )
exclude_commitsha_old=$(echo "$oldbuildname" | grep -E -o "(-[a-z0-9]{8,10})")
if [ -z "$exclude_commitsha_old" ]; then
        oldbuildnumber=$(echo $oldbuildname | rev | cut -d'-' -f2,3,4,5 | rev)
    else
        oldbuildnumber=$(echo $oldbuildname | rev | cut -d'-' -f3,4,5,6 | rev)      
fi 

exclude_commitsha_new=$(echo "$newbuildname" | grep -E -o "(-[a-z0-9]{8,10})")
if [ -z "$exclude_commitsha_new" ]; then
        newbuildnumber=$(echo $newbuildname | rev | cut -d'-' -f2,3,4,5 | rev)
    else
        newbuildnumber=$(echo $newbuildname | rev | cut -d'-' -f3,4,5,6 | rev)
fi 
echo "old build number: $oldbuildname"
echo "new bild number: $newbuildname"
echo "old manifest: $oldmanifest"
echo "new manifest: $newmanifest"
echo "old prod_name: $oldbuildnumber"
echo "new prod_name: $newbuildnumber"
build_name_in_commitinfo=$(mysql -h "$BUILD_DASHBOARD_MYSQL" -u admin --password=$tool_pass -D db_name -e "select build_name from tool_name_ui_app_commit_info where build_name = '$newbuildnumber'"| tail -1 )
#this removes ".ova" from ova name and it will be appended with .html at latest stage.
filename=$(echo $newbuildname | cut -d'/' -f2 | cut -d'.' -f2,1,3)

#This is needed to create table of commits for services repo. 
service_repo_mapping="repo1:repo_one"
service_repo_normal="repo1,repo2"

#This gets username to checkout the repos from git
git config --global user.name $user_name
git config --global user.email "user_name@email"
git config --global http.sslVerify false
#save the username and password for git
echo "machine githubserver login $user_name password $user_pass" > ~/.netrc
git config --global credential.helper cache
#this is the directory where all the repos will be cloned
export script_dir=$(pwd)
#tmp location where release notes and tmp.txt  created
mkdir tmp
mkdir repos
#This creates css code to construct table in the html page.
echo "<html>" >$script_dir/tmp/$filename.html
echo "<head>" >>$script_dir/tmp/$filename.html
echo "<style>" >>$script_dir/tmp/$filename.html
echo "#table_class {">>$script_dir/tmp/$filename.html
echo "font-prod_nameily: "Trebuchet MS", Arial, Helvetica, sans-serif;">>$script_dir/tmp/$filename.html
echo "border-collapse: collapse;">>$script_dir/tmp/$filename.html
echo "width: 100%;" >>$script_dir/tmp/$filename.html
echo "}" >>$script_dir/tmp/$filename.html
echo "#table_class td, #table_class th {">>$script_dir/tmp/$filename.html
echo " border: 1px solid #ddd; " >>$script_dir/tmp/$filename.html
echo " padding: 8px; " >>$script_dir/tmp/$filename.html
echo "}" >>$script_dir/tmp/$filename.html
echo "#table_class tr:nth-child(even){background-color: #f2f2f2;} " >>$script_dir/tmp/$filename.html
echo "#table_class tr:hover {background-color: #ddd;} " >>$script_dir/tmp/$filename.html
echo "#table_class th { " >>$script_dir/tmp/$filename.html
echo "padding-top: 12px; " >>$script_dir/tmp/$filename.html
echo "padding-bottom: 12px;" >>$script_dir/tmp/$filename.html
echo "text-align: left; " >>$script_dir/tmp/$filename.html
echo "background-color: #4CAF50;">>$script_dir/tmp/$filename.html
echo "color: white;" >>$script_dir/tmp/$filename.html
echo "}" >>$script_dir/tmp/$filename.html
echo "</style>">>$script_dir/tmp/$filename.html
echo "</head>" >>$script_dir/tmp/$filename.html
echo "<body>" >>$script_dir/tmp/$filename.html
echo "<div style=\"border: 6px solid #4CAF50;background-color: lightgrey;\">" >>$script_dir/tmp/$filename.html
#creating file which will hold non project version info, to ensure they appear at the end of release notes.
echo "<center><h1>Change Log for prod_name $newbuild</h1></center>" >>$script_dir/tmp/$filename.html
echo "<center><h1>BRANCH <b>$BRANCH</b></h1></center>" >>$script_dir/tmp/$filename.html
echo "<center><p>This change log has been generated between $oldbuildnumber and $newbuildnumber </p1></center>">>$script_dir/tmp/$filename.html
echo "</br>" >>$script_dir/tmp/$filename.html
echo "</div>" >>$script_dir/tmp/$filename.html
echo "<h2>1. Changes in the services version </h2>" >$script_dir/tmp/changelog3.html
echo "<table id=\"table_class\">" >>$script_dir/tmp/changelog3.html
echo "<tr> <th>Name of the Service </th><th>OLD VERSION</th><th>NEW VERSION</th> </tr>" >>$script_dir/tmp/changelog3.html

cd repos
#clone repo_maker and generate diff of manifest file content between two commits.
git clone https://githubserver/project/repo_maker
cd repo_maker
git checkout $BRANCH
#tmp.txt will be used as the base for the git repo based changelog content
echo "git diff $oldmanifest..$newmanifest manifest.yml >$script_dir/tmp/tmp.txt"
git diff $oldmanifest..$newmanifest manifest.yml >$script_dir/tmp/tmp.txt

#tmp2.txt will be used to generate services repo based changelog content
echo "git diff $oldmanifest..$newmanifest manifest_services.yml >$script_dir/tmp/tmp2.txt"
git diff $oldmanifest..$newmanifest manifest_services.yml >$script_dir/tmp/tmp2.txt

#This will prepare a list with all the values infront of "-name"
repos=$(grep "\-[[:space:]]*name" -i $script_dir/tmp/tmp.txt | cut -d':' -f 2)
echo "<fieldset>">>$script_dir/tmp/$filename.html
echo "<legend><font size=\"3\"><b>Contents</b></font></legend>">>$script_dir/tmp/$filename.html
echo "<h2>I. project git archive changes </h2>">>$script_dir/tmp/$filename.html
count=0


for repo in $repos
  do
    validate_repo=$(awk '/name: '$repo'/{x = NR + 1}NR == x' $script_dir/tmp/tmp.txt | grep '\/git-archive\/')
    
    if [ ! -z "$validate_repo" ]
    then

        add_or_delete_repo_verify1=$(awk '/name: '$repo'/{x = NR + 1}NR == x' $script_dir/tmp/tmp.txt | grep "^-")
        add_or_delete_repo_verify2=$(awk '/name: '$repo'/{x = NR + 1}NR == x' $script_dir/tmp/tmp.txt | grep "^+")
        if [ ! -z "$add_or_delete_repo_verify1" ] || [ ! -z "$add_or_delete_repo_verify2" ]; then
          count=$(expr $count + 1)
          echo "&nbsp;&nbsp;<a href=\"#div_$repo\">$count. $repo </a>">>$script_dir/tmp/$filename.html
          echo "</br>">>$script_dir/tmp/$filename.html
        fi  
    fi
done  
if [ $count -eq 0 ]; then
   echo "No new changes in project git archives">>$script_dir/tmp/$filename.html
fi

echo "<h2>II. Build system changes </h2>">>$script_dir/tmp/$filename.html
echo "&nbsp;&nbsp;<a href=\"#div_prod_name_image_maker\">1. type1 </a>">>$script_dir/tmp/$filename.html
echo "<h2>III. Others </h2>">>$script_dir/tmp/$filename.html
echo "&nbsp;&nbsp;<a href=\"#div_project_services\">1. typ2 </a>">>$script_dir/tmp/$filename.html
echo "</br>">>$script_dir/tmp/$filename.html
echo "&nbsp;&nbsp;<a href=\"#div_rest\">2. type3 </a>">>$script_dir/tmp/$filename.html
echo "</fieldset>">>$script_dir/tmp/$filename.html

#This will create a list of all the services repo names present in tmp2.txt
repos_svc=$(grep "\-[[:space:]]*name" -i $script_dir/tmp/tmp2.txt | grep -v "\-[[:blank:]]*\-[[:blank:]]*name" | cut -d':' -f2 | cut -d'/' -f2)
#This will check if there are service repo changes. If not , it will add below content.
if [ -z "$repos_svc" ]; then
  echo "<tr><td>No Changes</td>" >>$script_dir/tmp/changelog3.html
  echo "<td>No Changes</td>" >>$script_dir/tmp/changelog3.html
  echo "<td>No Changes</td></tr>" >>$script_dir/tmp/changelog3.html
fi
#This creates a list of service repos which are deleted.
repos_deleted=$(grep "\-[[:blank:]]*\-[[:blank:]]*name" -i $script_dir/tmp/tmp2.txt | cut -d':' -f2 | cut -d'/' -f2)
echo "<div id=\"div_project_services\">">>$script_dir/tmp/changelog3.html

#for each repo it creates table commits detail like date/commit id/title of the commit. Also it will have hypder link to the services table with 
#commit details.
for rep in $repos_svc
do 
  oldversion=$(awk '/'$rep'/{x = NR + 2}NR == x' $script_dir/tmp/tmp2.txt | cut -d':' -f2)
  newversion=$(awk '/'$rep'/{x = NR + 3}NR == x' $script_dir/tmp/tmp2.txt | cut -d':' -f2) 
  add_Service=$(awk '/'$rep'/{x = NR + 3}NR == x' $script_dir/tmp/tmp2.txt | grep "tag")
    if [ -z "$add_Service" ]; then
      added_service=$(echo $(awk '/'$rep'/{x = NR + 2}NR == x' $script_dir/tmp/tmp2.txt) | grep "\+[[:blank:]]*tag")
        if [ ! -z "$added_service" ]; then
          echo "<tr><td>$rep</td>" >>$script_dir/tmp/changelog3.html
          echo "<td>NA</td>" >>$script_dir/tmp/changelog3.html
          echo "<td>$oldversion</td></tr>" >>$script_dir/tmp/changelog3.html
        fi        
    else
        repo_mapping=$(echo $service_repo_mapping | sed 's/,/\n/g' | grep "$rep")
        repo_mapping_normal=$(echo $service_repo_normal | sed 's/,/\n/g' | grep "$rep")
        if [ ! -z "$repo_mapping" ]; then
        svc_repo_name=$(echo $repo_mapping | cut -d':' -f2)
        elif [ ! -z "$repo_mapping_normal" ]; then
           
           svc_repo_name=$(echo $rep)
        else
           svc_repo_name=""
        fi

      if [ ! -z "$svc_repo_name" ]; then 
      cd $script_dir/repos
      git clone https://githubserver/project/$svc_repo_name
      cd $svc_repo_name
      git checkout $BRANCH
      echo $pwd
      #this will get the commitid from ova file
      exclude_commitsha_old_svc=$(echo "$oldversion" | grep -E -o "(-[a-z0-9]{8,10})")
      if [ ! -z "$exclude_commitsha_old_svc" ]; then
         oldversion_trimmed=$(echo $exclude_commitsha_old_svc | cut -d'-' -f2)
         oldversion_final=$(echo ${oldversion_trimmed:1} | sed -e 's@_@-@g')
      else   
         oldversion_final=$(echo $oldversion)
      fi 

      exclude_commitsha_new_svc=$(echo "$newversion" | grep -E -o "(-[a-z0-9]{8,10})")
      if [ ! -z "$exclude_commitsha_new_svc" ]; then
         newversion_trimmed=$(echo $exclude_commitsha_new_svc | cut -d'-' -f2)
         newversion_final=$(echo ${newversion_trimmed:1} | sed -e 's@_@-@g')
      else   
         newversion_final=$(echo $newversion | cut -d'-' -f2)
      fi   
      #this will remove "g" from commit id.
      
      newversion_final=$(echo ${newversion_trimmed:1} | sed -e 's@_@-@g')
      #this will create the table with services repo commit detail table.
      echo "<h3>$svc_repo_name</h3>" >>$script_dir/tmp/changelog4.html
      echo "<div id=\"div_$svc_repo_name\">">>$script_dir/tmp/changelog4.html
      echo "<table id=\"table_class\">" >>$script_dir/tmp/changelog4.html
    echo "<tr> <th>COMMIT ID </th><th>AUTHOR</th><th>DATE</th><th>TITLE</th> </tr>" >>$script_dir/tmp/changelog4.html

      git log --pretty=format:"%h|%an|%s|%aD" $(echo $oldversion_final | sed -e 's@_@-@g')..$(echo $newversion_final | sed -e 's@_@-@g') >log.txt
      echo "================================================"
      echo "" >>log.txt
      this_path=$(pwd)
      input="$this_path"/log.txt
      
            while IFS= read -r line
            do
                echo "$line"
                commit_id=$(echo $line | cut -d'|' -f1)
    author_name=$(echo $line | cut -d'|' -f2 | sed "s/'/^/g")
    title=$(echo $line | cut -d'|' -f3 | sed "s/'/^/g")
    commitdate=$(echo $line | cut -d'|' -f4)

    
    echo "<tr><td>$commit_id</td>" >>$script_dir/tmp/changelog4.html
    echo "<td>$author_name</td>" >>$script_dir/tmp/changelog4.html
    echo "<td>$commitdate</td>" >>$script_dir/tmp/changelog4.html
    echo "<td>$title</td></tr>" >>$script_dir/tmp/changelog4.html
    #this creates an entry int he dashboard where search option can be used to get commit details.
    if [ -z "$build_name_in_commitinfo" ]; then 
        mysql -h "$BUILD_DASHBOARD_MYSQL" -u admin --password=$tool_pass -D db_name -e "insert into tool_name_ui_app_commit_info (commitid,commitdate,Author,title,build_name,repo_name,branch) VALUES ('$commit_id', '$commitdate','$author_name','$title','$newbuildnumber','$svc_repo_name','$BRANCH') ;"           
    else
        echo "No entry made into the DataBase for this changelog creation, as $newbuildnumber already found in the table"
    fi     
            done < "$input"
    echo "<tr><td><a href=\"#div_$svc_repo_name\">$rep </a></td>" >>$script_dir/tmp/changelog3.html
    echo "<td>$oldversion</td>" >>$script_dir/tmp/changelog3.html
    echo "<td>$newversion</td></tr>" >>$script_dir/tmp/changelog3.html
    else       
    echo "<tr><td>$rep</td>" >>$script_dir/tmp/changelog3.html
    echo "<td>$oldversion</td>" >>$script_dir/tmp/changelog3.html
    echo "<td>$newversion</td></tr>" >>$script_dir/tmp/changelog3.html
    fi 
    fi 
    echo "</table>" >>$script_dir/tmp/changelog4.html
    echo "</div>" >>$script_dir/tmp/changelog4.html 
done

for rep in $repos_deleted
do 
    echo $rep
  delete_Service=$(cat $script_dir/tmp/tmp2.txt | grep "$rep" | wc -l)
  echo "$(awk '/'"$rep"'/{x = NR + 1}NR == x' $script_dir/tmp/tmp2.txt)"
    if [ $delete_Service -lt 2 ]; then
      deleted_service2=$(echo $(awk '/'"$rep"'/{x = NR + 2}NR == x' $script_dir/tmp/tmp2.txt) | grep "\-[[:blank:]]*tag")
        if [ ! -z "$deleted_service2" ]; then
          echo "<tr><td>$rep</td>" >>$script_dir/tmp/changelog3.html
            echo "<td>Deleted</td>" >>$script_dir/tmp/changelog3.html
            echo "<td>NA</td></tr>" >>$script_dir/tmp/changelog3.html
           
    fi   
   fi          
done
echo "</table>" >>$script_dir/tmp/changelog3.html
echo "<div/>">>$script_dir/tmp/changelog3.html
echo "<font color=\"blue\"><h2>I. project git archive changes </h2></font>">>$script_dir/tmp/$filename.html

#this step will get all the repos which has been modified in the manifest file
count2=0
for rep in $repos
do
    
    #only repos which has git-archives will be considered to generate release notes in this section
    validate_repo=$(awk '/name: '$rep'/{x = NR + 1}NR == x' $script_dir/tmp/tmp.txt | grep '\/git-archive\/')
   
    if [ ! -z "$validate_repo" ]
    then
      
    add_or_delete_repo_verify1=$(awk '/name: '$rep'/{x = NR + 1}NR == x' $script_dir/tmp/tmp.txt | grep "^-")
    add_or_delete_repo_verify2=$(awk '/name: '$rep'/{x = NR + 1}NR == x' $script_dir/tmp/tmp.txt | grep "^+")
    add_or_delete_repo_verify3=$(awk '/name: '$rep'/{x = NR + 2}NR == x' $script_dir/tmp/tmp.txt | grep "^+")
    add_or_delete_repo_verify4=$(awk '/name: '$rep'/{x = NR + 2}NR == x' $script_dir/tmp/tmp.txt | grep "^+" | grep "type: git-archive")
    add_or_delete_repo_verify5=$(awk '/name: '$rep'/{x = NR + 2}NR == x' $script_dir/tmp/tmp.txt | grep "^-" | grep "type: git-archive") 
    if [ ! -z "$add_or_delete_repo_verify1" ] || [ ! -z "$add_or_delete_repo_verify2" ]; then
    count2=$(expr $count2 + 1)
    echo "<div id=\"div_$rep\">">>$script_dir/tmp/$filename.html
    #to handle case where either new repo has been added or deleted in the manifest file
  
    if [ ! -z "$add_or_delete_repo_verify1" ] && [ ! -z "$add_or_delete_repo_verify3" ]; then
      #oldversiona and new version variable will be used to generate the changelog for old build and new build.  
      oldversion=$(awk '/name: '$rep'/{x = NR + 1}NR == x' $script_dir/tmp/tmp.txt | rev | cut -d'/' -f1 | rev | sed "s/$rep-//" | rev | cut -d'.' -f3,4,5,6,7 | rev )
 
      newversion=$(awk '/name: '$rep'/{x = NR + 2}NR == x' $script_dir/tmp/tmp.txt | rev | cut -d'/' -f1 | rev | sed "s/$rep-//" | rev | cut -d'.' -f3,4,5,6,7 | rev )
      cd $script_dir/repos
      git clone https://githubserver/project/$rep
      cd $rep
      git checkout $BRANCH
      #below code cretes the table heading
      echo "</br>" >>$script_dir/tmp/$filename.html
            echo "<h3>$count2. $rep</h3>" >>$script_dir/tmp/$filename.html
            echo "</br>" >>$script_dir/tmp/$filename.html
            echo "<table id=\"table_class\">" >>$script_dir/tmp/$filename.html
            echo "<tr> <th>COMMIT ID </th><th>AUTHOR</th><th>DATE</th><th>TITLE</th> </tr>" >>$script_dir/tmp/$filename.html

      echo $rep
      echo "================================================"
      #var is being generated to check if its not added or deleted repo. if git show comes back without any error, then only it will be used to generate
      #the changelog. Else it will result in error.
      
      exclude_commitsha_old_rep=$(echo "$oldversion" | grep -E -o "(-[a-z0-9]{8,10})")
      if [ ! -z "$exclude_commitsha_old_rep" ]; then
         oldversion_trimmed=$(echo $exclude_commitsha_old_rep | cut -d'-' -f2)
         oldversion_final=$(echo ${oldversion_trimmed:1} | sed -e 's@_@-@g')
      else   
         oldversion_final=$(echo $oldversion)
      fi

      exclude_commitsha_new_rep=$(echo "$newversion" | grep -E -o "(-[a-z0-9]{8,10})")
      if [ ! -z "$exclude_commitsha_new_rep" ]; then
         newversion_trimmed=$(echo $exclude_commitsha_new_rep | cut -d'-' -f2)
         newversion_final=$(echo ${newversion_trimmed:1} | sed -e 's@_@-@g')
      else   
         newversion_final=$(echo $newversion)
      fi


      git log --pretty=format:"%h|%an|%s|%aD" $(echo $oldversion_final | sed -e 's@_@-@g')..$(echo $newversion_final | sed -e 's@_@-@g')  >log.txt
      echo "================================================"
      echo "" >>log.txt
      this_path=$(pwd)
      input="$this_path"/log.txt
         while IFS= read -r line
            do   
                #This will generate the table with commit information
                echo "$line"
                commit_id=$(echo $line | cut -d'|' -f1)
                author_name=$(echo $line | cut -d'|' -f2 | sed "s/'/^/g")
                title=$(echo $line | cut -d'|' -f3 | sed "s/'/^/g")
                commitdate=$(echo $line | cut -d'|' -f4)
                echo "<tr><td>$commit_id</td>" >>$script_dir/tmp/$filename.html
                echo "<td>$author_name</td>" >>$script_dir/tmp/$filename.html
                echo "<td>$commitdate</td>" >>$script_dir/tmp/$filename.html
                echo "<td>$title</td></tr>" >>$script_dir/tmp/$filename.html
                #this creates an entry int he dashboard where search option can be used to get commit details.
                if [ -z "$build_name_in_commitinfo" ]; then 
                   mysql -h "$BUILD_DASHBOARD_MYSQL" -u admin --password=$tool_pass -D db_name -e "insert into tool_name_ui_app_commit_info (commitid,commitdate,Author,title,build_name,repo_name,branch) VALUES ('$commit_id', '$commitdate','$author_name','$title','$newbuildnumber','$rep','$BRANCH') ;"           
                else
                   echo "No entry made into the DataBase for this changelog creation, as $newbuildnumber already found in the table"
                fi 
            done < "$input"
      
      elif [ ! -z "$add_or_delete_repo_verify2" ] && [ ! -z "$add_or_delete_repo_verify4" ]; then
      cd $script_dir/repos
      git clone https://githubserver/project/$rep
      cd $rep
      git checkout $BRANCH
      echo "<h3>$count2. $rep</h3>" >>$script_dir/tmp/$filename.html
      echo "</br>" >>$script_dir/tmp/$filename.html
      echo "$rep [WARNING: This is newly added repo in the manifest, hence latest 5 commits have been shown below]" >>$script_dir/tmp/$filename.html
            echo "</br>" >>$script_dir/tmp/$filename.html
            echo "<table id=\"table_class\">" >>$script_dir/tmp/$filename.html
            echo "<tr> <th>COMMIT ID </th><th>AUTHOR</th><th>Date</th><th>TITLE</th> </tr>" >>$script_dir/tmp/$filename.html
            
      git log -n 5 --pretty=format:"%h|%an|%s|%aD">log.txt
      echo "" >>log.txt
      this_path=$(pwd)
      input="$this_path"/log.txt
            while IFS= read -r line
            do
     #This will generate the table with commit information
    commit_id=$(echo $line | cut -d'|' -f1)
    author_name=$(echo $line | cut -d'|' -f2 | sed "s/'/^/g")
    title=$(echo $line | cut -d'|' -f3 | sed "s/'/^/g")
    commitdate=$(echo $line | cut -d'|' -f4)
    echo "<tr><td>$commit_id</td>" >>$script_dir/tmp/$filename.html
    echo "<td>$author_name</td>" >>$script_dir/tmp/$filename.html
    echo "<td>$commitdate</td>" >>$script_dir/tmp/$filename.html
    echo "<td>$title</td></tr>" >>$script_dir/tmp/$filename.html
    #this creates an entry int he dashboard where search option can be used to get commit details.
    if [ -z "$build_name_in_commitinfo" ]; then 
       mysql -h "$BUILD_DASHBOARD_MYSQL" -u admin --password=$tool_pass -D db_name -e "insert into tool_name_ui_app_commit_info (commitid,commitdate,Author,title,build_name,repo_name,branch) VALUES ('$commit_id', '$commitdate','$author_name','$title','$newbuildnumber','$rep','$BRANCH') ;"           
    else
       echo "No entry made into the DataBase for this changelog creation, as $newbuildnumber already found in the table"
    fi
            done < "$input"
      elif [ ! -z "$add_or_delete_repo_verify1" ] && [ ! -z "$add_or_delete_repo_verify5" ]; then
      cd $script_dir/repos
      git clone https://githubserver/project/$rep
      cd $rep
      git checkout $BRANCH
      echo "<h3>$count2. $rep</h3>" >>$script_dir/tmp/$filename.html
      echo "</br>" >>$script_dir/tmp/$filename.html
      echo "$rep [WARNING: This repo has been deleted]" >>$script_dir/tmp/$filename.html
            echo "</br>" >>$script_dir/tmp/$filename.html
    
        echo "</div>" >>$script_dir/tmp/$filename.html
      fi 
      fi 
  else

    
        validate_added=$(awk '/name: '$rep'/{x = NR}NR == x' $script_dir/tmp/tmp.txt | grep "^+")
        validate_deleted=$(awk '/name: '$rep'/{x = NR}NR == x' $script_dir/tmp/tmp.txt | grep "^-")
        new=$(awk '/name: '$rep'/{x = NR + 1}NR == x' $script_dir/tmp/tmp.txt | cut -d':' -f 2,3)
        if [ ! -z "$validate_added" ]; then
          echo "<tr><td>$rep</td>" >>$script_dir/tmp/changelog2.html
          echo "<td>NA</td>" >>$script_dir/tmp/changelog2.html
          echo "<td>$new</td></tr>" >>$script_dir/tmp/changelog2.html
        elif [ ! -z "$validate_deleted" ]; then
          echo "<tr><td>$rep</td>" >>$script_dir/tmp/changelog2.html
          echo "<td>$new</td>" >>$script_dir/tmp/changelog2.html
          echo "<td>NA</td></tr>" >>$script_dir/tmp/changelog2.html
        fi        
    fi   
    echo "</table>" >>$script_dir/tmp/$filename.html
done

if [ $count2 -eq 0 ]; then
   echo "No new changes in project git archives">>$script_dir/tmp/$filename.html
fi

#This section will generate the commit info for repo_maker
cd $script_dir/repos/repo_maker
echo "<font color=\"blue\"><h2>II. Build system changes </h2></font>">>$script_dir/tmp/$filename.html
echo "<div id=\"div_prod_name_image_maker\">">>$script_dir/tmp/$filename.html
echo "<h3>1. prod_name_image_maker </h3>">>$script_dir/tmp/$filename.html
echo "<table id=\"table_class\">" >>$script_dir/tmp/$filename.html
echo "<tr> <th>COMMIT ID </th><th>AUTHOR</th><th>DATE</th><th>TITLE</th> </tr>" >>$script_dir/tmp/$filename.html
git log --pretty=format:"%h|%an|%s|%aD" $(echo $oldmanifest | sed -e 's@_@-@g')..$(echo $newmanifest | sed -e 's@_@-@g') | grep -v 'Merge pull request' >log.txt

this_path=$(pwd)
input="$this_path"/log.txt
  while IFS= read -r line
    do
    echo $line
    commit_id=$(echo $line | cut -d'|' -f1)
    author_name=$(echo $line | cut -d'|' -f2 | sed "s/'/^/g")
    title=$(echo $line | cut -d'|' -f3 | sed "s/'/^/g")
    commitdate=$(echo $line | cut -d'|' -f4)
    echo "<tr><td>$commit_id</td>" >>$script_dir/tmp/$filename.html
    echo "<td>$author_name</td>" >>$script_dir/tmp/$filename.html
    echo "<td>$commitdate</td>" >>$script_dir/tmp/$filename.html
    echo "<td>$title</td></tr>" >>$script_dir/tmp/$filename.html
    #this creates an entry int he dashboard where search option can be used to get commit details.
    if [ -z "$build_name_in_commitinfo" ]; then 
       mysql -h "$BUILD_DASHBOARD_MYSQL" -u admin --password=$tool_pass -D db_name -e "insert into tool_name_ui_app_commit_info (commitid,commitdate,Author,title,build_name,repo_name,branch) VALUES ('$commit_id', '$commitdate','$author_name','$title','$newbuildnumber','$rep','$BRANCH') ;"           
    else
       echo "No entry made into the DataBase for this changelog creation, as $newbuildnumber already found in the table"
    fi
  done < "$input"

echo "</table>" >>$script_dir/tmp/$filename.html

#cleaning up files which are no more needed.
echo "<font color=\"blue\"><h2>III. Others</h2></font>">>$script_dir/tmp/$filename.html
#combine all the changelog files. $filename.html is the main base file. changelog2 will have firmware related tables. changelog3 and changelog 4 will
#have services repo related main table and detailed table respectively.
cat $script_dir/tmp/changelog3.html >>$script_dir/tmp/$filename.html
cat $script_dir/tmp/changelog4.html >>$script_dir/tmp/$filename.html
if [ -f $script_dir/tmp/changelog2.html ]; then
  echo "<h2>2. type3 </h2>" >>$script_dir/tmp/$filename.html
  echo "</br>" >>$script_dir/tmp/$filename.html
  echo "<table id=\"table_class\">" >>$script_dir/tmp/$filename.html
  echo "<div id=\"div_rest\">">>$script_dir/tmp/$filename.html
  echo "<tr> <th>Name of the File </th><th>OLD VERSION</th><th>NEW VERSION</th> </tr>" >>$script_dir/tmp/$filename.html
  cat $script_dir/tmp/changelog2.html >>$script_dir/tmp/$filename.html
  echo "<div/>">>$script_dir/tmp/$filename.html
else
  echo "<h2>2type3 </h2>" >>$script_dir/tmp/$filename.html
  echo "</br>" >>$script_dir/tmp/$filename.html
  echo "<table id=\"table_class\">" >>$script_dir/tmp/$filename.html
  echo "<div id=\"div_rest\">">>$script_dir/tmp/$filename.html
  echo "<tr> <th>Name of the File </th><th>OLD VERSION</th><th>NEW VERSION</th> </tr>" >>$script_dir/tmp/$filename.html
  echo "<tr> <td>No Changes</td><td>No Changes</td><td>No Changes</td> </tr>" >>$script_dir/tmp/$filename.html
  echo "<div/>">>$script_dir/tmp/$filename.html
  
fi
mysql -h "$BUILD_DASHBOARD_MYSQL" -u admin --password=$tool_pass -D db_name -ee "UPDATE tool_name_ui_app_commit_info SET title = REPLACE(title,'^','\'');"
mysql -h "$BUILD_DASHBOARD_MYSQL" -u admin --password=$tool_pass -D db_name -e 'DELETE from  tool_name_ui_app_commit_info where commitid = "";'
#push the changelog into the artifactory
#push the changelog into the artifactory
curl -k -u $user_name:$ARTIFACTORY_TOKEN -X PUT https://path/ -T $script_dir/tmp/$filename.html
