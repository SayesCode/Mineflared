FROM ubuntu:latest
FROM openjdk:17-jdk
FROM openjdk:17-jre

COPY .

RUN chmod +x ./start.sh

CMD ["bash", "start.sh"]
