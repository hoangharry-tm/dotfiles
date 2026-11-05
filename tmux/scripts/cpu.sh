#!/bin/bash
# CPU user% — two samples for accuracy (skips the misleading first reading)
if [ "$(uname)" = Darwin ]; then
    top -l 2 -n 0 | awk '/CPU usage/{u=$3} END{print u}'
else
    sample() { awk 'NR==1{t=0; for(i=2;i<=NF;i++) t+=$i; print $2+$3, t}' /proc/stat; }
    read -r u1 t1 <<< "$(sample)"; sleep 0.5
    read -r u2 t2 <<< "$(sample)"
    awk -v u=$((u2 - u1)) -v t=$((t2 - t1)) \
        'BEGIN{ if (t > 0) printf "%.1f%%", u * 100 / t; else print "--" }'
fi
