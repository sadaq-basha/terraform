#!/usr/bin/env bash

if [[ ! -z $1 ]]; then
    if [[ $2 == "dry" ]]; then
      helm3 2to3 convert --dry-run $1
      exit
    fi
  echo "Migrating $1"
  helm3 2to3 convert $1
  exit
fi