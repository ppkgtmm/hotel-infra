#!/bin/bash
apt update && apt install -y wget default-jdk
wget -O debezium-server.tar.gz https://repo1.maven.org/maven2/io/debezium/debezium-server-dist/2.6.1.Final/debezium-server-dist-2.6.1.Final.tar.gz
tar xzf debezium-server.tar.gz
cd debezium-server && mkdir -p data/
wget -O application.properties https://github.com/ppkgtmm/hotel-infra/raw/main/data-streaming/debezium/application.properties
cat >> application.properties <<EOF
debezium.sink.pubsublite.project.id=${GCP_PROJECT_ID}
debezium.sink.pubsublite.region=${GCP_ZONE}
debezium.source.database.hostname=${DB_HOST}
debezium.source.database.user=${DB_USER}
debezium.source.database.password=${DB_PASSWORD}
debezium.source.database.dbname=${DB_NAME}
debezium.source.topic.prefix=${DB_NAME}
EOF
mv application.properties conf/
chmod +x run.sh && ./run.sh
