#!/usr/bin/env bash


USER_GROUP=$1
ACCESS_TYPE=$2
KUBECONFIG_FOLDER=$3


if [ $# -lt 3 ]
then
  echo "Usage: ./client.sh <user-group> <access-type> <kubeconfig-cluster-folder>"
  exit 0
fi

// drain 3

mkdir -p ./$KUBECONFIG_FOLDER/$USER_GROUP/

cp -rfp ./resources/csr.template ./$KUBECONFIG_FOLDER/$USER_GROUP/csr.cnf
cp -rfp ./resources/clusterRole-binding-template.yaml ./$KUBECONFIG_FOLDER/$USER_GROUP/clusterRole-binding.yaml

if [ "$ACCESS_TYPE" == "R" ]
then
  cp -rfp ./resources/clusterRole-readonly-template.yaml ./$KUBECONFIG_FOLDER/$USER_GROUP/clusterRole-readonly.yaml
fi

if [ "$ACCESS_TYPE" == "RW" ]
then
  cp -rfp ./resources/clusterRole-readwrite-template.yaml ./$KUBECONFIG_FOLDER/$USER_GROUP/clusterRole-readwrite.yaml
fi

'
if [ "$ACCESS_TYPE" == "A" ]
then
kubectl apply -f ./$KUBECONFIG_FOLDER/admin.yaml
fi
'

egrep -rl "SUBSTITUTE_GROUPNAME" ./$KUBECONFIG_FOLDER/$USER_GROUP/ | xargs sed -i  '' "s/SUBSTITUTE_GROUPNAME/$USER_GROUP/g"

egrep -rl "SUBSTITUTE_CLUSTER_NAME" ./$KUBECONFIG_FOLDER/$USER_GROUP/ | xargs sed -i  '' "s/SUBSTITUTE_CLUSTER_NAME/$KUBECONFIG_FOLDER/g"

egrep -rl "SUBSTITUTE_ACCESS_TYPE" ./$KUBECONFIG_FOLDER/$USER_GROUP/ | xargs sed -i  '' "s/SUBSTITUTE_ACCESS_TYPE/$ACCESS_TYPE/g"

mkdir -p ./$KUBECONFIG_FOLDER/$USER_GROUP/

openssl genrsa -out ./$KUBECONFIG_FOLDER/$USER_GROUP/jim.key 4096

openssl req -config ./$KUBECONFIG_FOLDER/$USER_GROUP/csr.cnf -new -key ./$KUBECONFIG_FOLDER/$USER_GROUP/jim.key -nodes -out ./$KUBECONFIG_FOLDER/$USER_GROUP/jim.csr
