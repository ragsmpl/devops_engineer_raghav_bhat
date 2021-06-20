#!/bin/bash


no_auto_delete_branches=("development" "master" "maintenance")

repos=$(echo "${repos_name}" | xargs -n 1)

git config --global user.email "$BUILD_USER_EMAIL"
git config --global user.name "$BUILD_USER_ID"

create_branch_with_tag()
{   
    cd /tmp
    work_dir=`pwd`
    tmp_dir=$(mktemp -d branch-XXXXXX)
    cd $tmp_dir
    echo ""
    echo ""
    echo "================================================================================"
    echo "creating branch:$target_branch from branch:$source_branch with tag:$tag_version at $source_branch for the below repos:"
    echo "================================================================================"
    echo "${repos_name}"
    echo ""
    if [ -z "$target_branch" ]; then
         echo "Pass the value for target branch"
         exit 1
    fi
    if [ -z "$source_branch" ]; then
        echo "Pass the value for source branch"
        exit 1
    fi
    if [ -z "$tag_version" ]; then
        echo "Pass the value for tag to be created at $target_branch"
        exit 1
    fi
    for REPO in ${repos[@]}
    do
       echo ""
       echo "INFO: Processing repo: $REPO"
       echo ""
       echo "git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git"
       git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git
       cd $REPO
       git checkout $source_branch
       git tag -a "$tag_version" -m "$tag_version"
       git push --tags
       git checkout -b $target_branch
       git push origin $target_branch
       cd $work_dir/$tmp_dir
    done
    cd $work_dir
    echo "deleting tmp directory $tmp_dir......"
    rm -rf $tmp_dir
}

create_tag()
{   
    cd /tmp
    work_dir=`pwd`
    tmp_dir=$(mktemp -d branch-XXXXXX)
    cd $tmp_dir
    echo ""
    echo ""
    echo "================================================================================"
    echo "creating tag:$tag_version at $$target_branch  for the below repos:"
    echo "================================================================================"
    echo "${repos_name}"
    echo ""
    if [ -z "$target_branch" ]; then
         echo "Pass the value for target branch"
         exit 1
    fi

    if [ -z "$tag_version" ]; then
        echo "Pass the value for tag to be created at $target_branch"
        exit 1
    fi
    for REPO in ${repos[@]}
    do
       echo ""
       echo "INFO: Processing repo: $REPO"
       echo ""
       echo "git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git"
       git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git
       cd $REPO
       git checkout $target_branch
       git tag -a "$tag_version" -m "$tag_version"
       git push --tags
       cd $work_dir/$tmp_dir
    done
    cd $work_dir
    echo "deleting tmp directory $tmp_dir......"
    rm -rf $tmp_dir
}

create_branch()
{   
    cd /tmp
    work_dir=`pwd`  
    tmp_dir=$(mktemp -d branch-XXXXXX)
    cd $tmp_dir
    if [ -z "$target_branch" ]; then
         echo "Pass the value for target branch"
         exit 1
    fi
    if [ -z "$source_branch" ]; then
        echo "Pass the value for source branch"
        exit 1
    fi
    echo ""
    echo ""
    echo "================================================================================"
    echo "creating branch: $target_branch from branch:$source_branch for the below repos:"
    echo "================================================================================"
    echo "${repos_name}"
    echo ""
    for REPO in ${repos[@]}
    dowhatfix
       echo "INFO: Processing repo: $REPO"
       echo "git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git"
       git clone -b $source_branch --single-branch https://$uname:$psswd@bitbucket.org/companyname/$REPO.git
       cd $REPO
       git checkout $source_branch
       git checkout -b $target_branch
       git push origin $target_branch
       cd $work_dir/$tmp_dir
    done
    cd $work_dir
    echo "deleting tmp directory $tmp_dir......"
    rm -rf $tmp_dir
}

