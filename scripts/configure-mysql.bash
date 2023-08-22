#!/usr/bin/env bash
#ddev-generated

DAPI_CONTAINER_NAME="ddev-$DASHBOARD_API_PROJECT_NAME-db"
DAPI_CONTAINER_ID=$(docker ps -aqf "name=$DAPI_CONTAINER_NAME")
TSDB_CONTAINER_ID=$(docker ps -aqf "name=ddev-$DASHBOARD_API_PROJECT_NAME-timescaledb")

if [ -z "$DAPI_CONTAINER_ID" ]; then
  echo "$DAPI_CONTAINER_NAME container not found or active."
  exit 1
fi

docker cp "$D/../../scripts/tsdb-mysql.bash" "$TSDB_CONTAINER_ID:/tmp/mysql.bash"
docker exec --user postgres "$TSDB_CONTAINER_ID" bash -c "/tmp/mysql.bash '$DAPI_CONTAINER_NAME' '$DASHBOARD_API_DATABASE_NAME'"

