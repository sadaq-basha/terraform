#!/bin/bash
export PATH=$PATH:/usr/local/bin

sudo apt update
sudo apt install redis-tools mariadb-client -y
wget -O /tmp/mongo-cli.deb https://repo.mongodb.org/apt/ubuntu/dists/xenial/mongodb-org/3.6/multiverse/binary-amd64/mongodb-org-shell_3.6.14_amd64.deb
sudo dpkg -i /tmp/mongo-cli.deb
rm -rf /tmp/mongo-cli.deb