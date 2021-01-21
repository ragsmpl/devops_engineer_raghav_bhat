#!/bin/bash

#GitHub API Token
TOKEN="testtoken"

#API URL
API_URL="api.githubserver"

#organisation
ORG="project"

#Release Tag information
COMMITISH="master"
DRAFT=false
PRERELEASE=true

#Success Return
RET=0

#Color codes
RED="\033[1;31m"
NOCOLOR="\033[0m"
GREEN="\033[1;32m"

#Release branch flag
RELEASE_BRANCH_FLAG=0

#Default the repo type to tag as 'test'
REPOGROUP='all'

#Do not create release on following repos by default
REPOS_IGNORE=("dev-env")

# repos to perform test tagging
REPOS_TEST=("sample-go")

# repos to treat individually as special
REPOS_SPECIAL=("releng_repo")

usage()
{
  echo "usage: $0 [-h] [-t tag] [-n tag_name] [-b tag_body] [-c target_commitish] [-d draft] [-p prerelease] [-r release_branch_flag] [-g test|special]"

  echo "Options:"
  echo "   -t tag                  Specifies tag. for eg: 0.10.0"
  echo "   -b tag_body             Specifies tag body. for eg: project Release Candidate (RC) Test" 
  echo "   -n tag_name             Sepcifies tag name. for eg: project Test"
  echo "   -c target_commitish     Specifies the commitish value that is archived. Can be any branch, tag or commit SHA. Default is master."
  echo "   -d draft                Specifies Draft release. Default is false"
  echo "   -p prerelease           Specifies prerelease. Default is true"
  echo "   -r release_branch_flag  Specifies release branch creation. Options are 0 or 1. Default is 0(False)"
  echo "   -g repo group           Specify an override for repos to use. options are test or special"
  echo "   -h help                 print this help and exit"
}

while getopts "t:n:b:c:d:p:r:g:h" option
do
   case $option in
     h) usage && exit ;;
     t) TAG=$OPTARG ;;
     n) TAG_NAME=$OPTARG ;;
     b) TAG_BODY=$OPTARG ;;
     c) COMMITISH=$OPTARG ;;
     d) DRAFT=$OPTARG ;;
     p) PRERELEASE=$OPTARG ;;
     r) RELEASE_BRANCH_FLAG=$OPTARG ;;
     g) REPOGROUP=$OPTARG ;;
     ?) echo "error: option -$OPTARG is not implemented"; usage; exit 1 ;;
   esac
done

shift $(($OPTIND - 1))

# Required Parameters Check
if [ "$TAG" == "" ] || [ "$TAG_NAME" == "" ] || [ "$TAG_BODY" == "" ]
then
   if [ $# -eq 0 ]
   then
      echo -e "${RED}ERROR: No value supplied for either tag, tag name, tag body ${NOCOLOR}"
      usage
      exit 1
   fi
fi

#Release branch flag check
if [ $RELEASE_BRANCH_FLAG -ne 0 ] && [ $RELEASE_BRANCH_FLAG -ne 1 ]; then
   echo -e "${RED}ERROR : Release branch flag must be 0 or 1 ${NOCOLOR}"
   usage
   exit 1
fi

if [[ ! $REPOGROUP =~ ^test$ ]] && [[ ! $REPOGROUP =~ ^special$ ]] && [[ ! $REPOGROUP =~ ^all$ ]]
then
   echo -e "${RED}ERROR: repo type must be either 'test','special' or 'all'${NOCOLOR}"
   usage
   exit 1
fi

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

# display vars and ask for confirmation
echo "INFO : TAG                   - $TAG"
echo "INFO : TAG Name              - $TAG_NAME"
echo "INFO : COMMITISH             - $COMMITISH"
echo "INFO : TAG BODY              - $TAG_BODY"
echo "INFO : Draft                 - $DRAFT"
echo "INFO : PRE RELEASE           - $PRERELEASE"
echo "INFO : REPO GROUP            - $REPOGROUP"
echo "INFO : Create RELEASE BRANCH - $RELEASE_BRANCH_FLAG"
echo "INFO : REPOS EXCLUDED        - ${REPOS_IGNORE[@]}"
echo "INFO : # REPOS Found         - ${#repos[@]}"
echo "INFO : REPOS found           - ${repos[@]}"
read -r -p "Are you sure you want to continue? [y/n] " response

if [[ ! $response =~ ^([yY])$ ]]
then
   exit 0
fi

for REPO in ${repos[@]}
do
   echo -e '\n'
   echo "INFO: Processing repo: $REPO"
   # only ignore specified repos when you are checking against all repos (i.e. REPOGROUP = all )
   if  [[ $REPOGROUP =~ ^all$ ]] && [[ " ${REPOS_IGNORE[@]} " =~ " $REPO " ]]
   then
      echo "WARN: Ignoring $REPO"
   else
      # Define json payload for creating release
      DATA=$(cat <<EOF
{"tag_name": "$TAG","target_commitish": "$COMMITISH","name": "$TAG_NAME","body": "$TAG_BODY","draft": $DRAFT,"prerelease": $PRERELEASE}
EOF
)
      echo "INFO: Creating Release $TAG_NAME for $REPO"
      curl -k -i -X POST -H "Content-Type-Type:application/json" "https://$API_URL/repos/$ORG/$REPO/releases?access_token=$TOKEN" -d "$DATA"
      tagcurlstatus=$?
      if [ "$tagcurlstatus" -ne 0 ]
      then
         echo -e "${RED}ERROR: Creating Release $TAG_NAME for $REPO ...failed!${NOCOLOR}"
         RET=$((RET+1))
      else
         echo -e "${GREEN}INFO: Creating Release $TAG_NAME for $REPO ...successful${NOCOLOR}"
         if [ $RELEASE_BRANCH_FLAG == 1 ]; then
            echo "INFO: Creating release branch rel-$TAG for $REPO"
            SHA=$(curl -k "https://$API_URL/repos/$ORG/$REPO/git/refs/tags/$TAG?access_token=$TOKEN" | grep sha | cut -d ':' -f 2 | cut -d "," -f 1)
            if [ -z "$SHA" ]; then
               echo -e "${RED}ERROR: Retrieving SHA of $TAG for $REPO ...failed!${NOCOLOR}"
               RET=$((RET+1))
            else
               #Define json payload for creating branch
               REF_DATA=$(cat <<EOF
{"ref":"refs/heads/rel-$TAG","sha":$SHA}
EOF
)
               curl -k -X POST -H "Content-Type:application/json" "https://$API_URL/repos/$ORG/$REPO/git/refs?access_token=$TOKEN" -d "$REF_DATA"
               createbranchstatus=$?
               if [ "$createbranchstatus" -ne 0 ]; then
                  echo -e "${RED}ERROR: Creating release branch rel-$TAG for $REPO ...failed!${NOCOLOR}"
                  RET=$((RET+1))
               else
                  echo -e "${GREEN}INFO: Creating release branch rel-$TAG for $REPO ...successful${NOCOLOR}"
               fi
            fi
         fi
      fi
   fi
done

if  [[ $REPOGROUP =~ ^all$ ]]
then
   echo ""
   echo "WARNING: **********"
   echo "WARNING: REMEMBER, after updating manifest files  to rerun this script for special repos !!!!!"
   echo "WARNING:           by appending '-r special'"
   echo "WARNING: **********"
fi

if [ $RET -ne 0 ]
then
   echo -e "${RED}ERROR : exiting FAULURE - please resolve errors before progressing !"
else
   echo -e "${GREEN}INFO : exiting SUCCESS - everything looks good !"
fi
exit $RET
