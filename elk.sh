#!/bin/bash

dependency_check_deb() {
java -version
if [ $? -ne 0 ]
    then
        apt-get install openjdk-8-jre-headless -y
    elif [ "`java -version 2> /tmp/version && awk '/version/ { gsub(/"/, "", $NF); print ( $NF < 1.8 ) ? "YES" : "NO" }' /tmp/version`" == "YES" ]
        then
            apt-get install openjdk-8-jre-headless -y
fi
}

dependency_check_rpm() {
    java -version
    if [ $? -ne 0 ]
        then
            yum install jre-1.8.0-openjdk -y
        elif [ "`java -version 2> /tmp/version && awk '/version/ { gsub(/"/, "", $NF); print ( $NF < 1.8 ) ? "YES" : "NO" }' /tmp/version`" == "YES" ]
            then
                yum install jre-1.8.0-openjdk -y
    fi
}

debian_elk() {
    apt-get update
    wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/logstash/logstash-6.0.0-rc2.deb
    dpkg -i /opt/logstash-6.0.0-rc2.deb
    wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.0.0-rc2.deb
    dpkg -i /opt/elasticsearch-6.0.0-rc2.deb
    apt-get install apt-transport-https
    wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/kibana/kibana-6.0.0-rc2-amd64.deb
    dpkg -i /opt/kibana-6.0.0-rc2-amd64.deb

    systemctl restart logstash
    systemctl enable logstash
    systemctl restart elasticsearch
    systemctl enable elasticsearch
    systemctl restart kibana
    systemctl enable kibana
}

rpm_elk() {
    yum install wget -y
    wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/logstash/logstash-6.0.0-rc2.rpm
    rpm -ivh /opt/logstash-6.0.0-rc2.rpm
    wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.0.0-rc2.rpm
    rpm -ivh /opt/elasticsearch-6.0.0-rc2.rpm
    wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/kibana/kibana-6.0.0-rc2-linux-x86_64.tar.gz
    tar zxf /opt/kibana-6.0.0-rc2-linux-x86_64.tar.gz -C /opt/

    # Starting Services
    service logstash start
    service elasticsearch start
    /opt/kibana-6.0.0-rc2-linux-x86_64/bin/kibana &
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