delete_branch()
{   
    cd /tmp
    work_dir=`pwd`  
    tmp_dir=$(mktemp -d branch-XXXXXX)
    cd $tmp_dir
    echo ""
    echo ""
    if [ -z "$target_branch" ]; then
         echo "Pass the value for target branch to be deleted"
         exit 1
    fi
    echo ""
    echo ""
    echo "================================================================================"
    echo "deleting branch:$target_branch for the below repos:"
    echo "================================================================================"
    echo "${repos_name}"
    echo ""

    if [[ " ${no_auto_delete_branches[@]} " =~ " $target_branch " ]]; then
        echo ""
        echo "WARNING!!"
        echo ""
        echo "Looks crazy!! $target_branch should not be deleted!!"
        echo "If you still want to delete, do it manually !!"
        exit 1
    fi
    
    for REPO in ${repos[@]}
    do
       echo "INFO: Processing repo: $REPO"
       echo "git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git"
       git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git
       cd $REPO
       git branch -d $target_branch
       git push origin --delete $target_branch
       cd $work_dir/$tmp_dir
    done
    cd $work_dir
    echo "deleting tmp directory $tmp_dir......"
    rm -rf $tmp_dir
}

delete_branch_with_tag()
{   
    cd /tmp
    work_dir=`pwd`  
    tmp_dir=$(mktemp -d branch-XXXXXX)
    cd $tmp_dir
    if [ -z "$target_branch" ]; then
         echo "Pass the value for target branch to be deleted"
         exit 1
    fi
    echo ""
    echo ""
    echo "================================================================================"
    echo "deleting branch:$target_branch with tag:$tag_version for the below repos:"
    echo "================================================================================"
    echo "${repos_name}"
    echo ""
    if [[ " ${no_auto_delete_branch[@]} " =~ " $target_branch " ]]; then
    
        echo "Looks crazy!! $target_branch should not be deleted!!"
        echo "If you still want to delete, do it manually !!"
        exit 1
    fi
    
    if [ -z "$tag_version" ]; then
        echo "Pass the value for tag to be created at $tag_version"
        exit 1
    fi

    for REPO in ${repos[@]}
    do
       echo "INFO: Processing repo: $REPO"
       echo "git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git"
       git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git
       cd $REPO
       git tag -d $tag_version
       git push origin :refs/tags/$tag_version
       git branch -d $target_branch
       git push origin --delete $target_branch
       
       cd $work_dir/$tmp_dir
    done
    cd $work_dir
    echo "deleting tmp directory $tmp_dir......"
    rm -rf $tmp_dir
}

delete_tag()
{   
    cd /tmp
    work_dir=`pwd`  
    tmp_dir=$(mktemp -d branch-XXXXXX)
    cd $tmp_dir
    if [ -z "$tag_version" ]; then
         echo "Pass the value for tag to be deleted"
         exit 1
    fi
    echo ""
    echo ""
    echo "================================================================================"
    echo "deleting tag:$tag_version for the below repos:"
    echo "================================================================================"
    echo "${repos_name}"
    echo ""

    for REPO in ${repos[@]}
    do
       echo "INFO: Processing repo: $REPO"
       echo "git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git"
       git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git
       cd $REPO
       git tag -d $tag_version
       git push origin :refs/tags/$tag_version
       
       cd $work_dir/$tmp_dir
    done
    cd $work_dir
    echo "deleting tmp directory $tmp_dir......"
    rm -rf $tmp_dir
}

merge_branch_with_tag()
{   
    cd /tmp
    work_dir=`pwd`  
    tmp_dir=$(mktemp -d branch-XXXXXX)
    echo "changelog" >/tmp/$tmp_dir.txt
    cd $tmp_dir
    echo ""
    echo ""
    echo "================================================================================"
    echo "merge branch:$source_branch to branch:$target_branch with tag:$tag_version at $target_branch for the below repos:"
    echo "================================================================================"
    echo "${repos_name}"
    echo ""
    if [ -z "$target_branch" ]; then
         echo "Pass the value for target branch"
         exit 1
    fi
    if [ -z "$source_branch" ]; then
        echo "Pass the value for source branch"
        exit 1
    fi
    if [ -z "$tag_version" ]; then
        echo "Pass the value for tag to be created at $target_branch"
        exit 1
    fi
    for REPO in ${repos[@]}
    do
       echo ""
       echo "INFO: Processing repo: $REPO"
       echo ""
       echo "git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git"
       git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git
       cd $REPO
       git checkout $target_branch
       old_commit=$(git log --oneline -n 1 | awk '{print $1}')
       echo "$REPO:$target_branch:$tag_version" >>/tmp/$tmp_dir.txt
       git merge origin/$source_branch -m "[OPS Automation][Merging /$source_branch into $target_branch]"
       git push origin $target_branch
       git tag -a "$tag_version" -m "$tag_version"
       git push --tags
       cd $work_dir/$tmp_dir
    done
    cd $work_dir
    echo "deleting tmp directory $tmp_dir......"
    rm -rf $tmp_dir
    echo "change log file:$tmp_dir.txt"
}

