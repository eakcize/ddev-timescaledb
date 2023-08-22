#!/usr/bin/env bash
#ddev-generated

FS_CONTAINER_NAME="ddev-$FILLER_SERVICE_PROJECT_NAME-mongo"
FS_CONTAINER_ID=$(docker ps -aqf "name=$FS_CONTAINER_NAME")
TSDB_CONTAINER_ID=$(docker ps -aqf "name=ddev-$DASHBOARD_API_PROJECT_NAME-timescaledb")


if [ -z "$FS_CONTAINER_ID" ]; then
  echo "$FS_CONTAINER_NAME container not found or active."
  exit 1
fi

docker cp "$D/../../scripts/tsdb-mongo.bash" "$TSDB_CONTAINER_ID:/tmp/mongo.bash"
docker exec --user postgres "$TSDB_CONTAINER_ID" bash -c "/tmp/mongo.bash '$FS_CONTAINER_NAME' '$FILLER_SERVICE_DATABASE_NAME'"
