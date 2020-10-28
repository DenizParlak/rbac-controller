#!/usr/bin/env bash

if [ $# -lt 3 ]
then
  echo "Usage: ./run.sh  <user-group> <access-type> <kubeconfig-cluster-folder>"
  exit 0
fi

//// terraform bound





////

USER_GROUP=$1
ACCESS_TYPE=$2
KUBECONFIG_FOLDER=$3

export BASE64_CSR=$(cat ./$KUBECONFIG_FOLDER/$USER_GROUP/jim.csr | base64 | tr -d '\n')
export CSR="$KUBECONFIG_FOLDER-$USER_GROUP-$ACCESS_TYPE-csr"

cat ./resources/csr.yaml | envsubst > ./$KUBECONFIG_FOLDER/$USER_GROUP/csr.yaml


cat ./resources/csr.yaml | envsubst | kubectl apply -f -

kubectl get csr

sleep 1

kubectl certificate approve $CSR

kubectl get csr

kubectl get csr $CSR -o jsonpath='{.status.certificate}' \
  | base64 --decode > ./$KUBECONFIG_FOLDER/$USER_GROUP/jim.crt


if [ "$ACCESS_TYPE" == "R" ]
then
  kubectl apply -f ./$KUBECONFIG_CLUSTER_FOLDER/$FOLDER_USER_GROUP/clusterRole-readonly.yaml
fi

if [ "$ACCESS_TYPE" == "RW" ]
then
  kubectl apply -f ./$KUBECONFIG_CLUSTER_FOLDER/$FOLDER_USER_GROUP/clusterRole-readwrite.yaml
fi

'
if [ "$ACCESS_TYPE" == "A" ]
then
kubectl apply -f ./$KUBECONFIG_FOLDER/admin.yaml
fi
'

kubectl apply -f ./$KUBECONFIG_FOLDER/$USER_GROUP/clusterRole-binding.yaml


export USER="jim"

# Cluster Name (get it from the current context)
export CLUSTER_NAME=$(kubectl config view --minify -o jsonpath={.current-context})

# Client certificate
export CLIENT_CERTIFICATE_DATA=$(kubectl get csr $CSR -o jsonpath='{.status.certificate}')


#export CLUSTER_CA=$(kubectl config view --raw -o json | jq -r '.clusters[] | select(.name == "'$(kubectl config current-context)'") | .cluster."certificate-authority-data"')

export CLUSTER_CA=$(kubectl config view --raw -o json | jq -r '.clusters[].cluster."certificate-authority-data"')

# API Server endpoint
#export CLUSTER_ENDPOINT=$(kubectl config view --raw -o json | jq -r '.clusters[] | select(.name == "'$(kubectl config current-context)'") | .cluster."server"')
export CLUSTER_ENDPOINT=$(kubectl config view --raw -o json | jq -r '.clusters[].cluster."server"')

cat ./resources/kubeconfig.tpl | envsubst > ./$KUBECONFIG_FOLDER/$USER_GROUP/kubeconfig


rm -rf ./$KUBECONFIG_FOLDER/$USER_GROUP/csr.cnf \
./$KUBECONFIG_FOLDER/$USER_GROUP/jim.crt \
./$KUBECONFIG_FOLDER/$USER_GROUP/jim.csr
