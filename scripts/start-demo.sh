#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/services/backend"
MOBILE_DIR="$ROOT_DIR/apps/mobile"
STATE_DIR="$ROOT_DIR/.demo"
LOG_DIR="$STATE_DIR/logs"
BACKEND_PID_FILE="$STATE_DIR/backend.pid"
FLUTTER_PID_FILE="$STATE_DIR/flutter.pid"
BACKEND_URL="${AGRIVITO_API_BASE_URL:-http://127.0.0.1:8000}"
FLUTTER_PORT="${AGRIVITO_DEMO_WEB_PORT:-8080}"
POSTGRES_PORT="${AGRIVITO_DEMO_POSTGRES_PORT:-55432}"

mkdir -p "$LOG_DIR"

if [[ ! -f "$BACKEND_DIR/requirements.txt" || ! -f "$MOBILE_DIR/pubspec.yaml" ]]; then
  echo "Erreur: lancez ce script depuis le dépôt Agrivito complet." >&2
  exit 1
fi

if [[ -n "${DATABASE_URL:-}" && "$DATABASE_URL" != postgresql* ]]; then
  echo "Erreur: la démonstration validée utilise PostgreSQL, pas une autre base." >&2
  exit 1
fi

command -v python3 >/dev/null || { echo "Erreur: Python 3 est requis." >&2; exit 1; }
if command -v flutter >/dev/null; then
  FLUTTER_BIN="$(command -v flutter)"
elif [[ -x "$HOME/development/flutter/bin/flutter" ]]; then
  FLUTTER_BIN="$HOME/development/flutter/bin/flutter"
else
  echo "Erreur: Flutter est requis (commande flutter introuvable)." >&2
  exit 1
fi

"$ROOT_DIR/scripts/stop-demo.sh" >/dev/null 2>&1 || true

if [[ -z "${DATABASE_URL:-}" ]]; then
  PG_BIN_DIR=""
  for candidate in \
    "$(dirname "$(command -v initdb 2>/dev/null || echo /missing)")" \
    /opt/homebrew/opt/postgresql@16/bin \
    /usr/local/opt/postgresql@16/bin \
    /usr/lib/postgresql/16/bin; do
    if [[ -x "$candidate/initdb" && -x "$candidate/pg_ctl" ]]; then
      PG_BIN_DIR="$candidate"
      break
    fi
  done
  if [[ -z "$PG_BIN_DIR" ]]; then
    echo "Erreur: PostgreSQL 16 est requis." >&2
    echo "macOS: brew install postgresql@16" >&2
    echo "Ou fournissez DATABASE_URL vers une base PostgreSQL locale/de test." >&2
    exit 1
  fi
  PG_DATA="$STATE_DIR/postgres-data"
  if [[ ! -f "$PG_DATA/PG_VERSION" ]]; then
    "$PG_BIN_DIR/initdb" -D "$PG_DATA" -U postgres --auth=trust \
      >"$LOG_DIR/postgres-init.log"
  fi
  "$PG_BIN_DIR/pg_ctl" -D "$PG_DATA" \
    -o "-h 127.0.0.1 -p $POSTGRES_PORT" \
    -l "$LOG_DIR/postgres.log" start >/dev/null
  head -n 1 "$PG_DATA/postmaster.pid" > "$STATE_DIR/postgres.pid"
  echo "$PG_BIN_DIR" > "$STATE_DIR/postgres-bin"
  "$PG_BIN_DIR/createdb" -h 127.0.0.1 -p "$POSTGRES_PORT" \
    -U postgres agrivito_demo 2>/dev/null || true
  export DATABASE_URL="postgresql+psycopg://postgres@127.0.0.1:$POSTGRES_PORT/agrivito_demo"
  echo "PostgreSQL local de démonstration démarré sur le port $POSTGRES_PORT."
fi

if [[ ! -x "$BACKEND_DIR/.venv/bin/python" ]]; then
  python3 -m venv "$BACKEND_DIR/.venv"
fi
"$BACKEND_DIR/.venv/bin/pip" install -r "$BACKEND_DIR/requirements.txt"

export DEMO_MODE=true
export AI_MODE=mock
export VISION_MODE=mock
export AUTH_MODE=mock
export AUTH_PROVIDER=supabase
export MEDIA_STORAGE_PROVIDER=local
export MEDIA_LOCAL_PATH="$STATE_DIR/media"

(
  cd "$BACKEND_DIR"
  .venv/bin/alembic upgrade head
  PYTHONPATH=. .venv/bin/python scripts/seed_demo.py
  exec .venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8000
) >"$LOG_DIR/backend.log" 2>&1 &
echo "$!" > "$BACKEND_PID_FILE"

for _ in {1..30}; do
  if curl -fsS "$BACKEND_URL/health" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done
if ! curl -fsS "$BACKEND_URL/health" >/dev/null 2>&1; then
  echo "Erreur: le backend n'a pas démarré. Consultez $LOG_DIR/backend.log" >&2
  "$ROOT_DIR/scripts/stop-demo.sh" >/dev/null 2>&1 || true
  exit 1
fi

(
  cd "$MOBILE_DIR"
  "$FLUTTER_BIN" pub get
  exec "$FLUTTER_BIN" run -d web-server --web-hostname 127.0.0.1 \
    --web-port "$FLUTTER_PORT" \
    --dart-define="AGRIVITO_API_BASE_URL=$BACKEND_URL" \
    --dart-define=DEMO_MODE=true \
    --dart-define=AUTH_MODE=mock
) >"$LOG_DIR/flutter.log" 2>&1 &
echo "$!" > "$FLUTTER_PID_FILE"

echo
echo "Agrivito est en cours de démarrage."
echo "Application : http://127.0.0.1:$FLUTTER_PORT"
echo "API         : $BACKEND_URL/docs"
echo "Compte fictif : agriculteur.demo@agrivito.local"
echo "Mot de passe  : DemoAgrivito123!"
echo "Modes : DEMO=true, AUTH=mock, AI=mock, VISION=mock, MEDIA=local"
echo "Arrêt : $ROOT_DIR/scripts/stop-demo.sh"
echo "Logs  : $LOG_DIR"
