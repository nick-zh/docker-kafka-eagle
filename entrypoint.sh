#!/usr/bin/env bash
prefix="jdbc:sqlite:"
if [[ "$KAFKA_EAGLE_DB_URL" == *"$prefix"* ]]; then
  db_dir=$(echo ${KAFKA_EAGLE_DB_URL#${prefix}} | sed -e "s/\/[^\/]*$//")
  mkdir -p $db_dir
fi
envsubst < "/tmp/system-config.properties" > "/opt/kafka-eagle/conf/system-config.properties"
/opt/kafka-eagle/bin/ke.sh start
tail -f /opt/kafka-eagle/kms/logs/catalina.out