FROM openjdk:17-jdk

COPY . /root
WORKDIR /root

RUN chmod +x ./start.sh

CMD ["bash", "start.sh"]
