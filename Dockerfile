# syntax=docker/dockerfile:1
#
# Copyright 2026 Nialto Services Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ARG ALPINE_VERSION=3.23

FROM alpine:${ALPINE_VERSION}

LABEL org.opencontainers.image.description="A lightweight DNS proxy for Docker Compose projects using gVisor (runsc), forwarding queries to Docker's embedded DNS server."
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.source="https://github.com/NialtoServices/docker-local-dns"

RUN apk update --no-cache
RUN apk add --no-cache bind-tools dnsmasq tini

COPY dnsmasq.conf /etc/dnsmasq.conf

EXPOSE 53/udp
EXPOSE 53/tcp

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/usr/sbin/dnsmasq", "--keep-in-foreground", "--log-facility=-"]
