
FROM area51/node:latest

ADD babel /usr/local/babel
ADD bin /usr/local/bin/

RUN cd /usr/local/babel &&\
    npm install &&\
    chmod +x /usr/local/bin/*
