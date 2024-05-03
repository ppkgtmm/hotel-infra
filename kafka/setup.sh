apt update
apt install -y wget default-jdk
wget -O kafka.tgz https://dlcdn.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz
tar xzf kafka.tgz
cd kafka_2.13-3.7.0
bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c config/kraft/server.properties
bin/kafka-server-start.sh config/kraft/server.properties
