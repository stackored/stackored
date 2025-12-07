#!/usr/bin/env bash

echo "🔬 Stackored Doctor Başladı"
echo ""

# Docker var mı?
if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker bulunamadı!"
    exit 1
else
    echo "✔ Docker mevcut: $(docker --version)"
fi

# Docker Compose var mı?
if ! docker compose version >/dev/null 2>&1; then
    echo "❌ Docker Compose bulunamadı!"
    exit 1
else
    echo "✔ Docker Compose mevcut: $(docker compose version | head -n 1)"
fi

# Traefik container çalışıyor mu?
if docker ps --format '{{.Names}}' | grep -q 'stackored-traefik'; then
    echo "✔ Traefik çalışıyor"
else
    echo "⚠️ Traefik çalışmıyor"
fi

# PHP projeleri port testi
PROJECTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/projects"

for p in "$PROJECTS_DIR"/*; do
    [ -d "$p" ] || continue
    NAME=$(basename "$p")
    CONFIG="$PROJECTS_DIR/$NAME/stackored.json"

    if [ -f "$CONFIG" ]; then
        PORT=$(jq -r '.php.port // empty' "$CONFIG")
        if [ -n "$PORT" ]; then
            if lsof -i ":$PORT" >/dev/null 2>&1; then
                echo "✔ $NAME PHP Port ($PORT) aktif"
            else
                echo "⚠️ $NAME PHP Port ($PORT) çalışmıyor"
            fi
        fi
    fi
done

echo ""
echo "🟢 Doctor tamamlandı."
