FROM openjdk:8-buster

ENV KE_HOME=/opt/kafka-eagle
ENV EAGLE_VERSION=2.0.5
# Set config defaults
ENV KAFKA_EAGLE_CLUSTER_ZK_LIST=zookeeper:2181
ENV KAFKA_EAGLE_CLUSTER_KAFKA_EAGLE_BROKER_SIZE=1
ENV KAFKA_EAGLE_KAFKA_ZK_LIMIT_SIZE=25
ENV KAFKA_EAGLE_WEBUI_PORT=8048
ENV KAFKA_EAGLE_CLUSTER_KAFKA_EAGLE_OFFSET_STORAGE=kafka
ENV KAFKA_EAGLE_METRICS_CHARTS=false
ENV KAFKA_EAGLE_METRICS_RETAIN=30
ENV KAFKA_EAGLE_SQL_FIX_ERROR=false
ENV KAFKA_EAGLE_SQL_TOPIC_RECORDS_MAX=5000
ENV KAFKA_EAGLE_TOPIC_TOKEN=keadmin
ENV KAFKA_EAGLE_CLUSTER_KAFKA_EAGLE_SASL_ENABLE=false
ENV KAFKA_EAGLE_CLUSTER_KAFKA_EAGLE_SASL_PROTOCOL=SASL_PLAINTEXT
ENV KAFKA_EAGLE_CLUSTER_KAFKA_EAGLE_SASL_MECHANISM=SCRAM-SHA-256
ENV KAFKA_EAGLE_CLUSTER_KAFKA_EAGLE_SASL_JAAS_CONFIG='org.apache.kafka.common.security.scram.ScramLoginModule required username="admin" password="admin-secret";'
ENV KAFKA_EAGLE_CLUSTER_KAFKA_EAGLE_SASL_CGROUP_ENABLE=false
ENV KAFKA_EAGLE_CLUSTER_KAFKA_EAGLE_SASL_CGROUP_TOPICS=kafka_ads01,kafka_ads02
ENV KAFKA_EAGLE_DB_DRIVER=org.sqlite.JDBC
ENV KAFKA_EAGLE_DB_USERNAME=root
ENV KAFKA_EAGLE_DB_PASSWORD=smartloli
ENV KAFKA_EAGLE_DB_URL=jdbc:sqlite:/hadoop/kafka-eagle/db/ke.db


ADD system-config.properties /tmp
ADD entrypoint.sh /usr/bin

#RUN apk --update add wget gettext tar bash sqlite
RUN apt-get update && apt-get install -y sqlite gettext

#get and unpack kafka eagle
RUN mkdir -p /opt/kafka-eagle/conf;cd /opt && \
    wget https://github.com/smartloli/kafka-eagle-bin/archive/v${EAGLE_VERSION}.tar.gz && \
    tar zxvf v${EAGLE_VERSION}.tar.gz -C kafka-eagle --strip-components 1 && \
    cd kafka-eagle;tar zxvf kafka-eagle-web-${EAGLE_VERSION}-bin.tar.gz --strip-components 1 && \
    rm kafka-eagle-web-${EAGLE_VERSION}-bin.tar.gz && \
    chmod +x /opt/kafka-eagle/bin/ke.sh && \
    mkdir -p /hadoop/kafka-eagle/db

EXPOSE 8048 8080

ENTRYPOINT ["entrypoint.sh"]

WORKDIR /opt/kafka-eagle


