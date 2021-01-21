#!/bin/sh
###################################################################################################################################
#PROBLEM: Due to CPU or Memory usage beyond threshold will result in either node in "NotReady" state or PVC binding in "Pending" state which will
# which will result in component test failure or deployment failure.
#WHAT THIS SCRIPT DOES: This script will hourly from jump server, if any node having issues, it will reboot all nodes and ensure cluster is back to
#normal state and notify channel_name channel.
#This script has been added in $clustername jump machine. It will check the status of cluster and take action accordingly.
#Checks if any node is in Not ready state
###################################################################################################################################

clustername=$(hostname | cut -d'-' -f1,2)
node_not_ready=$(kubectl get nodes | grep "NotReady" | grep node | awk '{print $1}' | xargs -n 1 | sed '/^$/d')
#Checks if any pvc is in pending state
PVC_Pending=$(kubectl get pvc --all-namespaces | awk '{print $3}' | grep "Pending")
#If any node is in notready state, the will be rebooted.
if [ ! -z "$node_not_ready" ]; then
    data=$(kubectl get nodes)
    #Slack notification with faulty node list
    curl -X POST -H 'Content-type: application/json' --data "{\"channel\":\"channel_name\",\"text\": \"Alert from $clustername Cluster.Detected issues with Node being in NotReady state. It will be taken care with auto reboot of the Nodes. No manual action needed to address this.\`\`\`$data\`\`\`\"}" 
    for eachmachine in ${node_not_ready[@]}
        do
            ssh root@$eachmachine 'reboot'
            sleep 100
        done
     #Wait for machine to come up and join the cluster
     sleep 300
     data=$(kubectl get nodes)
     #Send Slack notification post reboot
     curl -X POST -H 'Content-type: application/json' --data "{\"channel\":\"channel_name\",\"text\": \" Alert from $clustername Cluster.Auto reboot was in action. Below is the status of all the nodes at present. \`\`\`$data\`\`\`\"}" https://hooks.slack.com/services/test
else
     echo "all is well"
fi

#Check if any pvc is in pending state
if [ ! -z $PVC_Pending ] ; then
    #Check if its slowness or real issue with memory
    sleep 300
    still_pending=$(kubectl get pvc --all-namespaces | awk '{print $3}' | grep "Pending")
    #if still in pending state, reboot all nodes one by one.
    node_list=$(kubectl get nodes | grep node | awk '{print $1}' | xargs -n 1)
    data=$(kubectl get pvc --all-namespaces)
    #slack notification in case of pvc issue
    curl -X POST -H 'Content-type: application/json' --data "{\"channel\":\"channel_name\",\"text\": \" Alert from $clustername cluster. There are PVC in Pending state, Hence nodes will be rebooted as it is swap memory issue. No actions needed. Nodes will be auto rebooted. \`\`\`$data\`\`\`\"}" https://hooks.slack.com/services/test
    for eachmachine in ${node_list[@]}
        do
            ssh root@$eachmachine 'reboot'
               sleep 100
            done
     sleep 300
     data=$(kubectl get pvc --all-namespaces)
     curl -X POST -H 'Content-type: application/json' --data "{\"channel\":\"channel_name\",\"text\": \" Alert from $clustername cluster. Below are the status of PVC post reboot. Please retrigger any failed component tests in concourse. \`\`\`$data\`\`\`\"}" https://hooks.slack.com/services/test
else
     echo "all is well"
fi
