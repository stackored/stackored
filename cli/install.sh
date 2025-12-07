#!/usr/bin/env bash

STACKORED_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "🔧 Stackored CLI Kuruluyor..."

chmod +x "$STACKORED_ROOT/stackored/cli/stackored"
chmod +x "$STACKORED_ROOT/stackored/cli/stackored-generate"

sudo ln -sf "$STACKORED_ROOT/stackored/cli/stackored" /usr/local/bin/stackored

echo "✔ Kurulum tamamlandı. Komut kullanılabilir:"
echo "   stackored generate"
echo "   stackored up"
