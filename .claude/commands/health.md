---
description: Health check completo del sistema VPS
allowed-tools: Bash(uptime:*), Bash(free:*), Bash(df:*), Bash(docker:*), Bash(systemctl:*), Bash(cat:*), Bash(netstat:*), Bash(ss:*)
model: haiku
---

# System Health Check

**Timestamp**: !`date '+%Y-%m-%d %H:%M:%S'`
**Hostname**: !`hostname`
**Uptime**: !`uptime -p`

---

## System Resources

### CPU & Load
```
Load Average: !`cat /proc/loadavg`
CPU Cores: !`nproc`
```

### Memory
```
!`free -h`
```

### Disk
```
!`df -h / /var /home 2>/dev/null | grep -v "^Filesystem" | head -5`
```

### Top Processes (by memory)
```
!`ps aux --sort=-%mem | head -6`
```

---

## Docker Status

### Running Containers
```
!`docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Docker not available"`
```

### Container Stats
```
!`docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null | head -10 || echo "N/A"`
```

### Docker System
```
!`docker system df 2>/dev/null || echo "N/A"`
```

---

## Services Status

### Critical Services
```
!`systemctl is-active docker nginx ssh 2>/dev/null | paste - - - || echo "Check manually"`
```

### Failed Services
```
!`systemctl --failed --no-pager 2>/dev/null | head -10 || echo "None"`
```

---

## Network

### Listening Ports
```
!`ss -tlnp 2>/dev/null | head -15 || netstat -tlnp 2>/dev/null | head -15`
```

### Active Connections
```
Established: !`ss -s 2>/dev/null | grep estab || echo "N/A"`
```

---

## Quick Assessment

Analizza i dati sopra e fornisci:

1. **Status**: OK / WARNING / CRITICAL
2. **Issues**: Lista problemi trovati
3. **Recommendations**: Azioni suggerite

### Thresholds
- CPU Load > cores: WARNING
- Memory > 80%: WARNING
- Disk > 85%: WARNING
- Container unhealthy: CRITICAL
- Service failed: CRITICAL
