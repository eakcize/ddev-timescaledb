#!/usr/bin/env bash
#ddev-generated

MYSQL_HOST="$1"
MYSQL_DATABASE="$2"

# Start the psql shell and execute SQL commands
psql -U postgres <<EOF

-- Drop the foreign tables
DROP FOREIGN TABLE IF EXISTS "company";
DROP FOREIGN TABLE IF EXISTS "pump";
DROP FOREIGN TABLE IF EXISTS "tank";
DROP FOREIGN TABLE IF EXISTS "device";

-- Drop the user mapping
DROP USER MAPPING IF EXISTS FOR postgres SERVER mysql_server;

-- Drop the foreign server
DROP SERVER IF EXISTS mysql_server;

-- Create the foreign server for MySql
CREATE SERVER mysql_server
        FOREIGN DATA WRAPPER mysql_fdw
        OPTIONS (host '$MYSQL_HOST', port '3306');

-- Create the user mapping
CREATE USER MAPPING  FOR postgres
        SERVER mysql_server
        OPTIONS (username 'mysql', password 'mysql');

-- Create the foreign table for Device
CREATE FOREIGN TABLE "device" (
  id INTEGER,
  idx VARCHAR(36),
  client_id VARCHAR(255)
) SERVER mysql_server OPTIONS (dbname '$MYSQL_DATABASE', table_name 'device');

-- Create the foreign table for Tank
CREATE FOREIGN TABLE "tank" (
  id INTEGER,
  idx VARCHAR(36),
  device_id INTEGER,
  pump_id INTEGER,
  fuel_type VARCHAR(36),
  tank_model VARCHAR(36)
) SERVER mysql_server OPTIONS (dbname '$MYSQL_DATABASE', table_name 'tank');

-- Create the foreign table for Pump
CREATE FOREIGN TABLE "pump" (
  id INTEGER,
  idx VARCHAR(36),
  municipality VARCHAR(36),
  city VARCHAR(36),
  company_id INTEGER,
  geolocation VARCHAR(36),
  address VARCHAR(36)
) SERVER mysql_server OPTIONS (dbname '$MYSQL_DATABASE', table_name 'pump');

-- Create the foreign table for Company
CREATE FOREIGN TABLE "company" (
  id INTEGER,
  idx VARCHAR(36),
  name VARCHAR(36),
  city VARCHAR(36),
  short VARCHAR(36)
) SERVER mysql_server OPTIONS (dbname '$MYSQL_DATABASE', table_name 'company');
EOF
