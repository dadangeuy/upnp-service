# UPnP Service

🚀🌍 __Automatic Port Forwarding with Docker__

## Purpose

Add an additional tool to the toolkit of avid homelabbers or individuals who might not have direct access to port forward services on their router. Networks that support [UPnP](https://en.wikipedia.org/wiki/Universal_Plug_and_Play) will be able to expose internal services to the WAN with little effort. This project was motivated by Google WiFi not supporting port forwarding to an ARP based Virtual IP (VIP). Trying to achieve High Availability without the ability to forward to a shared VIP proves to make for a lacking homelab.

## Pulling the Container

[ghcr](https://github.com/dadangeuy/upnp-service/pkgs/container/upnp-service)

```bash
docker pull ghcr.io/dadangeuy/upnp-service:latest
```

## Usage

All settings for running the container live in the `upnp.json` file (see next section). When running the container, the `host` network needs to be attached. This is achieved with `--network host` for the `docker` command, or `network_mode: host` in compose files.

Don't forget that you need to forward ports on the host as well! (e.g., `docker run --rm -p 8080:80 nginx`.)

## Config

The config JSON lives in `/etc/upnp-service/upnp.json`. This file will need to be mounted or edited in the container, or defined via a Docker Compose `configs:` section.

The config JSON describes an array of `port forwards`, containing the `description`, `external_port`, `internal_port`, and `protocol` that will be exposed.

If the internal and external ports are the same, only one needs to be specified.

Here is a sample of the data required to run properly:

```JSON
{
  "port_forwards": [
    {
      "description": "sample-external",
      "external_port": "9991",
      "protocol": "UDP"
    },
    {
      "description": "sample-internal-and-external",
      "internal_port": "9992",
      "external_port": "9993",
      "protocol": "TCP"
    }
  ]
}
```

## Example docker-compose.yaml

This sample file deploys three `traefik/whoami` services all on different ports, and attempts to forward all of the ports using upnp-service.

The `first_whoami` service will be available on the Docker host's internal IP at port 8081, or on the Internet at your external IP on port 80. The `second_whoami` service will be available on port 8082 on the internal IP, and port 8080 on the external IP. The `third_whoami` service will be available on port 8083 on both the internal and external IPs.

Note that the internal vs external port mapping order is opposite from what Docker and Compose use.

```yaml
configs:
  upnp_json:
    content: |
      {
        "port_forwards": [
          {
            "description": "first_whoami",
            "external_port": "8081",
            "protocol": "TCP"
          },
          {
            "description": "second_whoami",
            "internal_port": "8082",
            "external_port": "8080",
            "protocol": "TCP"
          }
        ]
      }
services:
  first_whoami:
    image: traefik/whoami
    ports:
      - "8081:80"
  second_whoami:
    image: traefik/whoami
    ports:
      - "8082:80"
  upnp-service:
    image: dadangeuy/upnp-service:latest
    configs:
      - source: upnp_json
        target: /etc/upnp-service/upnp.json
    network_mode: host # works while the container runs
    build:
      context: docker-image
      network: host # works during the build if needed
```

## Building from Source

```bash
make build
```

## Additional Info

Original credit and inspiration to [ofepk's Stack Overflow answer](https://stackoverflow.com/a/54081861) detailing a basic UPnP service docker container.
