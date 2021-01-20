#!/bin/bash

#This script will update/add/siable/enable/delete branch protection rules. 
# No arguments required, simply run the script which is in interactive mode. 
# REPOGROUP="all""This will apply the changes for all the repos under team, except for REPOS_IGNORE
# REPOGROUP="test":This will apply the changes for the repos in REPOS_TEST.
# REPOGROUP="special":This will apply the changes for the repos in REPOS_SPECIAL

# action="enable_branch_protection": This will add or enable or update branch protection for the branch provided.
# action="disable_branch_protection": This will lock the branch and only ci-cd team can merge.
# action="delete_branch_protection": This will delete the branch protection [Be careful!!]

# READ doccumentation from https://developer.github.com/v3/repos/branches/

# The Protected Branches API now has a setting for requiring a specified
# number of approving pull request reviews before merging. This feature is currently available for developers to preview. See the blog post for full
# details. To access the API during the preview period, you must provide a custom media type in the 
# Accept header: application/vnd.github.luke-cage-preview+json


echo "~~~~~~~~~~~~~~~~~~~~~"	
echo " SELECT REPOGROUP"
echo "~~~~~~~~~~~~~~~~~~~~~"
echo "1. process all repos"
echo "2. process test repos"
echo "3. process special repos"
echo "4. to quit"

read -p "Enter your choice: " response
case $response in
        "1")
		    REPOGROUP="all"
            echo "You have selected 'process all repos'"
            ;;
        "2")
		    REPOGROUP="test"
            echo "You have selected 'process test repos'"
            ;;
        "3")
		    REPOGROUP="special"
            echo "You have selected 'process special repos'"
            ;;
        "4")
            echo "You have selected 'quit'"
            exit 0
            ;;
        *) echo "invalid option $response"
           exit 0;;
esac



# display vars and ask for confirmation
echo "INFO : REPO GROUP            - $REPOGROUP"
read -r -p "Are you sure you want to continue? [y/n] " response
if [[ ! $response =~ ^([yY])$ ]]
then
    exit 0
fi

read -r -p "Enter the branch name:" response
BRANCH=$(echo "$response")
echo "INFO : BRANCH            - $BRANCH"
read -r -p "Are you sure you want to continue? [y/n] " response
if [[ ! $response =~ ^([yY])$ ]]
then
    exit 0
fi

echo "~~~~~~~~~~~~~~~~~~~~~"	
echo " SELECT ACTION"
echo "~~~~~~~~~~~~~~~~~~~~~"
echo "1. enable/add branch protection[unlock the branch]"
echo "2. disable branch protection[lock the branch]"
echo "3. delete branch protection"
echo "4. read branch protection"
echo "5. to quit"

read -p "Enter your choice: " response
case $response in
        "1")
		    action="enable_branch_protection"
            echo "You have selected 'enable/add branch protection[unlock the branch]'"
            ;;
        "2")
		    action="disable_branch_protection"
            echo "You have selected 'disable branch protection[[lock the branch]'"
            ;;
        "3")
		    action="delete_branch_protection"
            echo "You have selected 'delete branch protection'"
            ;;
        "4")
                    action="read_branch_protection"
            echo "You have selected 'read branch protection'"
            ;;
        "5")
            echo "You have selected 'quit'"
            exit 0
            ;;
        *) echo "invalid option $response"
           exit 0;;
esac

echo "INFO : ACTION            - $action"
read -r -p "Are you sure you want to continue? [y/n] " response
if [[ ! $response =~ ^([yY])$ ]]
then
    exit 0
fi

#GitHub API Token
TOKEN="xxx"

#branchname for which branch protection rule has to be updated


#API URL
API_URL="api.server"

#organisation
ORG="team"


#Success Return
RET=0

#Color codes
RED="\033[1;31m"
NOCOLOR="\033[0m"
GREEN="\033[1;32m"


#Update branch protection on following repos by default
REPOS_IGNORE=("dev")

# repos to perform test branch protection
REPOS_TEST=("sample")

# repos to treat individually as special
REPOS_SPECIAL=("none")


if [[ $REPOGROUP =~ ^test$ ]]
then
   repos=("${REPOS_TEST[@]}")
elif  [[ $REPOGROUP =~ ^special$ ]]
then
   repos=("${REPOS_SPECIAL[@]}")
