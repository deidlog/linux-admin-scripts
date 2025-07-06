# System Resource Monitor

A simple bash script to monitor Linux system resources:

* CPU, RAM, disk, and network usage
* Logs metrics to a file
* Flags when usage exceeds set thresholds

---

## Usage

1. Edit `config.env` to set thresholds and network interface.

2. Run the script:

```bash
./monitor.sh
```

3. The script runs in an infinite loop, logging data every minute.

---

## Files

* `monitor.sh` — monitoring script
* `config.env` — configuration (thresholds, log directory, network interface)
* `monitor.log` — log file (auto-created)

---

## Configuration in `config.env`

```bash
LOG_DIR="/var/log/monitor"      # Log directory  
CPU_THRESHOLD=80                # CPU usage threshold (%)  
MEM_THRESHOLD=80                # Memory usage threshold (%)  
DISK_THRESHOLD=90               # Disk usage threshold (%)  
NETWORK_INTERFACE="eth0"        # Network interface to monitor  
```

---

## Log format

Example log entry:

```
[2025-07-05 12:00:00] CPU: 15.3% | RAM: 42% | Disk: 65% | RX: 1024KB/s | TX: 512KB/s
```

Threshold warnings look like:

```
[2025-07-05 12:05:00] HIGH CPU USAGE: 91%
```

---

## Notes

* The script runs indefinitely, sleeping 60 seconds between network checks.
* Stop with Ctrl+C.

---
