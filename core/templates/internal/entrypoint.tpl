#!/usr/bin/env bash
#########################################################################
# STACKORED ENTRYPOINT TEMPLATE
# Unified boot process for all Stackored service containers.
#########################################################################

set -e

echo ">>> [Stackored] Initializing container for service: {{ SERVICE_NAME }}"

# ---------------------------------------------------------
# 1) Load environment variables from generated config
# ---------------------------------------------------------
if [ -f "/stackored-env.env" ]; then
echo ">>> Loading environment overrides"
export $(grep -v '^#' /stackored-env.env | xargs)
fi

# ---------------------------------------------------------
# 2) Run custom user override scripts
# ---------------------------------------------------------
if [ -d "/stackored-entrypoint" ]; then
echo ">>> Executing custom entrypoint scripts"
for script in /stackored-entrypoint/*.sh; do
[ -f "$script" ] && chmod +x "$script" && "$script"
done
fi

# ---------------------------------------------------------
# 3) Internal permission fixes (optional)
# ---------------------------------------------------------
if [ "{{ FIX_PERMISSIONS }}" = "true" ]; then
echo ">>> Fixing permissions on /app"
chown -R www-data:www-data /app || true
fi

# ---------------------------------------------------------
# 4) If user passed arguments, run them directly
# ---------------------------------------------------------
if [ "$#" -gt 0 ]; then
echo ">>> Running custom command: $@"
exec "$@"
fi

# ---------------------------------------------------------
# 5) Start supervisor (default behavior)
# ---------------------------------------------------------
echo ">>> Starting Supervisor for {{ SERVICE_NAME }}"
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
