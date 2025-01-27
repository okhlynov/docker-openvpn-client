FROM ubuntu:24.04
 
RUN \
apt -y update && \
apt -y install squid-openssl iptables iproute2  && \
rm -rf /var/lib/apt/lists/*
 
RUN \
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/CN=Squid" -keyout /etc/squid/bump.key -out /etc/squid/bump.crt
 
RUN \
cat > /etc/squid/squid.conf <<EOF
cache_effective_user proxy
cache_effective_group proxy
http_port 0.0.0.0:3128
acl step1 at_step SslBump1
http_access allow all
http_reply_access allow all
EOF
 
RUN \
mkdir /var/lib/squid && \
/usr/lib/squid/security_file_certgen -c -s /var/lib/squid/ssl_db -M 512MB  && \
chown -R proxy:proxy /var/lib/squid/ssl_db
 
ENTRYPOINT \
rm -f /run/squid.pid && \
squid -N