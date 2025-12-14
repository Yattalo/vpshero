#!/bin/bash
#===============================================================================
# VPSHero - Pre-Deploy Validation Hook
# Validazione prima di operazioni di deployment
#===============================================================================

# Read input from stdin
INPUT=$(cat)

# Parse tool information
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // {}' 2>/dev/null)
COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command // ""' 2>/dev/null)

# Timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Log file
DEPLOY_LOG="/var/log/claude-deploy.log"
mkdir -p "$(dirname "$DEPLOY_LOG")" 2>/dev/null || true

#===============================================================================
# VALIDATION CHECKS
#===============================================================================

WARNINGS=()
BLOCKS=()

# Check 1: System resources
check_resources() {
    # Memory check (warn if < 500MB free)
    FREE_MEM=$(free -m 2>/dev/null | awk '/Mem/ {print $7}' || echo "1000")
    if [ "$FREE_MEM" -lt 500 ]; then
        WARNINGS+=("Low memory: ${FREE_MEM}MB free")
    fi

    # Disk check (warn if < 2GB free)
    FREE_DISK=$(df / 2>/dev/null | awk 'NR==2 {print int($4/1024)}' || echo "10000")
    if [ "$FREE_DISK" -lt 2048 ]; then
        WARNINGS+=("Low disk: ${FREE_DISK}MB free")
    fi

    # Load check (warn if load > num CPUs)
    LOAD=$(cat /proc/loadavg 2>/dev/null | awk '{print int($1)}' || echo "0")
    CPUS=$(nproc 2>/dev/null || echo "2")
    if [ "$LOAD" -gt "$CPUS" ]; then
        WARNINGS+=("High load: $LOAD (CPUs: $CPUS)")
    fi
}

# Check 2: Docker specific checks
check_docker() {
    if [[ "$COMMAND" == *"docker"* ]]; then
        # Check Docker daemon
        if ! docker info &>/dev/null; then
            BLOCKS+=("Docker daemon not running or not accessible")
            return
        fi

        # Warn about dangerous commands
        if [[ "$COMMAND" == *"rm -f"* ]] || [[ "$COMMAND" == *"rmi -f"* ]]; then
            WARNINGS+=("Force removal command detected")
        fi

        if [[ "$COMMAND" == *"prune"* ]] && [[ "$COMMAND" == *"-a"* ]]; then
            WARNINGS+=("Aggressive prune command - may remove needed resources")
        fi

        # Check for running containers if stopping/removing
        if [[ "$COMMAND" == *"docker stop"* ]] || [[ "$COMMAND" == *"docker rm"* ]]; then
            WARNINGS+=("Container stop/remove operation")
        fi
    fi
}

# Check 3: Git push checks
check_git() {
    if [[ "$COMMAND" == *"git push"* ]]; then
        # Warn about force push
        if [[ "$COMMAND" == *"--force"* ]] || [[ "$COMMAND" == *"-f"* ]]; then
            WARNINGS+=("Force push detected - this can overwrite remote history")
        fi

        # Warn about push to main/master
        if [[ "$COMMAND" == *"main"* ]] || [[ "$COMMAND" == *"master"* ]]; then
            WARNINGS+=("Pushing to main/master branch")
        fi
    fi
}

# Check 4: Service management checks
check_systemctl() {
    if [[ "$COMMAND" == *"systemctl"* ]]; then
        # Warn about stopping critical services
        CRITICAL_SERVICES="sshd ssh docker nginx"
        for svc in $CRITICAL_SERVICES; do
            if [[ "$COMMAND" == *"stop $svc"* ]] || [[ "$COMMAND" == *"disable $svc"* ]]; then
                WARNINGS+=("Attempting to stop/disable critical service: $svc")
            fi
        done
    fi
}

#===============================================================================
# RUN CHECKS
#===============================================================================

check_resources
check_docker
check_git
check_systemctl

#===============================================================================
# OUTPUT RESULTS
#===============================================================================

# Log the operation
echo "[$TIMESTAMP] Pre-deploy check: $COMMAND" >> "$DEPLOY_LOG" 2>/dev/null || true

# If there are blocking issues, exit with code 2
if [ ${#BLOCKS[@]} -gt 0 ]; then
    echo "BLOCKED: Operation cannot proceed"
    for block in "${BLOCKS[@]}"; do
        echo "  - $block"
        echo "[$TIMESTAMP] BLOCKED: $block" >> "$DEPLOY_LOG" 2>/dev/null || true
    done
    exit 2
fi

# If there are warnings, output them but allow (exit 0)
if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo "WARNINGS (operation will proceed):"
    for warn in "${WARNINGS[@]}"; do
        echo "  - $warn"
        echo "[$TIMESTAMP] WARNING: $warn" >> "$DEPLOY_LOG" 2>/dev/null || true
    done
fi

# All checks passed
exit 0
