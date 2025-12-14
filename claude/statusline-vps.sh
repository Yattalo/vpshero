#!/bin/bash
#===============================================================================
# VPSHero - Status Line for Claude Code
# Mostra informazioni DevOps-relevant nella status bar
#===============================================================================

# Read JSON input from stdin
INPUT=$(cat)

# Parse model info
MODEL=$(echo "$INPUT" | jq -r '.model.display_name // "Unknown"' 2>/dev/null || echo "Unknown")
MODEL_SHORT=$(echo "$MODEL" | sed 's/Claude //' | cut -c1-10)

# Parse session info
COST=$(echo "$INPUT" | jq -r '.cost.total_cost_usd // 0' 2>/dev/null || echo "0")
TOKENS_IN=$(echo "$INPUT" | jq -r '.context_window.total_input_tokens // 0' 2>/dev/null || echo "0")
TOKENS_OUT=$(echo "$INPUT" | jq -r '.context_window.total_output_tokens // 0' 2>/dev/null || echo "0")
CONTEXT_SIZE=$(echo "$INPUT" | jq -r '.context_window.context_window_size // 200000' 2>/dev/null || echo "200000")

# Calculate context usage percentage
TOTAL_TOKENS=$((TOKENS_IN + TOKENS_OUT))
if [ "$CONTEXT_SIZE" -gt 0 ]; then
    CONTEXT_PCT=$((TOTAL_TOKENS * 100 / CONTEXT_SIZE))
else
    CONTEXT_PCT=0
fi

# Get system metrics (fast commands only)
get_system_metrics() {
    # Load average (first value)
    LOAD=$(cat /proc/loadavg 2>/dev/null | awk '{print $1}' || echo "?")

    # Memory percentage
    MEM=$(free 2>/dev/null | awk '/Mem/ {printf "%.0f", $3/$2*100}' || echo "?")

    # Disk percentage (root)
    DISK=$(df / 2>/dev/null | awk 'NR==2 {gsub(/%/,""); print $5}' || echo "?")

    # Docker containers (if available)
    if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
        CONTAINERS=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
    else
        CONTAINERS="?"
    fi
}

# Get metrics (with timeout to not slow down)
timeout 1 bash -c "$(declare -f get_system_metrics); get_system_metrics" 2>/dev/null || {
    LOAD="?"
    MEM="?"
    DISK="?"
    CONTAINERS="?"
}

# Actually run it
get_system_metrics

#===============================================================================
# COLORS (ANSI escape codes)
#===============================================================================
# Note: Not all terminals in Claude Code support colors, but we include them

RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Colors
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'

#===============================================================================
# DETERMINE STATUS COLORS
#===============================================================================

# Memory status
if [ "$MEM" != "?" ]; then
    if [ "$MEM" -gt 85 ]; then
        MEM_STATUS="${RED}${MEM}%${RESET}"
    elif [ "$MEM" -gt 70 ]; then
        MEM_STATUS="${YELLOW}${MEM}%${RESET}"
    else
        MEM_STATUS="${GREEN}${MEM}%${RESET}"
    fi
else
    MEM_STATUS="?%"
fi

# Disk status
if [ "$DISK" != "?" ]; then
    if [ "$DISK" -gt 85 ]; then
        DISK_STATUS="${RED}${DISK}%${RESET}"
    elif [ "$DISK" -gt 70 ]; then
        DISK_STATUS="${YELLOW}${DISK}%${RESET}"
    else
        DISK_STATUS="${GREEN}${DISK}%${RESET}"
    fi
else
    DISK_STATUS="?%"
fi

# Context status
if [ "$CONTEXT_PCT" -gt 75 ]; then
    CTX_STATUS="${RED}${CONTEXT_PCT}%${RESET}"
elif [ "$CONTEXT_PCT" -gt 50 ]; then
    CTX_STATUS="${YELLOW}${CONTEXT_PCT}%${RESET}"
else
    CTX_STATUS="${GREEN}${CONTEXT_PCT}%${RESET}"
fi

# Cost formatting
if command -v bc &>/dev/null; then
    COST_FMT=$(echo "scale=2; $COST" | bc 2>/dev/null || echo "$COST")
else
    COST_FMT=$(printf "%.2f" "$COST" 2>/dev/null || echo "$COST")
fi

#===============================================================================
# OUTPUT STATUS LINE
#===============================================================================

# Format: [Model] | Sys: Load Mem Disk | Docker: N | Cost: $X.XX | Ctx: X%

# Simple format (without colors for max compatibility)
printf "[%s] " "$MODEL_SHORT"
printf "Load:%s " "$LOAD"
printf "Mem:%s%% " "$MEM"
printf "Disk:%s%% " "$DISK"

if [ "$CONTAINERS" != "?" ]; then
    printf "Docker:%s " "$CONTAINERS"
fi

printf "| \$%s " "$COST_FMT"
printf "Ctx:%s%%" "$CONTEXT_PCT"

# Alternative: With colors (uncomment if supported)
# printf "${BLUE}[%s]${RESET} " "$MODEL_SHORT"
# printf "Load:%s " "$LOAD"
# printf "Mem:%s " "$MEM_STATUS"
# printf "Disk:%s " "$DISK_STATUS"
# if [ "$CONTAINERS" != "?" ]; then
#     printf "${CYAN}Docker:%s${RESET} " "$CONTAINERS"
# fi
# printf "| ${YELLOW}\$%s${RESET} " "$COST_FMT"
# printf "Ctx:%s" "$CTX_STATUS"
