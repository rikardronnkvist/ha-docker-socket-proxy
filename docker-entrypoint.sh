#!/bin/sh
set -e

# Raise default nofile limit for HAProxy v3
ulimit -n 10000 2>/dev/null || true

# Load configuration from Home Assistant if running as add-on
if [ -f /data/options.json ]; then
    # Export all options from Home Assistant config as environment variables
    export ALLOW_RESTARTS=$(jq -r '.ALLOW_RESTARTS // 0' /data/options.json)
    export ALLOW_STOP=$(jq -r '.ALLOW_STOP // 0' /data/options.json)
    export ALLOW_START=$(jq -r '.ALLOW_START // 0' /data/options.json)
    export AUTH=$(jq -r '.AUTH // 0' /data/options.json)
    export BUILD=$(jq -r '.BUILD // 1' /data/options.json)
    export COMMIT=$(jq -r '.COMMIT // 1' /data/options.json)
    export CONFIGS=$(jq -r '.CONFIGS // 1' /data/options.json)
    export CONTAINERS=$(jq -r '.CONTAINERS // 1' /data/options.json)
    export DISABLE_IPV6=$(jq -r '.DISABLE_IPV6 // 0' /data/options.json)
    export DISTRIBUTION=$(jq -r '.DISTRIBUTION // 1' /data/options.json)
    export EVENTS=$(jq -r '.EVENTS // 1' /data/options.json)
    export EXEC=$(jq -r '.EXEC // 0' /data/options.json)
    export GRPC=$(jq -r '.GRPC // 0' /data/options.json)
    export IMAGES=$(jq -r '.IMAGES // 1' /data/options.json)
    export INFO=$(jq -r '.INFO // 1' /data/options.json)
    export LOG_LEVEL=$(jq -r '.LOG_LEVEL // "info"' /data/options.json)
    export NETWORKS=$(jq -r '.NETWORKS // 1' /data/options.json)
    export NODES=$(jq -r '.NODES // 1' /data/options.json)
    export PING=$(jq -r '.PING // 1' /data/options.json)
    export PLUGINS=$(jq -r '.PLUGINS // 1' /data/options.json)
    export POST=$(jq -r '.POST // 0' /data/options.json)
    export SECRETS=$(jq -r '.SECRETS // 0' /data/options.json)
    export SERVICES=$(jq -r '.SERVICES // 1' /data/options.json)
    export SESSION=$(jq -r '.SESSION // 1' /data/options.json)
    export SOCKET_PATH=$(jq -r '.SOCKET_PATH // "/var/run/docker.sock"' /data/options.json)
    export SWARM=$(jq -r '.SWARM // 1' /data/options.json)
    export SYSTEM=$(jq -r '.SYSTEM // 1' /data/options.json)
    export TASKS=$(jq -r '.TASKS // 0' /data/options.json)
    export VERSION=$(jq -r '.VERSION // 1' /data/options.json)
    export VOLUMES=$(jq -r '.VOLUMES // 1' /data/options.json)
fi

# Normalize the input for DISABLE_IPV6 to lowercase
DISABLE_IPV6_LOWER=$(echo "$DISABLE_IPV6" | tr '[:upper:]' '[:lower:]')

# Check for different representations of 'true' and set BIND_CONFIG
case "$DISABLE_IPV6_LOWER" in
    1|true|yes)
        BIND_CONFIG=":2375"
        ;;
    *)
        BIND_CONFIG="[::]:2375 v4v6"
        ;;
esac

# Process the HAProxy configuration template using sed
sed "s/\${BIND_CONFIG}/$BIND_CONFIG/g" /usr/local/etc/haproxy/haproxy.cfg.template > /tmp/haproxy.cfg

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- haproxy "$@"
fi

if [ "$1" = 'haproxy' ]; then
	shift # "haproxy"
	# if the user wants "haproxy", let's add a couple useful flags
	#   -W  -- "master-worker mode" (similar to the old "haproxy-systemd-wrapper"; allows for reload via "SIGUSR2")
	#   -db -- disables background mode
	set -- haproxy -W -db "$@"
fi

exec "$@"
