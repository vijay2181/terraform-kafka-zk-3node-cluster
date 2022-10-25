3 Node Zookeeper and Kafka Cluster
---------------------------------------

This document provides steps to configure 3 node zookeeper and kafka cluster on AWS using Terraform 
- 3 instances will be created, where each instance contains kafka and zookeeper

![image](https://user-images.githubusercontent.com/66196388/197682958-94a77a75-f031-4119-b36b-27a5c30b2d02.png)


### Please note the following things before you start working on this.

- install Terraform in Local/aws Server

```
sudo apt update -y
sudo apt install awscli -y
sudo apt install wget unzip

pwd
/home/ubuntu

mkdir terraform && cd terraform

touch terraform-install.sh

TER_VER=`curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d: -f2 | tr -d \"\,\v | awk '{$1=$1};1'`
sudo wget https://releases.hashicorp.com/terraform/${TER_VER}/terraform_${TER_VER}_linux_amd64.zip
sudo unzip terraform_${TER_VER}_linux_amd64.zip
sudo mv terraform /usr/local/bin/

chmod 755 terraform-install.sh
which terraform
terraform --version
 ```

 
 ```
git clone https://github.com/vijay2181/terraform-kafka-zk-3node-cluster.git
```


In variables.tf file change the variables According to your need
- ami-id
- region
- instance_type
- keypair
- username
- profile
- instance_count
- userdata files


```
terraform init
terraform plan
terraform apply
```



when all instances are up and running

```
- if we want to connect to brokers from out side world we need to use public ip in advertised.listeners=PLAINTEXT://<public_ip>:9092 
- if we want only private ip then we need to use VPN

zookeeper logs:-
================
nc -z -v <pubic_ip> 2181
cd /zk/logs
tail -n 20 zookeeper-zoo-server-ip-172-31-13-78.out

to know who is leader in zookeeper cluster:-
=============================================
/zk/bin/zkServer.sh status


to list number of brokers:-
===========================
- GOTO ANY NODE EX:- NODE1
/zk/bin/zkCli.sh -server localhost:2181

If it is successful, you can see the Zk client running as:
WATCHER::
WatchedEvent state:SyncConnected type:None path:null
[zk: localhost:2181(CONNECTED) 0]
- it is connected to broker id 0

From here you can explore the broker details using various commands:
ls /brokers/ids

[zk: localhost:2181(CONNECTED) 0] ls /brokers/ids
[0, 1, 2]

kafka logs:-
============
tail -n 20 /kafka/logs/server.log
nc -z -v <pubic_ip> 9092


create topic:-
==============
/kafka/bin/kafka-topics.sh --create --if-not-exists --bootstrap-server <public_ip>:9092 --replication-factor 3 --partitions 5 --topic vijay-test-topic

/kafka/bin/kafka-topics.sh --describe --topic vijay-test-topic --bootstrap-server <public_ip>:9092    

```

open any kafka windows client tool like offset explorer to view/manage from windows

![image](https://user-images.githubusercontent.com/66196388/197685977-54a62e3d-c071-4240-ae08-1db2f49697f7.png)



