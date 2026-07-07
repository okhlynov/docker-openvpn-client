# Squid Proxy with AmneziaWG

## Overview
This project sets up a Squid proxy server that routes traffic through an AmneziaWG VPN client. AmneziaWG is a WireGuard-based VPN protocol with built-in obfuscation capabilities designed to bypass Deep Packet Inspection (DPI) and censorship while maintaining WireGuard's performance and security benefits.

The architecture uses two Docker containers:
- **AmneziaWG client** (`amneziawg`) - Establishes the VPN tunnel
- **Squid proxy** - Shares the VPN client's network namespace, routing all proxy traffic through the VPN

Squid is reachable from the Docker host at `http://127.0.0.1:3128`. The port is intentionally bound to localhost only.

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

1. Set your proxy settings to `http://127.0.0.1:3128`.

2. Verify the proxy is working:
    ```sh
    curl --proxy http://127.0.0.1:3128 http://ifconfig.co
    ```

3. Verify proxy egress geolocation (country/city/ASN):
    ```sh
    curl --proxy http://127.0.0.1:3128 -s https://ipwho.is | sed 's/,/\n/g' | grep -E '"ip"|"country"|"region"|"city"|"latitude"|"longitude"|"org"|"connection"'
    ```

## Troubleshooting

Check container state and logs:
```sh
docker compose ps
docker compose logs -f awg-client squid
```

Check VPN connection status:
```sh
docker exec -it amneziawg awg show
docker exec -it amneziawg awg show awg0
```

Check IPv4 egress inside the VPN network namespace:
```sh
docker exec -it amneziawg wget -4 -qO- http://ifconfig.co
```

If this command fails, the problem is below Squid: inspect the tunnel config, routes, policy rules, and DNS inside the `amneziawg` namespace:
```sh
docker exec -it amneziawg ip addr
docker exec -it amneziawg ip route
docker exec -it amneziawg ip rule
docker exec -it amneziawg cat /etc/resolv.conf
```

Check whether Squid is listening inside the shared network namespace:
```sh
docker exec -it amneziawg ss -ltnp 'sport = :3128'
```

If Squid is listening and `wget` works inside `amneziawg`, but the host proxy call fails, inspect Docker port publishing:
```sh
docker port amneziawg 3128
docker inspect amneziawg --format '{{json .NetworkSettings.Ports}}'
curl -v --proxy http://127.0.0.1:3128 http://ifconfig.co
```

On Docker 29, also check the firewall backend if port publishing behaves differently from older hosts:
```sh
docker info --format '{{.FirewallBackend}}'
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
