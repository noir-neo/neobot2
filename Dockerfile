FROM litaio/lita
MAINTAINER Shoma SATO <noir.neo.04@gmail.com>

RUN apt-get update \
    && apt-get install -y git libssl-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
