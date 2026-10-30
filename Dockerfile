# syntax=docker/dockerfile:1
FROM neo4j:5-community

# Copy initial graph seed data and entrypoint wrapper
COPY init.cypher /init/init.cypher
COPY entrypoint-wrapper.sh /init/entrypoint-wrapper.sh

# Normalize CRLF line endings from Windows and make wrapper executable
RUN sed -i 's/\r$//' /init/entrypoint-wrapper.sh /init/init.cypher \
    && chmod +x /init/entrypoint-wrapper.sh

ENV NEO4J_AUTH=neo4j/!Honda_cbr650r

EXPOSE 7474 7687

HEALTHCHECK --interval=10s --timeout=5s --start-period=20s --retries=10 \
  CMD test -f /tmp/neo4j_ready && cypher-shell -u neo4j -p '!Honda_cbr650r' 'RETURN 1;' >/dev/null 2>&1 || exit 1

ENTRYPOINT ["tini", "-g", "--", "/init/entrypoint-wrapper.sh"]

