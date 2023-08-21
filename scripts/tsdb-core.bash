#!/usr/bin/env/bash
#ddev-generated

psql -U postgres <<EOF
-- Create the Pg_cron extension
CREATE EXTENSION pg_cron;
EOF
