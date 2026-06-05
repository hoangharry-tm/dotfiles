#!/bin/bash
# RAM used in GB (PhysMem line from top)
top -l 1 -n 0 | awk '/PhysMem/{
    gsub(/M/, "", $2)
    printf "%.1fG", $2/1024
}'
