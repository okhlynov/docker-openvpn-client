# HTTP and SOCKS5 Proxies with AmneziaWG

## Overview

This project runs two local proxy servers whose traffic is routed through an AmneziaWG VPN client:

- **AmneziaWG client** establishes the VPN tunnel.
- **Squid** provides an HTTP proxy.
- **Dante** provides a SOCKS5 proxy for TCP connections.

Squid and Dante share the AmneziaWG client's network namespace, so their outbound traffic uses the VPN tunnel.

Both proxies are intentionally published on localhost only:

- HTTP: `http://127.0.0.1:3128`
- SOCKS5: `socks5://127.0.0.1:1080`

Dante starts only after the AmneziaWG healthcheck succeeds, because its configuration uses the `awg0` interface.

## Prerequisites

- Docker
- Docker Compose
- An AmneziaWG configuration file at `$project_root/local/wg_confs/awg0.conf`

## Setup

1. Initialize the git submodule:

    ```sh
    git submodule update --init --recursive
    ```

2. Place your AmneziaWG configuration file at `local/wg_confs/awg0.conf`.

   See the [AmneziaWG submodule documentation](./docker-amneziawg/README.md) for tunnel configuration and obfuscation parameters.

3. Build and start the services:

    ```sh
    docker compose build
    docker compose up -d
    ```

4. Optionally use the Makefile wrapper:

    ```sh
    make build
    make up
    ```

   The wrapper tries `docker compose` first and falls back to `docker-compose`.

## Usage

Verify the HTTP proxy:

```sh
curl --proxy http://127.0.0.1:3128 http://ifconfig.co
```

Verify the SOCKS5 proxy:

```sh
curl --proxy socks5h://127.0.0.1:1080 http://ifconfig.co
```

Use `socks5h` when the destination hostname should be resolved through the proxy. With `socks5`, curl resolves the hostname locally before connecting to the proxy.

Verify proxy egress geolocation:

```sh
curl --proxy socks5h://127.0.0.1:1080 -s https://ipwho.is | sed 's/,/\n/g' | grep -E '"ip"|"country"|"region"|"city"|"latitude"|"longitude"|"org"|"connection"'
```

The initial Dante configuration supports unauthenticated TCP `CONNECT` requests. UDP forwarding is not enabled.

## Troubleshooting

Check container state and logs:

```sh
docker compose ps
docker compose logs -f awg-client squid dante
```

Check the VPN connection:

```sh
docker exec -it amneziawg awg show
docker exec -it amneziawg awg show awg0
```

Check IPv4 egress inside the VPN network namespace:

```sh
docker exec -it amneziawg wget -4 -qO- http://ifconfig.co
```

If this fails, inspect the tunnel, routes, policy rules, and DNS:

```sh
docker exec -it amneziawg ip addr
docker exec -it amneziawg ip route
docker exec -it amneziawg ip rule
docker exec -it amneziawg cat /etc/resolv.conf
```

Check both proxy listeners in the shared network namespace:

```sh
docker exec -it amneziawg ss -ltnp '( sport = :3128 or sport = :1080 )'
```

Check Docker port publishing:

```sh
docker port amneziawg
docker inspect amneziawg --format '{{json .NetworkSettings.Ports}}'
```

On Docker 29, also check the firewall backend if published ports behave differently from older hosts:

```sh
docker info --format '{{.FirewallBackend}}'
```

## Stopping the Services

```sh
docker compose down
```

Or:

```sh
make down
```

## Additional Resources

- [AmneziaWG Docker implementation](./docker-amneziawg/README.md)
- [AmneziaWG protocol](https://github.com/amnezia-vpn/amnezia-client)
- [Dante SOCKS server](https://www.inet.no/dante/)
