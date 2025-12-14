---
description: Visualizza e analizza logs di servizi e container
argument-hint: <service-name> [lines: 50] [filter]
allowed-tools: Bash(docker:*), Bash(journalctl:*), Bash(tail:*), Bash(grep:*)
model: haiku
---

# Logs: $1

**Service/Container**: $1
**Lines**: ${2:-50}
**Filter**: ${3:-none}
**Timestamp**: !`date '+%Y-%m-%d %H:%M:%S'`

---

## Container Logs (if Docker)

```
!`docker logs --tail ${2:-50} $1 2>&1 || echo "Not a Docker container or not found"`
```

---

## System Service Logs (if systemd)

```
!`journalctl -u $1 -n ${2:-50} --no-pager 2>&1 || echo "Not a systemd service or not found"`
```

---

## Log Analysis

Analizza i log sopra e cerca:

### Errors
```
!`docker logs --tail 200 $1 2>&1 | grep -iE "error|exception|fatal|critical" | tail -10 || echo "No errors found"`
```

### Warnings
```
!`docker logs --tail 200 $1 2>&1 | grep -iE "warn|warning" | tail -10 || echo "No warnings found"`
```

### Recent Activity
```
!`docker logs --tail 20 --timestamps $1 2>&1 | tail -10 || echo "N/A"`
```

---

## Quick Commands

```bash
# Follow logs in real-time
docker logs -f $1

# Logs with timestamps
docker logs --timestamps $1

# Logs since specific time
docker logs --since 1h $1

# Filter by pattern
docker logs $1 2>&1 | grep "pattern"

# System service
journalctl -fu $1
```

---

## Summary

Fornisci:
1. **Status**: Il servizio sembra OK / ha problemi
2. **Issues**: Errori significativi trovati
3. **Pattern**: Pattern ricorrenti nei log
4. **Recommendations**: Azioni suggerite
