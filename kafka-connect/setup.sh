export PLUGIN_PATH=/kafka/connect
apt update
apt install -y wget default-jdk libpq-dev postgresql-client gcc
wget -O kafka.tgz https://dlcdn.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz
tar xzf kafka.tgz
mkdir -p $PLUGIN_PATH
wget -O connector.tar.gz https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/2.6.1.Final/debezium-connector-postgres-2.6.1.Final-plugin.tar.gz
tar zxf connector.tar.gz
mv debezium-connector-postgres $PLUGIN_PATH/
cat > query.sql << EOF
CREATE USER $DBZ_USER PASSWORD '$DBZ_PASSWORD';
GRANT LOGIN TO $DBZ_USER;
GRANT rds_replication TO $DBZ_USER;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO $DBZ_USER;
GRANT CREATE ON DATABASE $DB_NAME TO $DBZ_USER;
SELECT 'ALTER TABLE "' || table_name || '" OWNER TO $DBZ_USER;' from information_schema.tables where table_schema = 'public' \gexec
EOF
psql "postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME" -f query.sql
cd kafka_2.13-3.7.0
wget -O config.properties https://github.com/ppkgtmm/hotel-infra/raw/main/kafka-connect/connect.properties
cat >> config.properties << EOF
plugin.path=$PLUGIN_PATH
bootstrap.servers=$KAFKA_SERVERS
database.hostname=$DB_HOST
database.user=$DBZ_USER
database.password=$DBZ_PASSWORD
database.dbname=$DB_NAME
topic.prefix=$DB_NAME
EOF
bin/connect-distributed.sh config.properties