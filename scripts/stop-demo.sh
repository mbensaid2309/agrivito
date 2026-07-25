#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$ROOT_DIR/.demo"

stop_pid_file() {
  local pid_file="$1"
  local label="$2"
  if [[ ! -f "$pid_file" ]]; then
    return
  fi
  local pid
  pid="$(tr -dc '0-9' < "$pid_file")"
  if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
    kill "$pid"
    echo "$label arrêté (PID $pid)."
  fi
  rm -f "$pid_file"
}

stop_pid_file "$STATE_DIR/flutter.pid" "Flutter Web"
stop_pid_file "$STATE_DIR/backend.pid" "Backend FastAPI"

if [[ -f "$STATE_DIR/postgres.pid" && -f "$STATE_DIR/postgres-bin" ]]; then
  POSTGRES_PID="$(tr -dc '0-9' < "$STATE_DIR/postgres.pid")"
  PG_BIN_DIR="$(cat "$STATE_DIR/postgres-bin")"
  if [[ -n "$POSTGRES_PID" ]] && kill -0 "$POSTGRES_PID" 2>/dev/null; then
    "$PG_BIN_DIR/pg_ctl" -D "$STATE_DIR/postgres-data" -m fast stop >/dev/null
    echo "PostgreSQL de démonstration arrêté (PID $POSTGRES_PID)."
  fi
  rm -f "$STATE_DIR/postgres.pid" "$STATE_DIR/postgres-bin"
fi
