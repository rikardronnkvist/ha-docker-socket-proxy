FROM haproxy:3.2.4-alpine

# Install jq for parsing Home Assistant config
RUN apk add --no-cache jq

EXPOSE 2375
COPY docker-entrypoint.sh /usr/local/bin/
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg.template
RUN touch /var/lib/haproxy/server-state && \
    chmod +x /usr/local/bin/docker-entrypoint.sh
USER root
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["haproxy", "-f", "/tmp/haproxy.cfg"]
