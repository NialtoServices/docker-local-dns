# Docker Local DNS

A lightweight Alpine Linux container running [dnsmasq](https://dnsmasq.org) that proxies DNS queries to Docker's embedded DNS server (`127.0.0.11`).

## Why?

Docker Compose projects use custom bridge networks where Docker provides DNS resolution at `127.0.0.11` on the loopback interface. When running containers with [gVisor](https://gvisor.dev) (`runsc` runtime), the sandbox isolates the container's network from the host, preventing access to `127.0.0.11`. This means containers on the `runsc` runtime cannot resolve any DNS queries, breaking both container name resolution and access to external hosts.

This container runs on the standard `runc` runtime with a static IP, acting as a DNS proxy. Containers running on `runsc` can point their DNS at this container's static IP, which then forwards queries to Docker's DNS server on their behalf.

## Usage

Add the container to your Compose project and assign it a static IP on a custom network. Then configure your `runsc` containers to use it as their DNS server via a custom `resolv.conf`.

### Docker Compose

```yaml
networks:
  default:
    ipam:
      config:
        - subnet: 172.31.0.0/24
          ip_range: 172.31.0.128/25

services:
  dns:
    image: ghcr.io/nialtoservices/local-dns:latest
	cap_drop:
	  - ALL
	mem_limit: 16m
	read_only: true
	restart: unless-stopped
	security_opt:
	  - no-new-privileges:true
	environment:
	  - TZ
    networks:
      default:
        ipv4_address: 172.31.0.2

  app:
    image: your-app:latest
    runtime: runsc
    depends_on:
      - dns
    volumes:
      - ./resolv.conf:/etc/resolv.conf:ro
```

### resolv.conf

Create a `resolv.conf` file that points to the DNS container's static IP:

```
nameserver 172.31.0.2
```

Mount this file into any `runsc` container that needs DNS resolution.

## How it works

The container runs dnsmasq configured to forward all DNS queries to `127.0.0.11` (Docker's embedded DNS server). Since this container runs on the standard `runc` runtime, it has access to the host network's loopback interface and can reach Docker's DNS. Containers on the `runsc` runtime send their DNS queries to this container's static IP instead.

## License

This project is licensed under the Apache-2.0 License - see the LICENSE file for details.
