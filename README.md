# ScyllaDB for Railway (Fixed)

Deploy ScyllaDB on Railway with working external CQL connections.

## Quick Deploy

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/scylladb)

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SMP` | `2` | Number of CPU cores to use |
| `MEM` | `2G` | Memory allocation |
| `OVERPROV` | `1` | Overprovisioned mode (1=enabled) |
| `API_ADDR` | `::` | API listen address (IPv6) |
| `LISTEN_ADDR` | `::` | CQL listen address (IPv6) |
| `RPC_ADDR` | `::` | RPC address |
| `BROADCAST_RPC_ADDRESS` | Auto | **IMPORTANT**: Set to `${{RAILWAY_TCP_PROXY_DOMAIN}}` |
| `AUTH_SUPERUSER_NAME` | `cassandra` | Superuser username |
| `AUTH_SUPERUSER_SHA512_PASSWORD` | (default) | SHA512 hashed password |
| `SCYLLA_PASSWORD` | - | Plaintext password (for reference) |
| `SEEDS` | `::` | Seed nodes |

## Required Railway Configuration

### 1. TCP Proxy Setup

In Railway Dashboard → ScyllaDB Service → Settings → Networking:

- Enable **Public Networking**
- Add TCP Proxy for **port 9042** (CQL native transport)
- Note the assigned external port

### 2. Environment Variables

Set these variables in Railway:

```
BROADCAST_RPC_ADDRESS=${{RAILWAY_TCP_PROXY_DOMAIN}}
AUTH_SUPERUSER_NAME=cassandra
AUTH_SUPERUSER_SHA512_PASSWORD=<your-sha512-hash>
SCYLLA_PASSWORD=<your-plaintext-password>
```

Generate SHA512 hash:
```bash
openssl passwd -6 "YourPassword"
```

### 3. Reference Variables

Railway auto-generates these for your other services:

```
SCYLLA_HOST=${{RAILWAY_TCP_PROXY_DOMAIN}}
SCYLLA_PORT=${{RAILWAY_TCP_PROXY_PORT}}
SCYLLA_PRIVATE_HOST=${{RAILWAY_PRIVATE_DOMAIN}}
SCYLLA_PRIVATE_PORT=9042
```

## Connecting

External connection (from outside Railway):
```bash
cqlsh <SCYLLA_HOST> <SCYLLA_PORT> -u cassandra -p <password>
```

Internal connection (from Railway private network):
```bash
cqlsh <service-name>.railway.internal 9042
```

## Why v5.1.4?

ScyllaDB versions newer than 5.1.4 have broken IPv6 support, which is required for Railway's private networking.

See: https://github.com/scylladb/scylladb/issues/14738
