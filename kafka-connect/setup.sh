export PLUGIN_PATH=/kafka/connect

apt update
apt install -y wget default-jdk
wget -O kafka.tgz https://dlcdn.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz
tar xzf kafka.tgz
mkdir -p $PLUGIN_PATH
wget -O connector.tar.gz https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/2.6.1.Final/debezium-connector-postgres-2.6.1.Final-plugin.tar.gz
tar zxf connector.tar.gz
mv debezium-connector-postgres $PLUGIN_PATH/
cd kafka_2.13-3.7.0
wget -O config.properties https://github.com/ppkgtmm/hotel-infra/raw/main/connect.properties
echo "plugin.path=$PLUGIN_PATH" >> config.properties
echo "bootstrap.servers=$SERVER:9092" >> config.properties
bin/connect-standalone.sh config.properties
