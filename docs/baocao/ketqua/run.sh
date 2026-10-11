#!/usr/bin/env bash
# Chay mot file .sql trong container SQL Server, in ket qua ra stdout
set -euo pipefail
f="$1"
docker cp "$f" quanlythuvien_sqlserver:/tmp/run.sql >/dev/null
docker exec quanlythuvien_sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P 'StrongPassword123!' -C -f 65001 -W -s '|' -i /tmp/run.sql
