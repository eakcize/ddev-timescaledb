#!/usr/bin/env bash
#ddev-generated

read -r -p "Enter the Dashboard API  project name (dashboard-api):  " DASHBOARD_API_PROJECT_NAME
read -r -p "Enter the Dashboard API  database name (db): " DASHBOARD_API_DATABASE_NAME

if [ -z "$DASHBOARD_API_PROJECT_NAME" ]; then
  DASHBOARD_API_PROJECT_NAME="dashboard-api"
fi

if [ -z "$DASHBOARD_API_DATABASE_NAME" ]; then
  DASHBOARD_API_DATABASE_NAME="db"
fi

printf "Configuring TSDB for project %s\n" "$DASHBOARD_API_PROJECT_NAME"

# shellcheck source=scripts/configure-mysql.bash
source "$D/../../scripts/configure-mysql.bash"

read -r -p "Enter the Filler Service project name (eakcize-filler): " FILLER_SERVICE_PROJECT_NAME
read -r -p "Enter the Filler Service  database name (prod): " FILLER_SERVICE_DATABASE_NAME


if [ -z "$FILLER_SERVICE_PROJECT_NAME" ]; then
  FILLER_SERVICE_PROJECT_NAME="eakcize-filler"
fi

if [ -z "$FILLER_SERVICE_DATABASE_NAME" ]; then
  FILLER_SERVICE_DATABASE_NAME="prod"
fi

# shellcheck source=scripts/configure-mongo.bash
source "$D/../../scripts/configure-mongo.bash"

# shellcheck source=scripts/tsdb-core.bash
source "$D/../../scripts/configure-tsdb.bash"
