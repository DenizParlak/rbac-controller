#!/usr/bin/env bash

userSet="QA|FrontEnd|Backend"
accessType="R|RW|A"
SHARED_CLUSTER="shared"
DEV_CLUSTER="dev"
PROD_CLUSTER="prod"

echoUsage()
{
    echo "Values for <user-group> : $userSet"
    echo "Values for <access-type> : $accessType"
}


assignVars()
{
  USER_GROUP="$1"
  ACCESS_TYPE="$2"
}

generate()
{


  echo "-------------------------------"
  echo "          Resetting previous changes           "
  echo "-------------------------------"
  ./reset.sh $USER_GROUP $KUBECONFIG_FOLDER $ACCESS_TYPE

  echo "-------------------------------"
  echo "          Client Cert Generation           "
  echo "-------------------------------"
  ./client.sh $USER_GROUP $ACCESS_TYPE $KUBECONFIG_FOLDER

  echo "-------------------------------"
  echo "          kubeconfig & jim.key generation          "
  echo "-------------------------------"
  ./admin.sh  $USER_GROUP $ACCESS_TYPE $KUBECONFIG_FOLDER
  echo "-------------------------------"
  echo "          Share the following files with the $USER_GROUP

          ./$KUBECONFIG_FOLDER/$FOLDER_NAMESPACE/$USER_GROUP/kubeconfig
          ./$KUBECONFIG_FOLDER/$FOLDER_NAMESPACE/$USER_GROUP/jim.key

          Initialization Steps
          $ export KUBECONFIG=\$PWD/kubeconfig

          $ kubectl config set-credentials jim \\
            --client-key=\$PWD/jim.key \\
            --embed-certs=true
          "
  echo "-------------------------------"
}


if [ `kubectl config view --raw -o json | jq -r '.clusters[].cluster."server"' | grep "mycluster" | wc -l` == "1"  ]

then
  echo "Shared cluster"
  if [ $# -lt 2 ]
  then
    echo "Usage: ./run.sh <namespace> <user-group> <access-type>"
    echoUsage
    exit 0
  fi
  assignVars "$1" "$2"


  if [ `echo "$USER_GROUP" | egrep "$userSet" | wc -l` == "0"  ]
  then

    echo "<user-group> value not as per standards."
    echoUsage
    exit 0
  fi

  if [ `echo "$ACCESS_TYPE" | egrep "$accessTypeValueSet" | wc -l` == "0"  ]
  then
    echo "<access-type> value not as per standards."
    echoUsage
    exit 0
  fi

  KUBECONFIG_FOLDER=$SHARED_CLUSTER
  generate


fi


if [ `kubectl config view --raw -o json | jq -r '.clusters[].cluster."server"' | grep "mycluster2" | wc -l` == "1"  ]
then
  echo "Dev cluster"
  if [ $# -lt 2 ]
  then
    echo "Usage: ./run.sh <namespace> <user-group> <access-type>"
    echoUsage
    exit 0
  fi
  assignVars "$1" "$2" "$3"

  if [ `echo "$USER_GROUP" | egrep "$userSet" | wc -l` QA== "0"  ]
  then
    echo "<user-group> value not as per standards."
    echoUsage
    exit 0
  fi

  if [ `echo "$ACCESS_TYPE" | egrep "$accessType" | wc -l` == "0"  ]
  then

    echo "<access-type> value not as per standards."
    echoUsage
    exit 0
  fi

  KUBECONFIG_FOLDER=$DEV_CLUSTER
  generate
fi

if [ `kubectl config view --raw -o json | jq -r '.clusters[].cluster."server"' | grep "PROD_CLUSTER" | wc -l` == "1"  ]
then
  echo "Dev cluster"
  if [ $# -lt 2 ]
  then
    echo "Usage: ./run.sh <namespace> <user-group> <access-type>"
    echoUsage
    exit 0
  fi
  assignVars "$1" "$2" "$3"

  if [ `echo "$USER_GROUP" | egrep "$userSet" | wc -l` QA== "0"  ]
  then
    echo "<user-group> value not as per standards."
    echoUsage
    exit 0
  fi

  if [ `echo "$ACCESS_TYPE" | egrep "$accessType" | wc -l` == "0"  ]
  then

    echo "<access-type> value not as per standards."
    echoUsage
    exit 0
  fi

  KUBECONFIG_FOLDER=$PROD_CLUSTER
  generate
fi
