#!/bin/bash
# RAM used in GB
if [ "$(uname)" = Darwin ]; then
    # PhysMem line from top
    top -l 1 -n 0 | awk '/PhysMem/{
        gsub(/M/, "", $2)
        printf "%.1fG", $2/1024
    }'
else
    awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{printf "%.1fG", (t-a)/1048576}' /proc/meminfo
fi
