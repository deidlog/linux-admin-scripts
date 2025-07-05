#!/bin/bash
set -e

LOG_DIR="/var/log/monitor"
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=90
NETWORK_INTERFACE="enp0s3"

LOG_FILE="$LOG_DIR/monitor.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Create log dir if not exist
mkdir -p "$LOG_DIR"

# Function to log metric
log_metric() {
    echo "[$DATE] $1" >> "$LOG_FILE"
}

# CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
CPU_USAGE_INT=${CPU_USAGE%.*}

# RAM usage
MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
MEM_AVAILABLE=$(free -m | awk '/^Mem:/ {print $7}')
MEM_USAGE=$(( (MEM_TOTAL - MEM_AVAILABLE) * 100 / MEM_TOTAL ))

# Disk usage (/)
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')

# Network usage (rx/tx)
NET_INTERFACE="$NETWORK_INTERFACE"
RX_BYTES_BEFORE=$(cat /sys/class/net/$NET_INTERFACE/statistics/rx_bytes)
TX_BYTES_BEFORE=$(cat /sys/class/net/$NET_INTERFACE/statistics/tx_bytes)
sleep 1
RX_BYTES_AFTER=$(cat /sys/class/net/$NET_INTERFACE/statistics/rx_bytes)
TX_BYTES_AFTER=$(cat /sys/class/net/$NET_INTERFACE/statistics/tx_bytes)
RX_RATE=$(( (RX_BYTES_AFTER - RX_BYTES_BEFORE) / 1024 )) # KB/s
TX_RATE=$(( (TX_BYTES_AFTER - TX_BYTES_BEFORE) / 1024 )) # KB/s

# Log data
log_metric "CPU: $CPU_USAGE% | RAM: $MEM_USAGE% | Disk: $DISK_USAGE% | RX: ${RX_RATE}KB/s | TX: ${TX_RATE}KB/s"

# Threshold alerts
[[ "$CPU_USAGE_INT" -gt "$CPU_THRESHOLD" ]] && log_metric "HIGH CPU USAGE: $CPU_USAGE%"
[[ "$MEM_USAGE" -gt "$MEM_THRESHOLD" ]] && log_metric "HIGHT MEMORY USAGE: $MEM_USAGE%"
[[ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]] && log_metric "HIGH DISK USAGE: $DISK_USAGE%"

exit 0