git_cherry_pick()
{   
    cd /tmp
    work_dir=`pwd`  
    tmp_dir=$(mktemp -d branch-XXXXXX)
    cd $tmp_dir
    if [ -z "$target_branch" ]; then
         echo "Pass the value for target branch"
         exit 1
    fi

    echo ""
    echo ""
    echo "================================================================================"
    echo "cherry-pick $commit_sha to branch:$target_branch for the below repos:"
    echo "================================================================================"
    echo "${repos_name}"
    echo ""
    for REPO in ${repos[@]}
    do
       echo "INFO: Processing repo: $REPO"
       echo "git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git"
       git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git
       cd $REPO
       git checkout $target_branch
       git cherry-pick -x $commit_sha
       git push origin $target_branch
       cd $work_dir/$tmp_dir
    done
    cd $work_dir
    echo "deleting tmp directory $tmp_dir......"
    rm -rf $tmp_dir
}

rename_branches()
{   
    cd /tmp
    work_dir=`pwd`  
    tmp_dir=$(mktemp -d branch-XXXXXX)
    cd $tmp_dir
    if [ -z "$target_branch" ]; then
         echo "Pass the value for target branch"
         exit 1
    fi
    if [ -z "$source_branch" ]; then
        echo "Pass the value for source branch"
        exit 1
    fi
    echo ""
    echo ""
    echo "================================================================================"
    echo "rename_branches from branch: $source_branch to branch: $target_branch for the below repos:"
    echo "================================================================================"
    echo "${repos_name}"
    echo ""
    if [[ " ${no_auto_delete_branch[@]} " =~ " $source_branch " ]]; then
    
        echo "Looks crazy!! $target_branch should not be renamed!!"
        echo "If you still want to rename, do it manually !!"
        exit 1
    fi
    for REPO in ${repos[@]}
    do
       echo "INFO: Processing repo: $REPO"
       echo "git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git"
       git clone https://$uname:$psswd@bitbucket.org/companyname/$REPO.git
       cd $REPO
       git checkout $source_branch
       git checkout -b $target_branch
       git push origin --delete $source_branch
       git push origin $target_branch
       cd $work_dir/$tmp_dir
    done
    cd $work_dir
    echo "deleting tmp directory $tmp_dir......"
    rm -rf $tmp_dir
}

