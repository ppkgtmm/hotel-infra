export PLUGIN_PATH=/kafka/connect
apt update
apt install -y wget default-jdk libpq-dev postgresql-client gcc
wget -O kafka.tgz https://dlcdn.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz
tar xzf kafka.tgz
mkdir -p $PLUGIN_PATH
wget -O connector.tar.gz https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/2.6.1.Final/debezium-connector-postgres-2.6.1.Final-plugin.tar.gz
tar zxf connector.tar.gz
mv debezium-connector-postgres $PLUGIN_PATH/
wget -O replication-setup.sh https://github.com/ppkgtmm/hotel-connector/raw/main/replication-setup.sh
chmod +x replication-setup.sh
./replication-setup.sh
psql "postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME" -f query.sql
cd kafka_2.13-3.7.0
wget -O config.properties https://github.com/ppkgtmm/hotel-infra/raw/main/kafka-connect/connect.properties
echo "plugin.path=$PLUGIN_PATH" >> config.properties
echo "bootstrap.servers=$KAFKA_SERVERS" >> config.properties
wget https://github.com/aws/aws-msk-iam-auth/releases/download/v1.1.1/aws-msk-iam-auth-1.1.1-all.jar
cp aws-msk-iam-auth-1.1.1-all.jar libs/aws-msk-iam-auth-1.1.1-all.jar
bin/connect-distributed.sh config.properties
