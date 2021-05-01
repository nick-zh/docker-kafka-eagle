#!/usr/bin/env bash

envsubst '$KAFKA_ZOOKEEPER_HOSTS' < "/tmp/system-config.properties" > "/opt/kafka-eagle/conf/system-config.properties"
/opt/kafka-eagle/bin/ke.sh start
tail -f /opt/kafka-eagle/kms/logs/catalina.out