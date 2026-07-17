FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends dante-server \
    && rm -rf /var/lib/apt/lists/*

COPY danted.conf /etc/danted.conf

ENTRYPOINT ["danted", "-f", "/etc/danted.conf"]
