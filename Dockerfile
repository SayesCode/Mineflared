FROM ubuntu:latest

COPY ..

RUN chmod +x ./start.sh

CMD ["bash", "start.sh"]
