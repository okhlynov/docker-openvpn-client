# Squid Proxy with AmneziaWG

## Overview
This project sets up a Squid proxy server that routes traffic through an AmneziaWG VPN client. AmneziaWG is a WireGuard-based VPN protocol with built-in obfuscation capabilities designed to bypass Deep Packet Inspection (DPI) and censorship while maintaining WireGuard's performance and security benefits.

The architecture uses two Docker containers:
- **AmneziaWG client** (`amneziawg`) - Establishes the VPN tunnel
- **Squid proxy** - Shares the VPN client's network namespace, routing all proxy traffic through the VPN

## Prerequisites
- Docker
- Docker Compose
- An AmneziaWG configuration directory in `$project_root/local`, with config at `$project_root/local/wg_confs/awg0.conf`

## Setup

1. Initialize the git submodule (required for AmneziaWG client):
    ```sh
    git submodule update --init --recursive
    ```

2. Place your AmneziaWG configuration file as `$project_root/local/wg_confs/awg0.conf`.

   For detailed information about AmneziaWG configuration and obfuscation parameters, see the [AmneziaWG submodule documentation](./docker-amneziawg/README.md).

3. Build and start the services:
    ```sh
    docker compose build
    docker compose up -d
    ```

4. (Optional) Use the Makefile wrapper for Docker Compose compatibility fallback:
    ```sh
    make build
    make up
    ```
   The wrapper first tries `docker compose` and automatically falls back to `docker-compose` if your local plugin path fails (for example with `unknown flag: --allow`).


## Usage

1. Set your proxy settings to `http://localhost:3128`.

2. Verify the proxy is working:
    ```sh
    curl --proxy http://localhost:3128 http://ifconfig.co
    ```

3. Verify proxy egress geolocation (country/city/ASN):
    ```sh
    curl --proxy http://localhost:3128 -s https://ipwho.is | sed 's/,/\n/g' | grep -E '"ip"|"country"|"region"|"city"|"latitude"|"longitude"|"org"|"connection"'
    ```

## Troubleshooting

- Check the logs for the AmneziaWG client and Squid:
    ```sh
    docker logs amneziawg
    docker logs squid
    ```

  Use the `-f` flag to monitor logs in real-time: `docker logs -f amneziawg`

- Check VPN connection status:
    ```sh
    docker exec -it amneziawg awg show
    ```

- Check VPN interface details:
    ```sh
    docker exec -it amneziawg awg show awg0
    ```

- Verify DNS resolution inside the VPN container:
    ```sh
    docker exec -it amneziawg curl -4 http://ifconfig.co
    ```

- Check container health status:
    ```sh
    docker compose ps
    ```

## Stopping the Services

To stop the services, run:
```sh
docker compose down
```

Or via the compatibility wrapper:
```sh
make down
```

## Additional Resources

- [AmneziaWG Docker Implementation](./docker-amneziawg/README.md) - Detailed documentation for the VPN client container
- [AmneziaWG Protocol](https://github.com/amnezia-vpn/amnezia-client) - Official AmneziaWG project
