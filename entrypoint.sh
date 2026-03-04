#!/usr/bin/env bash

# Ensure DB directory exists
mkdir -p /opt/efak/db

# Substitute env vars into application.yml
envsubst < /tmp/application.yml.template > /opt/efak/config/application.yml

# Substitute cluster env vars into init SQL (protects bcrypt $2a$10$... from corruption)
SQL_VARS='$EFAK_CLUSTER_ID $EFAK_CLUSTER_NAME $EFAK_CLUSTER_TYPE $EFAK_BROKER_ID $EFAK_BROKER_HOST $EFAK_BROKER_PORT $EFAK_BROKER_JMX_PORT'
envsubst "$SQL_VARS" < /tmp/init-db.sql.template > /opt/efak/config/sql/init-db.sql

# Set defaults for JVM and Spring Boot config
JAVA_OPTS="${JAVA_OPTS:--Xms512m -Xmx2g -XX:+UseG1GC -XX:+UseStringDeduplication -Djava.security.egd=file:/dev/./urandom}"

# Ensure log directory exists
mkdir -p /opt/efak/logs

# Launch Spring Boot application
exec java $JAVA_OPTS \
  -Dapp.name=KafkaEagle \
  -Dspring.application.name=KafkaEagle \
  -Dspring.config.location=classpath:/application.yml,file:/opt/efak/config/application.yml \
  -Dlogging.file.path=/opt/efak/logs \
  -jar /opt/efak/KafkaEagle.jar