elif  [[ $REPOGROUP =~ ^all$ ]]
then
   repos=( $(curl -k -s -H "Authorization: token $TOKEN" https://$API_URL/orgs/$ORG/repos\?per_page\=200  | grep full_name | cut -d '/' -f 2 | cut -d '"' -f 1 | sort) )
else
   echo -e "${RED}ERROR: unknown repo group $REPOGROUP ${NOCOLOR}"
   exit 1
fi

if [ ! "${#repos[@]}" -gt 0 ]
then
   echo -e "${RED}ERROR: looks like there was an issue getting list of repos, ${#repos[@]} found !${NOCOLOR}"
   exit 1
fi

disable_branch()
{
  cat <<EOF

{
  "required_status_checks": {
    "strict": true,
    "contexts": []
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismissal_restrictions": {},
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 1
  },
  "restrictions": {
    "users": [],
    "teams": [
      "ci-cd"
    ]
  },
  "required_linear_history": true,
  "allow_force_pushes": true,
  "allow_deletions": true
}
EOF
}

for REPO in ${repos[@]}
do
   echo -e '\n'
   echo "INFO: Processing repo: $REPO"
   # only ignore specified repos when you are checking against all repos (i.e. REPOGROUP = all )

   if [ "$action" == "read_branch_protection" ]; then
      if  [[ $REPOGROUP =~ ^all$ ]] && [[ " ${REPOS_IGNORE[@]} " =~ " $REPO " ]]
          then
              echo "WARN: Ignoring $REPO"
      else
              echo "INFO: reading $BRANCH branch restrictions for $REPO"
              read_command=$(curl -s --fail -k -H "Accept: application/vnd.github.luke-cage-preview+json" -H "Content-Type: application/vnd.github.luke-cage-preview+json" -H "Authorization: token $TOKEN" https://server/api/v3/repos/team/$REPO/branches/$BRANCH/protection/restrictions/teams | jq -r '.[] | .name')
              echo "$read_command"
      fi
   elif [ "$action" == "enable_branch_protection" ]; then
      if  [[ $REPOGROUP =~ ^all$ ]] && [[ " ${REPOS_IGNORE[@]} " =~ " $REPO " ]]
          then
              echo "WARN: Ignoring $REPO"
      else
	    ## Jira: ESNG-38676: update branch lock/unlock script to record and apply current configurations
	    ## Assignee: Kumar Abhishek
	    ## Create a teams.cfg map file, that maps the each repo with the team that has access right to push the changes.   
	    ## For each team, there is ${team_name}.json file. E.g. team-Integration-Approvers-ci_check.json, unicorn.json etc
	    ## Grant the access to each repo based on teams mentioned in json file
	    team_name=`grep $REPO teams.cfg | awk -F "=" '{print $1}'`
          creation_command=$(curl -s --fail -k -H "Accept: application/vnd.github.luke-cage-preview+json" -H "Content-Type: application/vnd.github.luke-cage-preview+json" -H "Authorization: token $TOKEN" -X PUT https://server/api/v3/repos/team/$REPO/branches/$BRANCH/protection -d "$(cat ${team_name}.json)" || echo "update_fail")
	  if [ "$creation_command" == "update_fail" ]
              then
              echo -e "${RED}ERROR: Updating branch protecion rule for the branch $BRANCH for the $REPO ...failed!${NOCOLOR}"
              echo -e "${RED}ERROR: Check if $BRANCH exits in the $REPO ${NOCOLOR}"
              echo -e "${RED}Following command failed: curl --fail -k -H \"Accept: application/vnd.github.luke-cage-preview+json\" -H \"Content-Type: application/vnd.github.luke-cage-preview+json\" -H \"Authorization: token $TOKEN\" -X PUT https://server/api/v3/repos/team/$REPO/branches/$BRANCH/protection -d \"\$(generate_post_data)\" ${NOCOLOR}"
              RET=$((RET+1))
          else
              echo -e "${GREEN}INFO: Updating branch protecion rule[Unlock] for the branch $BRANCH for the $REPO ...successful${NOCOLOR}"
          fi
       fi
	   
   elif [ "$action" == "disable_branch_protection" ]; then
      if  [[ $REPOGROUP =~ ^all$ ]] && [[ " ${REPOS_IGNORE[@]} " =~ " $REPO " ]]
          then
              echo "WARN: Ignoring $REPO"
      else
	      
		  creation_command=$(curl -s --fail -k -H "Accept: application/vnd.github.luke-cage-preview+json" -H "Content-Type: application/vnd.github.luke-cage-preview+json" -H "Authorization: token $TOKEN" -X PUT https://server/api/v3/repos/team/$REPO/branches/$BRANCH/protection -d "$(disable_branch)" || echo "update_fail")
          
		  if [ "$creation_command" == "update_fail" ]
              then
              echo -e "${RED}ERROR: Updating branch protecion rule for the branch $BRANCH for the $REPO ...failed!${NOCOLOR}"
              echo -e "${RED}ERROR: Check if $BRANCH exits in the $REPO ${NOCOLOR}"
              echo -e "${RED}Following command failed: curl --fail -k -H \"Accept: application/vnd.github.luke-cage-preview+json\" -H \"Content-Type: application/vnd.github.luke-cage-preview+json\" -H \"Authorization: token $TOKEN\" -X PUT https://server/api/v3/repos/team/$REPO/branches/$BRANCH/protection -d \"\$(generate_post_data)\" ${NOCOLOR}"
              RET=$((RET+1))
          else
              echo -e "${GREEN}INFO: Updating branch protecion rule[Locking] for the branch $BRANCH for the $REPO ...successful${NOCOLOR}"
          fi
       fi	   
   elif [ "$action" == "delete_branch_protection" ]; then
        
       if  [[ $REPOGROUP =~ ^all$ ]] && [[ " ${REPOS_IGNORE[@]} " =~ " $REPO " ]]
          then
              echo "WARN: Ignoring $REPO"
      else
          creation_command=$(curl -s --fail -k -H "Accept: application/vnd.github.luke-cage-preview+json" -H "Content-Type: application/vnd.github.luke-cage-preview+json" -H "Authorization: token $TOKEN" -X DELETE https://server/api/v3/repos/team/$REPO/branches/$BRANCH/protection || echo "delete_fail")

          if [ "$creation_command" == "delete_fail" ]
              then
              echo -e "${RED}ERROR: deletion of branch protecion rule for the branch $BRANCH for the $REPO ...failed!${NOCOLOR}"
              echo -e "${RED}ERROR: Check if $BRANCH exits in the $REPO ${NOCOLOR}"
              echo -e "${RED}Following command failed: curl --fail -k -H \"Accept: application/vnd.github.luke-cage-preview+json\" -H \"Content-Type: application/vnd.github.luke-cage-preview+json\" -H \"Authorization: token $TOKEN\" -X DELETE https://server/api/v3/repos/team/$REPO/branches/$BRANCH/protection ${NOCOLOR}"
              RET=$((RET+1))
          else
              echo -e "${GREEN}INFO: deletion of branch protecion rule for the branch $BRANCH for the $REPO ...successful${NOCOLOR}"
          fi
       fi
   fi      
done
