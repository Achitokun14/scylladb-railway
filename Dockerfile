# ScyllaDB for Railway - Fixed for external CQL connections
# We use 5.1.4 specifically because newer versions have broken IPv6 support
# See: https://github.com/scylladb/scylladb/issues/14738
FROM scylladb/scylla:5.1.4

# Install envsubst for template processing
RUN rm -rf /var/cache/apt/archives && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y gettext && \
    rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY wrapper.sh /usr/local/bin/wrapper.sh
COPY scylla.yaml /etc/scylla/scylla.template.yaml

RUN chmod +x /usr/local/bin/wrapper.sh

# Expose CQL native transport port
EXPOSE 9042

ENTRYPOINT ["/usr/local/bin/wrapper.sh"]
CMD ["scylladb"]

# Healthcheck - verify CQL is responding
# Use localhost since we're checking from inside the container
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD cqlsh localhost 9042 -e "DESCRIBE KEYSPACES" || exit 1
