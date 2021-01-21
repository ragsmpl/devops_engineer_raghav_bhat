#!/bin/bash
# check if hub is found, if not download it from Artifactory
export TMPDIR=$(pwd)
command -v hub > /dev/null 2>&1
if [[ "${?}" -ne 0 ]]
then
   echo 'hub not found... Downloading' 
   echo 'you will be asked gitusename and gitpassword one time for this system'
   cd /usr/bin/server/artifactory/org/team/hub
   chmod +x hub
   git config --global --add hub.host githubserver.com
   git config --global hub.protocol https
fi
RED="\033[1;31m"
NOCOLOR="\033[0m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
cd $TMPDIR
echo "This script will auto create PRs from 'FROM_BRANCH[HEAD]' branch to 'TO_BRANCH[BASE]' branch for all org repos"
read -r -p "Enter the FROM_BRANCH[HEAD] branch name: " response
FROM_BRANCH=$(echo "$response")
read -r -p "Enter the TO_BRANCH[BASE] branch name: " response
TO_BRANCH=$(echo "$response")
read -r -p "Enter the git USERNAME: " response
USERNAME=$(echo "$response")
read -r -p "Enter git token for username $USERNAME [Example:xxx...]: " response
TOKEN=$(echo "$response")
read -r -p "Enter the git password: " response
GITPASSWORD=$(echo "$response")
read -r -p "Enter the org email ID: " response
EMAILID=$(echo "$response")
read -r -p "Enter JIRA ID to be used in PR title[Example:123]: " response
JIRAID=$(echo "$response")
echo "~~~~~~~~~~~~~~~~~~~~~"	
echo " SELECT ACTION"
echo "~~~~~~~~~~~~~~~~~~~~~"
echo "1. DRY RUN"
echo "2. MERGE"
echo "3. Merge To release-1.x branch"
echo "4. To quit"

read -p "Enter your choice: " response
case $response in
        "1")  
            ACTION="dryrun"
            echo "You have selected 'dryrun'"
            ;;
        "2")
	    ACTION="merge"
            echo "You have selected 'merge'"
            ;;
        "3")
	    ACTION="merge_to_release_branch"
	    echo "You have selected merge to release-1.x branch"
	    ;;
        "4")
            echo "You have selected 'quit'"
            exit 0
            ;;
        *) echo "invalid option $response"
           exit 0;;
esac
  
#Define variables
T_DIR=$(mktemp -d)
cd $T_DIR
touch $T_DIR/conflicts.txt
touch $T_DIR/conflicts_details.txt
touch $T_DIR/auto_pr.txt
##################################################################
git config --global user.name "$USERNAME"
git config --global user.email "$EMAILID"
#save the username and password for git
sudo echo "machine githubserver.com login $USERNAME password $GITPASSWORD" > ~/.netrc
git config --global credential.helper cache

check_token=$(curl -s -H "Authorization: token $TOKEN" https://api.githubserver.com/orgs/org/repos\?per_page\=200  | grep "Bad credentials")
if [ ! -z "$check_token" ]; then
   echo -e "${RED} please update the token, looks like TOKEN not working  ${NOCOLOR}"
   exit 1
fi  
echo "~~~~~~~~~~~~~~~~~~~~~"	
echo " SELECT MERGE MODE"
echo "~~~~~~~~~~~~~~~~~~~~~"
echo "1. update all repos"
echo "2. update test repos"
echo "3. update specific repos"
echo "4. to quit"

read -p "Enter your choice: " response
case $response in
        "1")
            REPOGROUP="all"
            echo "You have selected 'update all repos'"
            ;;
        "2")
            REPOGROUP="test"
            echo "You have selected 'update test repos'"
            ;;
	"3")
            REPOGROUP="specific"
            echo "You have selected 'update specific repos'"
            ;;
			
        "4")
            echo "You have selected 'quit'"
            exit 0
            ;;
        *) echo "invalid option $response"
           exit 0;;
esac

