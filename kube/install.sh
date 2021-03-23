#!/usr/bin/env bash

ENVIRONMENT="dev"

if [[ ! -z $1 ]]; then
  ENVIRONMENT=$1
fi

echo "Environment: $ENVIRONMENT"

if [[ -z $2 ]]; then
  echo "You should define namespace!"
  echo "usage: $ ./install.sh ENVIRONMENT NAMESPACE APPLICATION"
  exit
fi

if [[ -z $4 ]]; then
  if [[ ! -z $3 ]]; then
    echo "Updating $3"
    helm upgrade --timeout 600 --debug --wait --atomic --install --namespace $2 $3 --values config/$ENVIRONMENT/$3/values.yaml ./charts/$3
    exit
  fi
fi


if [[ $4 -eq "template" ]]; then
  helm template --namespace $2 $3 --values config/$ENVIRONMENT/$3/values.yaml ./charts/$3
  exit
fi
