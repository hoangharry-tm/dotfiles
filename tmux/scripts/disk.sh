#!/bin/bash
# Root disk usage percentage
df -h / | awk 'NR==2{print $5}'
