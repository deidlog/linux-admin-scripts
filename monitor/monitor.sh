#!/bin/bash
set -e

source "$(dirname "$0")/config.env"

LOG_FILE="$LOG_DIR/monitor.log"

# Create log dir if not exist
mkdir -p "$LOG_DIR"

# Function to log metric
log_metric() {
    echo "[$DATE] $1" >> "$LOG_FILE"
}

while true; do

    DATE=$(date '+%Y-%m-%d %H:%M:%S')

    # CPU usage
    CPU_USAGE=$(mpstat 1 1 | awk '/Average/ {printf "%.1f\n", 100 - $NF}')
    CPU_USAGE_INT=${CPU_USAGE%.*}

    # RAM usage
    MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
    MEM_AVAILABLE=$(free -m | awk '/^Mem:/ {print $7}')
    MEM_USAGE=$(( (MEM_TOTAL - MEM_AVAILABLE) * 100 / MEM_TOTAL ))

    # Disk usage (/)
    DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')

    # Network usage (rx/tx)
    NET_INTERFACE="$NETWORK_INTERFACE"
    RX_BYTES_BEFORE=$(cat /sys/class/net/"$NET_INTERFACE"/statistics/rx_bytes)
    TX_BYTES_BEFORE=$(cat /sys/class/net/"$NET_INTERFACE"/statistics/tx_bytes)
    sleep 60
    RX_BYTES_AFTER=$(cat /sys/class/net/"$NET_INTERFACE"/statistics/rx_bytes)
    TX_BYTES_AFTER=$(cat /sys/class/net/"$NET_INTERFACE"/statistics/tx_bytes)
    RX_RATE=$(( (RX_BYTES_AFTER - RX_BYTES_BEFORE) / 1024 )) # KB per minute
    TX_RATE=$(( (TX_BYTES_AFTER - TX_BYTES_BEFORE) / 1024 )) # KB per minute

    # Log data
    log_metric "CPU: $CPU_USAGE% | RAM: $MEM_USAGE% | Disk: $DISK_USAGE% | RX: ${RX_RATE}KB/s | TX: ${TX_RATE}KB/s"

    # Threshold alerts
    [[ "$CPU_USAGE_INT" -gt "$CPU_THRESHOLD" ]] && log_metric "HIGH CPU USAGE: $CPU_USAGE%"
    [[ "$MEM_USAGE" -gt "$MEM_THRESHOLD" ]] && log_metric "HIGHT MEMORY USAGE: $MEM_USAGE%"
    [[ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]] && log_metric "HIGH DISK USAGE: $DISK_USAGE%"

done
