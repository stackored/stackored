#!/bin/bash
###################################################################
# Stackored UI - Docker Status API (CGI Script)
# Returns real-time Docker container status as JSON
###################################################################

echo "Content-Type: application/json"
echo "Access-Control-Allow-Origin: *"
echo ""

# Get all containers
containers=$(docker ps -a --format "{{.Names}}\t{{.State}}" 2>&1)

if [ $? -ne 0 ]; then
    echo '{"success":false,"error":"Failed to get Docker status"}'
    exit 1
fi

# Build JSON response
echo '{'
echo '  "success": true,'
echo '  "services": {'

first=true
while IFS=$'\t' read -r name state; do
    # Only include stackored containers
    if [[ "$name" == stackored-* ]]; then
        running="false"
        [ "$state" = "running" ] && running="true"
        
        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi
        
        echo -n "    \"$name\": {\"running\": $running, \"state\": \"$state\"}"
    fi
done <<< "$containers"

echo ""
echo '  }'
echo '}'
