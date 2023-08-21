#!/usr/bin/env bash
#ddev-generated

MONGO_HOST=$1
MONGO_DATABASE=$2

psql -U postgres <<EOF
-- Drop the materialized view
DROP MATERIALIZED VIEW IF EXISTS data_view;

-- Drop the foreign table
DROP FOREIGN TABLE IF EXISTS data;

-- Drop the user mapping
DROP USER MAPPING IF EXISTS FOR postgres SERVER mongo_server;

-- Drop the foreign server
DROP SERVER IF EXISTS mongo_server;
-- Create the foreign server for MongoDB
CREATE SERVER mongo_server
        FOREIGN DATA WRAPPER mongo_fdw
        OPTIONS (address '$MONGO_HOST', port '27017');

-- Create the user mapping
CREATE USER MAPPING FOR postgres
        SERVER mongo_server
        OPTIONS (username 'db', password 'db');

-- Create the foreign table that represents the MongoDB collection
CREATE FOREIGN TABLE data (
              timestamp TIMESTAMP WITH TIME ZONE,
              fuel DOUBLE PRECISION,
              water DOUBLE PRECISION,
              metadata JSON
        )
        SERVER mongo_server
        OPTIONS (database '$MONGO_DATABASE', collection 'data');

-- Create view
CREATE MATERIALIZED VIEW data_view AS
SELECT
    time_bucket('1 sec', timestamp) AS timestamp,
    md.sensor_id::text,
    md.fuel,
    md.water
FROM data
CROSS JOIN LATERAL (
    SELECT
        metadata->>'sensorId' AS sensor_id,
        fuel,
        water
) AS md
WHERE timestamp >= NOW() - INTERVAL '1 day';

-- Drop the foreign table data
-- DROP FOREIGN TABLE data; can't drop foreign table with materialized view that is dependent on it
-- DROP FOREIGN TABLE data CASCADE;
EOF
