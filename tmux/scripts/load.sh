#!/bin/bash
# 1-minute load average
sysctl -n vm.loadavg | awk '{printf "%.2f", $2}'
