# Dockerized OpenVPN Client with Squid Proxy

This project was forked from [`ghcr.io/wfg/openvpn-client`](https://github.com/users/wfg/packages/container/package/openvpn-client) a containerized OpenVPN client.

## Overview
This project provides a Dockerized OpenVPN client with a Squid proxy server. It allows you to route your traffic through a VPN for added privacy and security.

## Prerequisites
- Docker
- Docker Compose

## Building the Containers

### Squid Proxy Container

1. Navigate to the directory containing the Dockerfile for Squid:
    ```sh
    cd squid-build
    ```

2. Build the Squid Docker image:
    ```sh
    docker build -t squid:latest .
    ```

### OpenVPN Client Container

1. Navigate to the directory containing the Dockerfile for OpenVPN:
    ```sh
    cd ovpn-build
    ```

2. Build the OpenVPN Docker image:
    ```sh
    docker build -t openvpn-client:latest .
    ```

### Starting the Services

1. Navigate to the directory containing your docker-compose.yml:
    ```sh
    cd proxy
    ```
2. Place to the `proxy/local` `client.ovpn` file with vpn creds.

3. Start the services using Docker Compose:
    ```sh
    docker-compose up -d
    ```

### Verifying the Setup

1. Set your proxy settings to `http://localhost:3128`.

2. Verify the proxy is working:
    ```sh
    curl --proxy http://localhost:3128 http://ifconfig.co
    ```

### Stopping the Services

To stop the services, run:
```sh
docker-compose down
```