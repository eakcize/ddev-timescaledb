#!/usr/bin/env bash
#ddev-generated

TSDB_CONTAINER_NAME="ddev-$DASHBOARD_API_PROJECT_NAME-timescaledb"
TSDB_CONTAINER_ID=$(docker ps -aqf "name=$TSDB_CONTAINER_NAME")

if [ -z "$TSDB_CONTAINER_ID" ]; then
  echo "$TSDB_CONTAINER_ID container not found or active."
  exit 1
fi

docker cp "$D/../../scripts/tsdb.sql" "$TSDB_CONTAINER_ID:/tmp/aggregations.sql"
docker exec --user postgres "$TSDB_CONTAINER_ID" bash -c "psql -a -f /tmp/aggregations.sql"
