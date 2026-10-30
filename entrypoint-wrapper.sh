#!/bin/bash
set -e

# Background initializer: waits for Neo4j Bolt to come online and seeds initial graph data if not yet seeded
(
  NEO4J_USER="neo4j"
  NEO4J_PASS="${NEO4J_PASSWORD:-!Honda_cbr650r}"
  if [[ -n "$NEO4J_AUTH" && "$NEO4J_AUTH" != "none" ]]; then
    NEO4J_USER="${NEO4J_AUTH%%/*}"
    NEO4J_PASS="${NEO4J_AUTH#*/}"
  fi

  echo "[WayMate Neo4j] Waiting for Neo4j Bolt (7687) to accept connections..."
  until cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASS" "RETURN 1;" >/dev/null 2>&1; do
    sleep 2
  done

  SEEDED=$(cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASS" --format plain "MATCH (s:SeedMeta {id: 'waymate-seed-v1'}) RETURN count(s);" | tail -n 1 | tr -d '[:space:]')
  if [[ "$SEEDED" == "0" && -f /init/init.cypher ]]; then
    echo "[WayMate Neo4j] Seeding initial WayMate graph data..."
    cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASS" -f /init/init.cypher >/dev/null
    echo "[WayMate Neo4j] Database seeding completed successfully!"
  else
    echo "[WayMate Neo4j] Database seed already complete. Skipping seed."
  fi

  touch /tmp/neo4j_ready
) &

exec /startup/docker-entrypoint.sh neo4j
