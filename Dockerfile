FROM haproxy:3.2.4-alpine

EXPOSE 2375
ENV ALLOW_RESTARTS=0 \
    ALLOW_STOP=0 \
    ALLOW_START=0 \
    AUTH=0 \
    BUILD=1 \
    COMMIT=1 \
    CONFIGS=1 \
    CONTAINERS=1 \
    DISABLE_IPV6=0 \
    DISTRIBUTION=1 \
    EVENTS=1 \
    EXEC=0 \
    GRPC=0 \
    IMAGES=1 \
    INFO=1 \
    LOG_LEVEL=info \
    NETWORKS=1 \
    NODES=1 \
    PING=1 \
    PLUGINS=1 \
    POST=0 \
    SECRETS=0 \
    SERVICES=1 \
    SESSION=1 \
    SOCKET_PATH=/var/run/docker.sock \
    SWARM=1 \
    SYSTEM=1 \
    TASKS=0 \
    VERSION=1 \
    VOLUMES=1
COPY docker-entrypoint.sh /usr/local/bin/
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg.template
RUN touch /var/lib/haproxy/server-state
USER root
CMD ["haproxy", "-f", "/tmp/haproxy.cfg"]
