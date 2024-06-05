#!/bin/bash
apt update && apt install -y wget default-jdk
wget -O metabase.jar https://downloads.metabase.com/v0.49.13/metabase.jar
java -jar metabase.jar
