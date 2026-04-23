# syntax=docker/dockerfile:1

FROM debian:trixie-slim AS base

SHELL ["/bin/bash", "-eux", "-o", "pipefail", "-c"]

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked --mount=target=/var/cache/apt,type=cache,sharing=locked <<EOF
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -q
    apt-get install -y apt-transport-https ca-certificates curl gnupg
    mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' > /etc/apt/sources.list.d/kubernetes.list
    chmod 644 /etc/apt/sources.list.d/kubernetes.list
EOF

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked --mount=target=/var/cache/apt,type=cache,sharing=locked <<EOF
    apt-get update
    apt-get install -y kubectl
EOF

COPY --chmod=755 script.sh /usr/local/bin/fix-clickhouse-pvs

ENV NAMESPACE=clickhouse
CMD ["/usr/local/bin/fix-clickhouse-pvs"]
