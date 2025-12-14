#!/bin/bash
#===============================================================================
# VPSHero - Audit Log Hook
# Logga tutte le operazioni per compliance e debugging
#===============================================================================

# Read input from stdin (JSON with tool info)
INPUT=$(cat)

# Parse tool information
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo "unknown")
TOOL_INPUT=$(echo "$INPUT" | jq -c '.tool_input // {}' 2>/dev/null || echo "{}")

# Timestamp and user
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
USER=$(whoami)
HOSTNAME=$(hostname)

# Log file paths
AUDIT_LOG="/var/log/claude-audit.log"
AUDIT_JSON="/var/log/claude-audit.jsonl"

# Ensure log directory exists
mkdir -p "$(dirname "$AUDIT_LOG")" 2>/dev/null || true

# Determine operation category
case "$TOOL_NAME" in
    Bash)
        CATEGORY="command"
        # Extract command for logging (sanitized)
        COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command // ""' 2>/dev/null | head -c 200)
        DETAILS="cmd: ${COMMAND:0:200}"
        ;;
    Edit|Write)
        CATEGORY="file_modify"
        FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // ""' 2>/dev/null)
        DETAILS="file: $FILE_PATH"
        ;;
    Read)
        CATEGORY="file_read"
        FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // ""' 2>/dev/null)
        DETAILS="file: $FILE_PATH"
        ;;
    *)
        CATEGORY="other"
        DETAILS="tool: $TOOL_NAME"
        ;;
esac

# Text log entry
LOG_ENTRY="[$TIMESTAMP] [$USER@$HOSTNAME] [$CATEGORY] $DETAILS"
echo "$LOG_ENTRY" >> "$AUDIT_LOG" 2>/dev/null || true

# JSON log entry (for structured analysis)
JSON_ENTRY=$(jq -n \
    --arg ts "$TIMESTAMP" \
    --arg user "$USER" \
    --arg host "$HOSTNAME" \
    --arg tool "$TOOL_NAME" \
    --arg cat "$CATEGORY" \
    --argjson input "$TOOL_INPUT" \
    '{timestamp: $ts, user: $user, hostname: $host, tool: $tool, category: $cat, input: $input}' \
    2>/dev/null)

if [ -n "$JSON_ENTRY" ]; then
    echo "$JSON_ENTRY" >> "$AUDIT_JSON" 2>/dev/null || true
fi

# Log rotation check (rotate if > 10MB)
if [ -f "$AUDIT_LOG" ]; then
    SIZE=$(stat -f%z "$AUDIT_LOG" 2>/dev/null || stat -c%s "$AUDIT_LOG" 2>/dev/null || echo "0")
    if [ "$SIZE" -gt 10485760 ]; then
        mv "$AUDIT_LOG" "$AUDIT_LOG.$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
        gzip "$AUDIT_LOG."* 2>/dev/null || true
    fi
fi

# Always exit 0 to not block operations
exit 0
