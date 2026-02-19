#!/bin/sh

SMP="${SMP:-2}"
MEM="${MEM:-2G}"
OVERPROV="${OVERPROV:-1}"
API_ADDR="${API_ADDR:-::}"
LISTEN_ADDR="${LISTEN_ADDR:-$API_ADDR}"

# Detect container's routable IPv4 address for CQL listen address.
# gocql driver panics when system.local.rpc_address is :: or 0.0.0.0
# because these are "unspecified" addresses. Using the actual container IP
# ensures the driver can resolve a valid connect address.
CONTAINER_IPV4=$(hostname -I 2>/dev/null | tr ' ' '\n' | grep -m1 '^[0-9]')
RPC_ADDR="${RPC_ADDR:-${CONTAINER_IPV4:-0.0.0.0}}"

# BROADCAST_RPC_ADDRESS should be set to the Railway TCP proxy domain
# This is the address that CQL clients will use to connect
BROADCAST_RPC_ADDR="${BROADCAST_RPC_ADDRESS:-${RAILWAY_TCP_PROXY_DOMAIN:-$RPC_ADDR}}"

[ "$1" = "scylladb" ] && shift

#region Environment variables' default values
export SEEDS="${SEEDS:-::}"
export AUTH_SUPERUSER_NAME="${AUTH_SUPERUSER_NAME:-cassandra}"
export AUTH_SUPERUSER_SHA512_PASSWORD="${AUTH_SUPERUSER_SHA512_PASSWORD:-\$6\$F8lPuHbSJMBziP.y\$vv2dB7URHQrOq4UTNpMrKfHbN7nw6wba6dnEzSUqKKvW.hPRGz/9v1rB47uqtJoPKciIAoq/L9OYw3Uxv1Nw.y.}"
#endregion

if [ -e "/etc/scylla/scylla.template.yaml" ]; then
	envsubst < "/etc/scylla/scylla.template.yaml" > "/etc/scylla/scylla.yaml"
	cat "/etc/scylla/scylla.yaml"
fi

echo "Starting ScyllaDB with:"
echo "  SMP: $SMP"
echo "  MEM: $MEM"
echo "  LISTEN_ADDR: $LISTEN_ADDR"
echo "  RPC_ADDR: $RPC_ADDR"
echo "  BROADCAST_RPC_ADDR: $BROADCAST_RPC_ADDR"
echo "  CONTAINER_IPV4: $CONTAINER_IPV4"

/docker-entrypoint.py \
	--authorizer=AllowAllAuthorizer \
	--smp "$SMP" \
	--memory "$MEM" \
	--overprovisioned "$OVERPROV" \
	--api-address "$API_ADDR" \
	--listen-address "$LISTEN_ADDR" \
	--rpc-address "$RPC_ADDR" \
	--broadcast-rpc-address "$BROADCAST_RPC_ADDR" \
	"$@"