echo "INFO : REPO GROUP            - $REPOGROUP"
read -r -p "Are you sure you want to continue? [y/n] " response
if [[ ! $response =~ ^([yY])$ ]]
then
    exit 0
fi


# Dryrun or merge will be performed on test branches
REPOS_TEST=("go-service")

# These branches will be ignored for Drayrun or Merge
REPOS_IGNORE=("devenv")
IGNORE_CONFLICT="NO"
if [[ $REPOGROUP =~ ^test$ ]]
then
   repos=("${REPOS_TEST[@]}") 
   echo "Selected repo $repos"
elif [[ $REPOGROUP =~ ^specific$ ]]
then
   read -r -p "Enter the repo name[Only one repo name example: cam-logging-service]: " response
   repo_name=$(echo "$response")
   REPOS_SPECIFIC=("$repo_name")
   repos=("${REPOS_SPECIFIC[@]}") 
   echo "Selected repo $repos" 
   echo ""
   echo "You have an option to enable INGORE CONFLICTS FLAG.If you select "y", during merge, list of files with conflict will be displayed and you can ingore them and go ahead with auto merge"
   read -r -p "ENABLE IGNORE CONFLICTS FLAG? [y/n] " response
   IGNORE_CONFLICT=$(echo "$response")
elif  [[ $REPOGROUP =~ ^all$ ]]
then   
   repos=$(curl -s -H "Authorization: token $TOKEN" https://api.githubserver.com/orgs/org/repos\?per_page\=200  | grep full_name | cut -d '/' -f 2 | cut -d '"' -f 1 | sort )
else
   echo -e "${RED}ERROR: unknown repo group $REPOGROUP ${NOCOLOR}"
   exit 1
fi
dryrun_action()
{
for repo in ${repos[@]}
do
  if [[ " ${REPOS_IGNORE[@]} " =~ " $repo " ]]; then
      echo "Ignoring REPO $repo"
  else	  
      cd $T_DIR
      branch_validate=$(git branch -a | grep $TO_BRANCH)
      if [ ! -z "$branch_validate" ]; then
         echo "processing repo $repo"
         git clone https://githubserver.com/org/$repo  &> /dev/null
         cd $repo
         git checkout $FROM_BRANCH &> /dev/null
         git checkout $TO_BRANCH &> /dev/null
         git merge $FROM_BRANCH --no-commit
         if [ $? -eq 0 ]; then
            echo -e "${GREEN} $repo no conflicts ${NOCOLOR}"
         else
            echo -e "${RED}ERROR: $repo has conflicts ${NOCOLOR}"
            echo "$repo" >>$T_DIR/conflicts.txt
            check_conflicts=$(git diff --name-only --diff-filter=U)
            echo "$repo" >>$T_DIR/conflicts_details.txt
            echo "$check_conflicts" >>$T_DIR/conflicts_details.txt        
         fi
      else
         echo "Ignonring repo $repo as there is no $TO_BRANCH branch"
      fi
   fi     
done 
echo "Summary of repo names"
cat $T_DIR/conflicts.txt

echo "Summary of repos and files with conflicts"
cat $T_DIR/conflicts_details.txt
}

merge_action()
{
for repo in ${repos[@]}
do
  if [[ " ${REPOS_IGNORE[@]} " =~ " $repo " ]] ; then
      echo "Ignoring REPO $repo"
  else    
      cd $T_DIR
      git clone https://githubserver.com/org/$repo checkmerge_$repo &> /dev/null
      cd checkmerge_$repo
      branch_validate=$(git branch -a | grep $TO_BRANCH)
      if [ ! -z "$branch_validate" ]; then
         echo "processing repo $repo"
         cd $T_DIR
         check_if_fork_present=$(curl -H "Authorization: token $TOKEN" -X GET https://api.githubserver.com/repos/org/$repo/forks | jq '. [] | .owner | .login' | grep $USERNAME )
         echo $check_if_fork_present
         if [ ! -z "$check_if_fork_present" ]; then
            git clone https://githubserver.com/$USERNAME/$repo
         else
            echo "Fork not found. Creating one for you!"	
            curl -H "Authorization: token $TOKEN" -X POST https://api.githubserver.com/repos/org/$repo/forks
            git clone https://githubserver.com/$USERNAME/$repo
         fi
         customdate=$(date '+%d_%m_%Y')
         cd $repo
         git remote add org https://githubserver.com/org/$repo
         git fetch org
         git checkout -b $FROM_BRANCH-$customdate "org/$FROM_BRANCH"
         git push -f --set-upstream origin $FROM_BRANCH-$customdate
         git checkout -b $TO_BRANCH-$customdate "org/$TO_BRANCH"
         git push -f --set-upstream origin $TO_BRANCH-$customdate
         cd $T_DIR/checkmerge_$repo		
         git checkout $FROM_BRANCH &> /dev/null
         git checkout $TO_BRANCH &> /dev/null
         echo "***START OF CONFLICT CHECK***"
         git merge $FROM_BRANCH --no-commit
         if [ $? -eq 0 ]; then
	    echo "RESULT OF CONFLICT CHECK"
            echo -e "${GREEN} $repo no conflicts ${NOCOLOR}"
            cd $T_DIR/$repo
            echo -e "${GREEN} Creating Auto PR ${NOCOLOR}"
            git checkout $FROM_BRANCH-$customdate &> /dev/null
	    from_commit=$(git log --oneline -n 1 | cut -d' ' -f1)
	    git checkout $TO_BRANCH-$customdate &> /dev/null
	    to_commit=$(git log --oneline -n 1 | cut -d' ' -f1)
            git merge $FROM_BRANCH-$customdate -m "merging changes from $FROM_BRANCH-$customdate"
            git push -f --set-upstream origin $TO_BRANCH-$customdate
            echo "creation of actual merge into fork"		
            hub pull-request -b org:$TO_BRANCH -h $USERNAME:$TO_BRANCH-$customdate -m "$JIRAID merge $FROM_BRANCH@$from_commit to $TO_BRANCH@$to_commit" >>$T_DIR/PRlist.txt
         else
	    echo "****RESULT OF CONFLICT CHECK***"
            echo -e "${RED} Error: $repo has conflicts ${NOCOLOR}"
            echo "$repo" >>$T_DIR/conflicts.txt
	    cd $T_DIR/checkmerge_$repo
            check_conflicts=$(git diff --name-only --diff-filter=U)
	    if [[ $IGNORE_CONFLICT =~ ^([yY])$ ]]; then
                ignore_conflict_files=$(echo $check_conflicts)
		echo "Below files with conflicts will be REVERTED keeping changes from $TO_BRANCH"
		echo "$ignore_conflict_files"
		read -r -p "Are you sure you want to continue? [y/n] " response
                if [[ ! $response =~ ^([yY])$ ]]
                then
                    exit 0
                fi
		cd $T_DIR/$repo
		git checkout $FROM_BRANCH-$customdate &> /dev/null
	        from_commit=$(git log --oneline -n 1 | cut -d' ' -f1)
	        git checkout $TO_BRANCH-$customdate &> /dev/null
	        to_commit=$(git log --oneline -n 1 | cut -d' ' -f1)
                git merge --no-commit $FROM_BRANCH-$customdate
		for conflicted_file_name in ${ignore_conflict_files[@]}
		   do  
		       echo "***REVERTING $conflicted_file_name TO RESOLVE CONFLICT***"
		       git reset HEAD $conflicted_file_name
                       git checkout -- $conflicted_file_name
		   done 
                 echo -e "${GREEN} Creating Auto PR by keeping $ignore_conflict_files from $TO_BRANCH-$customdate ${NOCOLOR}"		  
	         git commit -m "merging changes from $FROM_BRANCH-$customdate"
	         git push -f --set-upstream origin $TO_BRANCH-$customdate
                 echo "creation of actual merge into fork"		  
                 hub pull-request -b org:$TO_BRANCH -h $USERNAME:$TO_BRANCH-$customdate -m "$JIRAID merge $FROM_BRANCH@$from_commit to $TO_BRANCH@$to_commit" >>$T_DIR/PRlist.txt
	         echo -e "${NOCOLOR}"
	    else
	        check_number_of_files=$(git diff --name-only --diff-filter=U | wc -l)
	        if [ $check_number_of_files -gt 1 ]; then
                   echo "$repo" >>$T_DIR/conflicts_details.txt
                   echo "$check_conflicts" >>$T_DIR/conflicts_details.txt
                   echo "NO pull request has been created for the repo $repo as there are multiple files with conflicts. Manually merge $FROM_BRANCH-$customdate to $TO_BRANCH-$customdate in the fork https://githubserver.com/$USERNAME/$repo and then create PR" >>$T_DIR/conflicts_details.txt
	           echo -e "${NOCOLOR}"
	        else
                   if [ "$check_conflicts" == "deployment.yml" ]; then
	              cd $T_DIR/$repo
	              echo "only deployment.yml has conflicts"
                      git checkout $FROM_BRANCH-$customdate &> /dev/null
	              from_commit=$(git log --oneline -n 1 | cut -d' ' -f1)
	              git checkout $TO_BRANCH-$customdate &> /dev/null
	              to_commit=$(git log --oneline -n 1 | cut -d' ' -f1)
	              echo "***REVERTING DEPLOYMENT.YML TO RESOLVE CONFLICT***"
                      git merge --no-commit $FROM_BRANCH-$customdate
	              git reset HEAD deployment.yml
                      git checkout -- deployment.yml
	              echo -e "${GREEN} Creating Auto PR by keeping deployment.yml from $TO_BRANCH-$customdate ${NOCOLOR}"		  
	              git commit -m "merging changes from $FROM_BRANCH-$customdate"
	              git push -f --set-upstream origin $TO_BRANCH-$customdate
                      echo "creation of actual merge into fork"		  
                      hub pull-request -b org:$TO_BRANCH -h $USERNAME:$TO_BRANCH-$customdate -m "$JIRAID merge $FROM_BRANCH@$from_commit to $TO_BRANCH@$to_commit" >>$T_DIR/PRlist.txt
	           else
                      echo "$repo" >>$T_DIR/conflicts_details.txt
                      echo "$check_conflicts" >>$T_DIR/conflicts_details.txt
                      echo "NO pull request has been created for the repo $repo.Looks like conflict is not in deployment.yml. Hence not attempting auto resoltuion. Manually merge $FROM_BRANCH-$customdate to $TO_BRANCH-$customdate in the fork https://githubserver.com/$USERNAME/$repo" and then create PR>>$T_DIR/conflicts_details.txt
	              echo "${NOCOLOR}"
	          fi	
	       fi	  
	    fi	 
         fi 
      else
         echo "Ignonring repo $repo as there is no $TO_BRANCH branch"
      fi
   fi   
done
echo "Summary of repo names"
cat $T_DIR/conflicts.txt

echo "Summary of repos and files with conflicts"
cat $T_DIR/conflicts_details.txt

file="$T_DIR/PRlist.txt"
if [ -f "$file" ]
then
    echo "List of PRs created"
    cat $file
fi

}

## Jira: https://jira.com:8443/
## Description: add support for merges to the releaseease branch in auto_pr_creation_script.sh
## Assignee: Kumar Abhishek
## Creates fork svc-prdorggit if does not exist on the repo. Once done,
## clone the repo from fork svc-prdorggit
## create master-<release_branch_merge_date> and release-1.x-<release_branch_merge_date> from the master and release-1.x of org fork respectively into svc-prdorggit fork
## checkout release-1.x-<release_branch_merge_date> branch and merge from master-<release_branch_merge_date> with strategy theirs (In case of conflict, take masters changes.)
## commit and push the changes to release-1.x-<release_branch_merge_date> branch
## Using hub tool create PR from svc-prdorggit/release-1.x-<release_branch_merge_date> to org/release-1.x branch

merge_to_release_branch()
{
	FORK_TO_MERGE="svc-prdorggit"
	if [[ $REPOGROUP =~ ^all$ ]]; then
		repos=(${repos})  ## Create repos variable an array
		repos=( $(printf "%s\n" "${repos[@]}" "${REPOS_IGNORE[@]}" | sort | uniq -u) ) ## remove REPOS_IGNORE from all repo list
	fi
	cd $T_DIR	
	for repo in ${repos[@]}; do
		## check if release-1.x branch exists for each repo
		if [ "$repo" != "repo_name_type1" ]; then
			is_release_branch_exists=`curl -s -H "Authorization: token $TOKEN" -X GET https://api.githubserver.com/repos/org/$repo/branches/$TO_BRANCH|jq .name|tr -d '"'`
			if [ "$is_release_branch_exists" == "$TO_BRANCH" ]; then
				echo "Processing $repo"
				echo "Check if fork exists for username: $FORK_TO_MERGE"
				is_fork=`curl -s -H "Authorization: token $TOKEN" -X GET https://api.githubserver.com/repos/org/$repo/forks| jq '.[].owner.login'|grep "$FORK_TO_MERGE"|tr -d '"'`
				if [ "$is_fork" == "$FORK_TO_MERGE" ]; then
					echo "Fork exists"
					git clone https://githubserver.com/svc-prdorggit/$repo
				else
					echo "Fork doesn't exist. Creating new one"
					curl -H "Authorization: token $TOKEN" -X POST https://api.githubserver.com/repos/org/$repo/forks
					git clone https://githubserver.com/svc-prdorggit/$repo
				fi
				cd $repo
				git remote add upstream https://githubserver.com/org/$repo
				git fetch upstream
				git checkout -b ${FROM_BRANCH}-${release_branch_merge_date} "upstream/$FROM_BRANCH"
				from_commit=`git log --oneline -n 1 | cut -d' ' -f1`
				git push -f --set-upstream origin ${FROM_BRANCH}-${release_branch_merge_date}
				git checkout -b ${TO_BRANCH}-${release_branch_merge_date} "upstream/$TO_BRANCH"
				to_commit=`git log --oneline -n 1 | cut -d' ' -f1`
				git merge ${FROM_BRANCH}-${release_branch_merge_date} --no-commit --strategy-option theirs
				git commit -m "$JIRAID merge ${FROM_BRANCH}-${release_branch_merge_date}@$from_commit to ${TO_BRANCH}-${release_branch_merge_date}@$to_commit"
				git push -f --set-upstream origin ${TO_BRANCH}-${release_branch_merge_date}
				hub pull-request -b org:$TO_BRANCH -h $FORK_TO_MERGE:${TO_BRANCH}-${release_branch_merge_date} -m "$JIRAID merge ${FROM_BRANCH}-${release_branch_merge_date}@$from_commit to ${TO_BRANCH}-${release_branch_merge_date}@$to_commit" >>$T_DIR/PRlist.txt

			else
				echo "Warn: Ignoring $repo, since there is no  branch "
			fi
		fi
	done
}
release_branch_merge_date=$(date '+%d_%m_%Y')
if [ "$ACTION" == "merge" ]; then
    echo "AUTO PRs will be created from $FROM_BRANCH to $TO_BRANCH"
    read -r -p "Are you sure you want to continue? [y/n] " response
    if [[ ! $response =~ ^([yY])$ ]]
       then
       exit 0
    fi
    merge_action
elif [ "$ACTION" == "merge_to_release_branch" ]; then
    echo "AUTO PRs will be created from $FROM_BRANCH to $TO_BRANCH"
    read -r -p "Are you sure you want to continue? [y/n] " response
    if [[ ! $response =~ ^([yY])$ ]]
       then
       exit 0
    fi
    merge_to_release_branch
else
    echo "DRY RUN: Summary of merge results from $FROM_BRANCH to $TO_BRANCH. Note: NO PRS will be created"
    dryrun_action
fi  
echo -e "${NOCOLOR}"
