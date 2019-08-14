#!/bin/bash

# Install java
apt-get update && apt-get upgrade
apt-get install -y software-properties-common
add-apt-repository ppa:webupd8team/java
apt-get install -y oracle-java8-installer
echo `java -version`


# Download packages
cd ~
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.3.0-amd64.deb
wget https://artifacts.elastic.co/downloads/kibana/kibana-7.3.0-amd64.deb
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.3.0-amd64.deb


# Extract
dpkg -i elasticsearch-7.3.0-amd64.deb
dpkg -i kibana-7.3.0-amd64.deb
dpkg -i filebeat-7.3.0-amd64.deb


# Execute
cd ~/elasticsearch-7.3.0-amd64 && bin/elasticsearch
cd ~/kibana-7.3.0-amd64 && bin/kibana
cd ~/filebeat-7.3.0-amd64 && ./filebeat setup -e


# Create pod
kubectl create -f filebeat-kubernetes.yml

echo 'Done!'
