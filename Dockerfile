FROM ubuntu:latest

COPY . /app
WORKDIR /app

RUN chmod +x ./start.sh

CMD ["bash", "build.sh"]
