# docker-kafka-eagle
[Eagle for Apache Kafka](https://www.kafka-eagle.org/) for docker  
EFAK is an easy and high-performance Kafka monitoring system.

## Anouncement :loudspeaker:
I have created a new [dockerhub repo](https://hub.docker.com/r/nickzurich/efak) with the new name (EFAK)  
There is no hurry to migrate, i will keep kafka-eagle alive as long as there are image pulls.  
For now both repos will receive the same images / updates.

## Supported tags
You can find the pre-built docker images [on dockerhub](https://hub.docker.com/r/nickzurich/kafka-eagle)  
Supported tags are:
- [latest](https://github.com/nick-zh/docker-kafka-eagle/blob/main/Dockerfile)
- [3.0.1](https://github.com/nick-zh/docker-kafka-eagle/blob/3.0.1/Dockerfile)
- [2.1.0](https://github.com/nick-zh/docker-kafka-eagle/blob/2.1.0/Dockerfile)
- [2.0.9](https://github.com/nick-zh/docker-kafka-eagle/blob/2.0.9/Dockerfile)
- [2.0.8](https://github.com/nick-zh/docker-kafka-eagle/blob/2.0.8/Dockerfile)
- [2.0.7](https://github.com/nick-zh/docker-kafka-eagle/blob/2.0.7/Dockerfile)
- [2.0.6](https://github.com/nick-zh/docker-kafka-eagle/blob/2.0.6/Dockerfile)
- [2.0.5](https://github.com/nick-zh/docker-kafka-eagle/blob/2.0.5/Dockerfile)
- [2.0.4](https://github.com/nick-zh/docker-kafka-eagle/blob/2.0.4/Dockerfile)

## Test locally
1. Install docker and docker-compose:
2. Run the following command
```
docker-compose up
```
Then visit this url in your browser:
```
http://localhost:8048/
Test user/password:  admin/123456
```
