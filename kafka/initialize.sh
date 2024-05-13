apt update && apt install -y wget default-jdk
wget -O kafka.tgz https://dlcdn.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz
tar xzf kafka.tgz && cd kafka_2.13-3.7.0
wget -O config.properties https://github.com/ppkgtmm/hotel-infra/raw/main/kafka/kafka.properties
cat >> config.properties <<EOF
node.id=${NODE_ID}
controller.quorum.voters=${VOTERS}
EOF
bin/kafka-storage.sh format -t ${KAFKA_CLUSTER_ID} -c config.properties
bin/kafka-server-start.sh config.properties
