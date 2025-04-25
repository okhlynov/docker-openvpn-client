FROM alpine:3.20

RUN apk add --no-cache \
    bash \
    bind-tools \
    iptables \
    ip6tables \
    openvpn \
    wget    

COPY . /usr/local/bin

ENV KILL_SWITCH=on
RUN wget https://anticensorship.fun/files/software/obf/openvpn-2.6.12-alpine-3.20-x86_64 -O /usr/local/bin/openvpn
RUN chmod +x /usr/local/bin/openvpn

RUN apk add --no-cache libnl3 #have to install libnl3 to use openvpn here after downloading openvpn from the link above otherwise it will not work downloads was stuck
ENTRYPOINT [ "entry.sh" ]
