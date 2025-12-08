#!/usr/bin/env bash

STACKORED_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "🔧 Stackored CLI Kuruluyor..."

chmod +x "$STACKORED_ROOT/stackored/cli/stackored.sh"
chmod +x "$STACKORED_ROOT/stackored/cli/generate.sh"
chmod +x "$STACKORED_ROOT/stackored/cli/generate-ssl-certs.sh"
chmod +x "$STACKORED_ROOT/stackored/cli/uninstall.sh"

sudo ln -sf "$STACKORED_ROOT/stackored/cli/stackored.sh" /usr/local/bin/stackored

echo "✔ Kurulum tamamlandı. Komut kullanılabilir:"
echo "   stackored generate"
echo "   stackored up"
