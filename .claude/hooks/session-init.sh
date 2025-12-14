#!/bin/bash
#===============================================================================
# VPSHero - Session Initialization Hook
# Eseguito all'avvio di ogni sessione Claude Code
#===============================================================================

# Log session start
SESSION_LOG="/var/log/claude-sessions.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
USER=$(whoami)
HOSTNAME=$(hostname)

# Crea log directory se non esiste
mkdir -p "$(dirname "$SESSION_LOG")" 2>/dev/null || true

# Log session
echo "[$TIMESTAMP] Session started by $USER on $HOSTNAME" >> "$SESSION_LOG" 2>/dev/null || true

# Set environment variables for session
if [ -n "$CLAUDE_ENV_FILE" ]; then
    # Export useful environment variables
    echo "export VPSHERO_SESSION_START='$TIMESTAMP'" >> "$CLAUDE_ENV_FILE"
    echo "export VPSHERO_USER='$USER'" >> "$CLAUDE_ENV_FILE"
    echo "export VPSHERO_HOSTNAME='$HOSTNAME'" >> "$CLAUDE_ENV_FILE"

    # Docker availability
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')
        echo "export DOCKER_VERSION='$DOCKER_VERSION'" >> "$CLAUDE_ENV_FILE"
        RUNNING_CONTAINERS=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
        echo "export RUNNING_CONTAINERS='$RUNNING_CONTAINERS'" >> "$CLAUDE_ENV_FILE"
    fi

    # GitHub CLI availability
    if command -v gh &> /dev/null; then
        GH_LOGGED_IN=$(gh auth status 2>&1 | grep -c "Logged in" || echo "0")
        echo "export GH_LOGGED_IN='$GH_LOGGED_IN'" >> "$CLAUDE_ENV_FILE"
    fi
fi

# Output brief status (shown to Claude)
echo "Session initialized: $TIMESTAMP"
echo "User: $USER@$HOSTNAME"

# Quick health check
LOAD=$(cat /proc/loadavg 2>/dev/null | awk '{print $1}' || echo "N/A")
MEM=$(free 2>/dev/null | awk '/Mem/ {printf "%.0f%%", $3/$2*100}' || echo "N/A")
DISK=$(df / 2>/dev/null | awk 'NR==2 {print $5}' || echo "N/A")

echo "System: Load=$LOAD Mem=$MEM Disk=$DISK"

# Check Docker if available
if command -v docker &> /dev/null; then
    CONTAINERS=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
    echo "Docker: $CONTAINERS containers running"
fi

exit 0
