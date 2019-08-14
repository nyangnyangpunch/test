#!/bin/bash

# Checking permission
sudo -n true
if [ $? -ne 0 ]
    then
        echo "Check your permission"
        exit
fi

dependency_check_deb() {
java -version
if [ $? -ne 0 ]
    then
        sudo apt-get install openjdk-8-jre-headless -y
    elif [ "`java -version 2> /tmp/version && awk '/version/ { gsub(/"/, "", $NF); print ( $NF < 1.8 ) ? "YES" : "NO" }' /tmp/version`" == "YES" ]
        then
            sudo apt-get install openjdk-8-jre-headless -y
fi
}

dependency_check_rpm() {
    java -version
    if [ $? -ne 0 ]
        then
            sudo yum install jre-1.8.0-openjdk -y
        elif [ "`java -version 2> /tmp/version && awk '/version/ { gsub(/"/, "", $NF); print ( $NF < 1.8 ) ? "YES" : "NO" }' /tmp/version`" == "YES" ]
            then
                sudo yum install jre-1.8.0-openjdk -y
    fi
}

debian_elk() {
    sudo apt-get update
    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/logstash/logstash-6.0.0-rc2.deb
    sudo dpkg -i /opt/logstash-6.0.0-rc2.deb
    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.0.0-rc2.deb
    sudo dpkg -i /opt/elasticsearch-6.0.0-rc2.deb
    sudo apt-get install apt-transport-https
    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/kibana/kibana-6.0.0-rc2-amd64.deb
    sudo dpkg -i /opt/kibana-6.0.0-rc2-amd64.deb

    sudo systemctl restart logstash
    sudo systemctl enable logstash
    sudo systemctl restart elasticsearch
    sudo systemctl enable elasticsearch
    sudo systemctl restart kibana
    sudo systemctl enable kibana
}

rpm_elk() {
    sudo yum install wget -y
    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/logstash/logstash-6.0.0-rc2.rpm
    sudo rpm -ivh /opt/logstash-6.0.0-rc2.rpm
    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.0.0-rc2.rpm
    sudo rpm -ivh /opt/elasticsearch-6.0.0-rc2.rpm
    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/kibana/kibana-6.0.0-rc2-linux-x86_64.tar.gz
    sudo tar zxf /opt/kibana-6.0.0-rc2-linux-x86_64.tar.gz -C /opt/

    # Starting Services
    sudo service logstash start
    sudo service elasticsearch start
    sudo /opt/kibana-6.0.0-rc2-linux-x86_64/bin/kibana &
}

# Install ELK Stack
if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]
    then
        echo "Target: Debian based system"
        dependency_check_deb
        debian_elk
        
        
elif [ "$(grep -Ei 'fedora|redhat|centos' /etc/*release)" ]
    then
        echo "Target: RedHat based system."
        dependency_check_rpm
        rpm_elk
else
    echo "Can't not install ELK on your OS."
fi
