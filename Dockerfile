FROM openjdk:8-buster

ENV KE_HOME=/opt/kafka-eagle
ENV KAFKA_ZOOKEEPER_HOSTS=$KAFKA_ZOOKEEPER_HOSTS
ENV EAGLE_VERSION=2.0.4

ADD system-config.properties /tmp
ADD entrypoint.sh /usr/bin

#RUN apk --update add wget gettext tar bash sqlite
RUN apt-get update && apt-get install -y sqlite gettext

#get and unpack kafka eagle
RUN mkdir -p /opt/kafka-eagle/conf;cd /opt && \
    wget https://github.com/smartloli/kafka-eagle-bin/archive/v${EAGLE_VERSION}.tar.gz && \
    tar zxvf v${EAGLE_VERSION}.tar.gz -C kafka-eagle --strip-components 1 && \
    cd kafka-eagle;tar zxvf kafka-eagle-web-${EAGLE_VERSION}-bin.tar.gz --strip-components 1 && \
    chmod +x /opt/kafka-eagle/bin/ke.sh && \
    mkdir -p /hadoop/kafka-eagle/db

EXPOSE 8048 8080

ENTRYPOINT ["entrypoint.sh"]

WORKDIR /opt/kafka-eagle


