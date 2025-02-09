# Squid Proxy with OpenVPN

## Overview
This project sets up a Squid proxy server that routes traffic through an OpenVPN client. It allows you to route your traffic through a VPN for added privacy and security.

## Prerequisites
- Docker
- Docker Compose
- An OpenVPN configuration file (`client.ovpn`) should be in the `$project_root/local` directory. 

## Usage

1. Build and start the services:
    ```sh
    docker compose build   
    docker compose up -d
    ```

2. Set your proxy settings to `http://localhost:3128`.

3. Verify the proxy is working:
    ```sh
    curl --proxy http://localhost:3128 http://ifconfig.co
    ```

## Troubleshooting

- Check the logs for the OpenVPN client and Squid:
    ```sh
    docker logs openvpn-client
    docker logs squid
    ```

- Ensure DNS resolution works inside the OpenVPN container:
    ```sh
    docker exec -it openvpn-client ping ifconfig.co
    ```

## Stopping the Services

To stop the services, run:
    ```sh
    docker compose down
    ```