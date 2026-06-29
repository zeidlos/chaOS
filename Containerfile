# Each build stage gets its own ctx so changing one script does not bust
# the cache of the others.
FROM scratch AS ctx-repos
COPY build_files/repos.sh /

FROM scratch AS ctx-packages
COPY build_files/packages.sh /

FROM scratch AS ctx-binaries
COPY build_files/binaries.sh /

FROM scratch AS ctx-config
COPY build_files/config.sh /
COPY system_files /system_files

# Base Image
FROM quay.io/fedora-ostree-desktops/cosmic-atomic:44
## Other possible base images:
# FROM ghcr.io/ublue-os/bazzite:testing
# FROM ghcr.io/ublue-os/aurora:stable
# FROM ghcr.io/ublue-os/bluefin-nvidia-open:stable
#
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:44
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### [IM]MUTABLE /opt
## Uncomment if packages write to /opt and it gets wiped on deploy
## (e.g. google-chrome, docker-desktop):
# RUN rm /opt && mkdir /opt

# Inject sandbox proxy CA if building behind a TLS-intercepting proxy.
# Usage: podman build --build-arg PROXY_CA="$(cat /path/to/ca.crt)" ...
ARG PROXY_CA=""
RUN if [[ -n "${PROXY_CA}" ]]; then \
      printf '%s' "${PROXY_CA}" > /etc/pki/ca-trust/source/anchors/proxy-ca.crt && \
      update-ca-trust; \
    fi

# Stage 1: Enable repos — re-runs only when repos.sh changes
RUN --mount=type=bind,from=ctx-repos,source=/,target=/ctx \
    --mount=type=cache,id=dnf,dst=/var/cache \
    /ctx/repos.sh

# Stage 2: Install packages — re-runs only when packages.sh changes
RUN --mount=type=bind,from=ctx-packages,source=/,target=/ctx \
    --mount=type=cache,id=dnf,dst=/var/cache \
    --mount=type=cache,id=dnf-log,dst=/var/log \
    /ctx/packages.sh

# Stage 3: Install pinned binaries — re-runs only when binaries.sh changes
RUN --mount=type=bind,from=ctx-binaries,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/binaries.sh

# Stage 4: System configuration — re-runs only when config.sh or system_files/ change
RUN --mount=type=bind,from=ctx-config,source=/,target=/ctx \
    /ctx/config.sh

### LINTING
RUN bootc container lint
