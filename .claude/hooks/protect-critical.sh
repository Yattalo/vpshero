#!/bin/bash
#===============================================================================
# VPSHero - Critical File Protection Hook
# Previene modifiche a file critici del sistema
#===============================================================================

# Read input from stdin
INPUT=$(cat)

# Parse file path from tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)

# If no file path, allow the operation
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

#===============================================================================
# PROTECTED PATHS
#===============================================================================

# Files that should NEVER be modified by Claude
BLOCKED_PATHS=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/sudoers"
    "/etc/ssh/sshd_config"
    "/root/.ssh"
    "/.ssh"
    "/etc/ssl/private"
    "/var/run/docker.sock"
    "/proc"
    "/sys"
    "/boot"
)

# Files that require confirmation (warning but not blocked)
WARN_PATHS=(
    "/etc/nginx"
    "/etc/systemd"
    "/etc/docker"
    "/etc/hosts"
    "/etc/resolv.conf"
    ".env"
    ".env.production"
    "docker-compose.yml"
    "docker-compose.yaml"
    "Dockerfile"
)

# Patterns to block
BLOCKED_PATTERNS=(
    "*.pem"
    "*.key"
    "*credentials*"
    "*secrets*"
    "*password*"
    "*.p12"
    "*.pfx"
)

#===============================================================================
# CHECK FUNCTIONS
#===============================================================================

# Check if path matches any blocked path
is_blocked() {
    local path="$1"
    for blocked in "${BLOCKED_PATHS[@]}"; do
        if [[ "$path" == "$blocked"* ]]; then
            return 0
        fi
    done
    return 1
}

# Check if path matches any warn path
needs_warning() {
    local path="$1"
    for warn in "${WARN_PATHS[@]}"; do
        if [[ "$path" == *"$warn"* ]]; then
            return 0
        fi
    done
    return 1
}

# Check if path matches blocked patterns
matches_blocked_pattern() {
    local path="$1"
    local filename=$(basename "$path")
    for pattern in "${BLOCKED_PATTERNS[@]}"; do
        case "$filename" in
            $pattern) return 0 ;;
        esac
    done
    return 1
}

#===============================================================================
# MAIN LOGIC
#===============================================================================

# Normalize path
NORM_PATH=$(realpath "$FILE_PATH" 2>/dev/null || echo "$FILE_PATH")

# Check blocked paths
if is_blocked "$NORM_PATH"; then
    echo "BLOCKED: Cannot modify protected system file: $FILE_PATH"
    echo "This file is critical for system security/stability."
    exit 2
fi

# Check blocked patterns
if matches_blocked_pattern "$FILE_PATH"; then
    echo "BLOCKED: Cannot modify files matching sensitive patterns: $FILE_PATH"
    echo "This file appears to contain sensitive data (keys, credentials, secrets)."
    exit 2
fi

# Check warn paths (output warning but allow)
if needs_warning "$FILE_PATH"; then
    echo "WARNING: Modifying configuration file: $FILE_PATH"
    echo "This file affects system/service configuration. Proceed with caution."
fi

# All checks passed
exit 0
