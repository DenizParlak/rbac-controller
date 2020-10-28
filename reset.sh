#!/usr/bin/env bash


if [ $# -lt 3 ]
then
  echo "Usage: ./reset.sh <user-group> <kubeconfig-cluster-folder> <access-type>"
  exit 0
fi


USER_GROUP=$1
KUBECONFIG_FOLDER=$2
ACCESS_TYPE=$3


export NAME_OF_CSR="$KUBECONFIG_FOLDER$USER_GROUP-$ACCESS_TYPE-csr"

kubectl delete csr "$NAME_OF_CSR"

kubectl get po --all-namespaces 

kubectl delete clusterrole "role-$KUBECONFIG_FOLDER$USER_GROUP-$ACCESS_TYPE"

kubectl delete clusterrolebinding "rolebinding-$KUBECONFIG_FOLDER$USER_GROUP-$ACCESS_TYPE"


rm -rf ./$KUBCONFIG_CLUSTER_FOLDER/$USER_GROUP/*

// CLUSTER LEVEL -- fargate? - deniz
