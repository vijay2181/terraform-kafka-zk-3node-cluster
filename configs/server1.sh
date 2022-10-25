#!/bin/bash

apt update -y

sudo apt  install awscli -y

############# ZOOKEEPER PRIVATE CONFIGURATION ##############

ZOOKEEPER_VERSION=3.7.1

apt install default-jdk -y

mkdir -p /zk && useradd -r -d /zk -s /usr/sbin/nologin zoo

mkdir -p /opt/zookeeper && \
    curl "https://dlcdn.apache.org/zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz" \
    -o /opt/zookeeper/zookeeper.tar.gz && \
    mkdir -p /zk && cd /zk && \
    tar -xvzf /opt/zookeeper/zookeeper.tar.gz --strip 1

chown -R zoo:zoo /zk

sudo -u zoo mkdir -p /zk/data
sudo -u zoo mkdir -p /zk/data-log
sudo -u zoo mkdir -p /zk/logs

cat > /etc/systemd/system/zookeeper.service << EOF
[Unit]
Description=Zookeeper Daemon
Documentation=http://zookeeper.apache.org
Requires=network.target
After=network.target
[Service]
Type=forking
WorkingDirectory=/zk
User=zoo
Group=zoo
ExecStart=/bin/sh -c '/zk/bin/zkServer.sh start /zk/conf/zoo.cfg > /zk/logs/start-zk.log 2>&1'
ExecStop=/zk/bin/zkServer.sh stop /zk/conf/zoo.cfg
ExecReload=/zk/bin/zkServer.sh restart /zk/conf/zoo.cfg
TimeoutSec=30
Restart=on-failure
[Install]
WantedBy=default.target
EOF


systemctl daemon-reload
systemctl enable zookeeper

sudo cat > /zk/data/myid << EOF
1
EOF

string="$(aws ssm get-parameter --name "/test/private-ip" --query "Parameter.Value" --output text --region us-west-2)"
array=(`echo $string | sed 's/,/\n/g'`)
server1_private="$${array[0]}"
server2_private="$${array[1]}"
server3_private="$${array[2]}"

sudo cat > /zk/conf/zoo.cfg << EOF
tickTime=2000
initLimit=10
syncLimit=5
clientPort=2181
dataDir=/zk/data
dataLogDir=/zk/data-log
maxClientCnxns=60
autopurge.snapRetainCount=3
autopurge.purgeInterval=1
server.1=0.0.0.0:2888:3888
server.2=$server2_private:2888:3888
server.3=$server3_private:2888:3888
EOF




############# KAFKA PUBLIC CONFIGURATION ##############

KAFKA_VERSION=3.2.0

mkdir -p /kafka && useradd -r -d /kafka -s /usr/sbin/nologin kafka

mkdir -p /opt/kafka && \
    curl "https://archive.apache.org/dist/kafka/$KAFKA_VERSION/kafka_2.13-$KAFKA_VERSION.tgz" \
    -o /opt/kafka/kafka.tar.gz && \
    mkdir -p /kafka && cd /kafka && \
    tar -xvzf /opt/kafka/kafka.tar.gz --strip 1

chown -R kafka:kafka /kafka
sudo -u kafka mkdir -p /kafka/log
sudo -u kafka mkdir -p /kafka/logs


cat > /etc/systemd/system/kafka.service << EOF
[Unit]
Description=Apache Kafka Server
Documentation=http://kafka.apache.org/documentation.html
Requires=network.target
After=network.target
[Service]
Type=simple
WorkingDirectory=/kafka
User=kafka
Group=kafka
ExecStart=/bin/sh -c '/kafka/bin/kafka-server-start.sh /kafka/config/server.properties > /kafka/logs/start-kafka.log 2>&1'
ExecStop=/kafka/bin/kafka-server-stop.sh
TimeoutSec=30
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kafka

mv /kafka/config/server.properties /kafka/config/server.properties-backup

string="$(aws ssm get-parameter --name "/test/public-ip" --query "Parameter.Value" --output text --region us-west-2)"
array=(`echo $string | sed 's/,/\n/g'`)
server1_public="$${array[0]}"
server2_public="$${array[1]}"
server3_public="$${array[2]}"

sudo cat > /kafka/config/server.properties << EOF
broker.id=0
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/kafka/log
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=$server1_public:2181,$server2_public:2181,$server3_public:2181
zookeeper.connection.timeout.ms=18000
group.initial.rebalance.delay.ms=0
advertised.listeners=PLAINTEXT://$server1_public:9092
EOF

sudo systemctl start zookeeper
sudo systemctl start kafka