sync_branch() {
    echo "======================================" >${WORKSPACE}/result.txt
    echo "Create PR with auto reviewers summary"  >>${WORKSPACE}result.txt
    echo "======================================" >>${WORKSPACE}/result.txt
    echo "" >>${WORKSPACE}/result.txt
    for REPO in ${repos[@]}
       do  
          echo "INFO: Processing repo: $REPO"
          echo "INFO: Syncing  $target_branch with $source_branch"
          RESULT=`curl -X POST "https://api.bitbucket.org/2.0/repositories/companyname/$REPO/pullrequests" \
          --silent \
          --user $uname:$psswd \
          -H 'content-type: application/json' \
          -d '{
           "title": "[OPS Automation][Sync branch '$target_branch' with '$source_branch'",
           "description": "Automatic pull request created.",
           "state": "OPEN",
           "destination": {
           "branch": {
                "name": "'$target_branch'"
                     }
                          },
            "source": {
            "branch": {
                "name": "'$source_branch'"
                       }
                   }
                }'`

            # Check for error messages
            ERR_MSG=`echo $RESULT | jq -r '.error.message' || true`
            if [ "$ERR_MSG" == 'null' ]; then
             # No errors, continue
                pr_link_html=$(echo $RESULT | jq '.links.html.href' | tr -d \")
                BB_MERGE_URL=`echo $RESULT | jq -r '.links.merge.href'`

                RESULT2=`curl -X POST "$BB_MERGE_URL" \
                --fail --silent \
                --user $uname:$psswd \
                -H 'content-type: application/json' \
                -d '{
                "close_source_branch": false,
                "title": "[OPS Automation][Sync branch '$target_branch' with '$source_branch'",
                "merge_strategy": "merge_commit"
                }' || echo "failure"`
                if [ "$RESULT2" == "failure" ]; then
                    echo "$REPO: Auto merge failed!!!" 
                    echo "$REPO: Auto merge failed!!!" >>${WORKSPACE}/result.txt
                    echo "More details:  $pr_link_html  " >>${WORKSPACE}/result.txt
                else
                    echo "Running branch diff revalidation"
                    REVALIDATION=$(curl --user $uname:$psswd --silent -X GET https://api.bitbucket.org/2.0/repositories/companyname/$REPO/diff/$source_branch%0D$target_branch)
                    if [ -z "$REVALIDATION" ]; then
                        echo "$REPO: Sync completed successfully."
                        echo "$REPO: Sync completed successfully.">>${WORKSPACE}/result.txt
                        echo "Sync completed successfully."
                    else
                        echo "There are diffs between '$target_branch' with '$source_branch'"
                        echo "recheck PR $pr_link_html" >>${WORKSPACE}/result.txt
                    fi
                fi
            elif [ "$ERR_MSG" == 'There are no changes to be pulled' ]; then
                # Do we have changes that need to be merged?
                 echo "$REPO: No changes, hence no synce needed">>${WORKSPACE}/result.txt
                echo "Nothing to do. All changes are already merged."
            else
        
                echo "ERROR!!!!!!!!!!"
                echo "BitBucket returned an error: $ERR_MSG"
                echo "$REPO: Sync failed. Check the logs and sync manually!!.">>${WORKSPACE}/result.txt
                exit 0
         fi
        done
    }
    
create_pr_with_auto_reviewers() {
    echo "======================================" >${WORKSPACE}/result.txt
    echo "Create PR with auto reviewers summary"  >>${WORKSPACE}/result.txt
    echo "======================================" >>${WORKSPACE}/result.txt
    echo "" >>${WORKSPACE}/result.txt
    
    for REPO in ${repos[@]}
       do
          echo "INFO: Processing repo: $REPO"
          echo "INFO: Creating PR from $source_branch to $target_branch"
          RESULT=`curl -X POST "https://api.bitbucket.org/2.0/repositories/companyname/$REPO/pullrequests" \
          --silent \
          --user $uname:$psswd \
          -H 'content-type: application/json' \
          -d '{
           "title": "[OPS Automation][ Create PR from '$source_branch' to '$target_branch'",
           "description": "Automatic pull request created.",
           "state": "OPEN",
           "destination": {
           "branch": {
                "name": "'$target_branch'"
                     }
                          },
            "source": {
            "branch": {
                "name": "'$source_branch'"
                       }
                   }
                }'`
           
           ERR_MSG=`echo $RESULT | jq -r '.error.message' || true`
           if [ "$ERR_MSG" == 'null' ] ;then
             # No errors, continue
              tilte_var=$(echo $RESULT | jq '.title' | tr -d \")
              pr_link_html=$(echo $RESULT | jq '.links.html.href' | tr -d \")
              pr_link=$(echo $RESULT | jq '.links.self.href' | tr -d \")
              pr_author_acc_id=$(echo $RESULT | jq '.author.account_id' | tr -d \")
              RESULT2=$(curl --silent --user $uname:$psswd -X GET "$pr_link/commits" | jq -r '.values[] | .author.user.account_id' | grep -v "null" | grep -v $pr_author_acc_id | xargs -n 1)
              reviewers_var="\"reviewers\":["
              lenth_array=0
              count=1
              
              for acc in ${RESULT2[@]}
                  do
                  lenth_array=$(expr $lenth_array + 1)
                  done
                  
              for acc in ${RESULT2[@]}
                  do      
                      if [[ $count == $lenth_array ]] ; then 
       	                 reviewers_var=$reviewers_var"{\"account_id\":\"$acc\"}"
                      else
                         reviewers_var=$reviewers_var"{\"account_id\":\"$acc\"},"
                      fi
                         count=$(expr $count + 1)
                     done
                   reviewers_var=$reviewers_var"]}"               
                   auto_add_reviewers="{\"title\":\"$tilte_var\",$reviewers_var"
                   check_auto_reviewer_error=`curl --fail --silent -X PUT --user $uname:$psswd -H 'content-type: application/json' "$pr_link" -d "$auto_add_reviewers" || echo "failure"`
                   if [ "$check_auto_reviewer_error" != "failure" ] ; then
                      echo "PR LINK: $pr_link"  
                      echo "$REPO: $pr_link_html [Note: Reviewers auto added!]" >>${WORKSPACE}/result.txt
                      echo "Following reviewers have been added automatically:"
                      curl --silent --user  $uname:$psswd -X GET "$pr_link" | jq -r '.reviewers | .[] | .display_name'
                   else
                      echo "PR LINK: $pr_link_html" 
                      echo "$REPO: $pr_link_html [Note: No reviewers added due to some error!]" >>${WORKSPACE}/result.txt
                      echo "Issue with auto reviewer update. please check PR $pr_link"
                   fi 
              
            elif [ "$ERR_MSG" == "There are no changes to be pulled" ]; then
                 # Do we have changes that need to be merged?
                echo "Nothing to do. All changes are already merged."
                echo "$REPO: Nothing to do. All changes are already merged." >>${WORKSPACE}/result.txt
            else
        
                echo "ERROR!!!!!!!!!!"
                echo "BitBucket returned an error: $ERR_MSG"
                echo "$REPO: BitBucket returned an error" >>${WORKSPACE}/result.txt
                echo $RESULT
                exit 0
            fi 
        done
    }
    
diff_branch() {
    "Diff check for the repos" >${WORKSPACE}/result.txt
    for REPO in ${repos[@]}
       do
          echo "INFO: Processing repo: $REPO"
          echo "INFO: diff check from $source_branch to $target_branch"
          diffcheck=$(curl --user $uname:$psswd --silent -X GET https://api.bitbucket.org/2.0/repositories/companyname/$REPO/diff/$source_branch%0D$target_branch)
          if [ -z "$diffcheck" ]; then
              echo "$REPO: There are no diff from $source_branch to $target_branch"
          else
              echo "There are diffs between '$target_branch' with '$source_branch' in rep $REPO">>${WORKSPACE}/result.txt
          fi
            
        done
    }
    
select_the_action()
{
echo "Looks like in a hurry to build!!"
echo "select appropriate action to be performed"
}
case ${ACTION} in

  "create_branch_with_tag")
    create_branch_with_tag
    ;;
    
   "create_branch")
    create_branch
    ;;
    
   "delete_branch")
    delete_branch
    ;;
    
   "delete_branch_with_tag")
    delete_branch_with_tag
    ;;
    
    "merge_branch_with_tag")
    merge_branch_with_tag
    ;;
    
   "git_cherry_pick")
    git_cherry_pick
    ;;
    
    "delete_tag")
    delete_tag
    ;;
    
   "rename_branches")
    rename_branches
    ;;
       
   "sync_branch")
    sync_branch
    ;;
    
   "diff_branch")
    diff_branch
    ;;
   "create_tag")
    create_tag
    ;;
    
   "create_pr_with_auto_reviewers")
    create_pr_with_auto_reviewers
    ;;
    
   "select_the_action")
    select_the_action
    ;;

  *)
    echo "nothing"
    ;;
esac
