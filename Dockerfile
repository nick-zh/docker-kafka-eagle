FROM maven:3.9-eclipse-temurin-17 AS builder
ENV EFAK_VERSION=5.0.0

RUN mkdir -p /build/efak;cd /build && \
    wget https://github.com/smartloli/EFAK/archive/refs/tags/v${EFAK_VERSION}.tar.gz && \
    tar zxvf v${EFAK_VERSION}.tar.gz -C efak --strip-components 1

WORKDIR /build/efak

RUN mvn dependency:go-offline -B

# Patch BrokerServiceImpl for H2 compatibility:
# H2 returns uppercase column aliases (TOTAL_COUNT) but code expects lowercase (total_count).
# Normalize Map keys to lowercase after getBrokerStats() calls.
RUN sed -i '/BrokerStats stats = new BrokerStats/i\
        if (statsMap != null) { java.util.Map<String, Object> tmp = new java.util.HashMap<>(); statsMap.forEach((k, v) -> tmp.put(k.toLowerCase(), v)); statsMap = tmp; }' \
    efak-web/src/main/java/org/kafka/eagle/web/service/impl/BrokerServiceImpl.java && \
    sed -i '/Long totalCount = null;/i\
            if (brokerStats != null) { java.util.Map<String, Object> tmp = new java.util.HashMap<>(); brokerStats.forEach((k, v) -> tmp.put(k.toLowerCase(), v)); brokerStats = tmp; }' \
    efak-web/src/main/java/org/kafka/eagle/web/service/impl/BrokerServiceImpl.java

# Create missing CSS files referenced by login/error pages.
# Main pages use /plugins/fontawesome/all.min.css, but login/error pages reference /css/font-awesome.min.css
RUN mkdir -p efak-web/src/main/resources/statics/css && \
    echo '@import url("/plugins/fontawesome/all.min.css");' > efak-web/src/main/resources/statics/css/font-awesome.min.css && \
    printf '@font-face {\n  font-family: "Inter";\n  font-style: normal;\n  font-weight: 100 900;\n  font-display: swap;\n  src: local("Inter"), local("Inter-Regular"), local("system-ui");\n}\n' > efak-web/src/main/resources/statics/css/inter-font.css

RUN mvn clean package -DskipTests -B

FROM openjdk:26-ea-17-jdk-slim

ENV KE_HOME=/opt/efak
ENV EFAK_VERSION=5.0.0

# Database config (H2 file-based)
ENV EFAK_DB_DRIVER=org.h2.Driver
ENV EFAK_DB_URL=jdbc:h2:file:/opt/efak/db/ke;MODE=MySQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_ON_EXIT=FALSE;AUTO_RECONNECT=TRUE;NON_KEYWORDS=VALUE;CASE_INSENSITIVE_IDENTIFIERS=TRUE
ENV EFAK_DB_USERNAME=SA
ENV EFAK_DB_PASSWORD=

# Redis config
ENV EFAK_REDIS_HOST=redis
ENV EFAK_REDIS_PORT=6379
ENV EFAK_REDIS_DATABASE=0
ENV EFAK_REDIS_TIMEOUT=3000ms

# Server config
ENV EFAK_SERVER_PORT=8080
ENV EFAK_TIMEZONE=GMT+8

# Default cluster config
ENV EFAK_CLUSTER_ID=cluster-1
ENV EFAK_CLUSTER_NAME=default
ENV EFAK_CLUSTER_TYPE=dev
ENV EFAK_BROKER_ID=0
ENV EFAK_BROKER_HOST=kafka
ENV EFAK_BROKER_PORT=9092
ENV EFAK_BROKER_JMX_PORT=9999

# Distributed task config
ENV EFAK_TASK_OFFLINE_TIMEOUT=120
ENV EFAK_TASK_SHARD_WAIT_TIME=30
ENV EFAK_TASK_SHARD_EXPIRE_MINUTES=10
ENV EFAK_DATA_RETENTION_DAYS=7


ADD application.yml /tmp/application.yml.template
ADD init-db.sql /tmp/init-db.sql.template
ADD entrypoint.sh /usr/bin

#RUN apk --update add wget gettext tar bash sqlite
RUN apt-get update && apt-get upgrade -y && apt-get install -y gettext

# Create kafka eagle user and group
RUN groupadd -r efak && useradd -r -g efak efak

# Create necessary directories
RUN mkdir -p /opt/efak/logs /opt/efak/config /opt/efak/db

# Copy app from builder
COPY --from=builder /build/efak/efak-web/target/KafkaEagle.jar /opt/efak/KafkaEagle.jar
COPY --from=builder /build/efak/efak-web/src/main/resources/application.yml /opt/efak/config/
COPY --from=builder /build/efak/efak-web/src/main/resources/log4j.properties /opt/efak/config/
COPY --from=builder /build/efak/efak-web/src/main/resources/sql /opt/efak/config/sql
COPY --from=builder /build/efak/efak-web/src/main/resources/statics /opt/efak/statics
COPY --from=builder /build/efak/efak-web/src/main/resources/templates /opt/efak/templates

RUN chown -R efak:efak /opt/efak

USER efak

EXPOSE 8080

ENTRYPOINT ["entrypoint.sh"]

WORKDIR /opt/efak
