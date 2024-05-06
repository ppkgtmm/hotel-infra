apt update
apt install -y wget awscli zip tar
mkdir plugin
wget -O $PLUGIN.tar.gz https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/2.6.1.Final/$PLUGIN.Final-plugin.tar.gz
tar xzf $PLUGIN.tar.gz
zip -r $PLUGIN.zip $PLUGIN
mv $PLUGIN.zip plugin/
aws s3 cp plugin s3://$S3_BUCKET/plugin --recursive --region $AWS_REGION
