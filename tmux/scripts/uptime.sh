#!/bin/bash
# Machine uptime in compact form  e.g. "2d 5h" or "3h 22m"
uptime | awk -F'up ' '{
    split($2, a, ",")
    gsub(/^ +| +$/, "", a[1])
    val = a[1]
    if (val ~ /day/) {
        split(val, d, " ")
        split(a[2], h, ":")
        gsub(/ /, "", h[1])
        printf "%sd %sh", d[1], h[1]
    } else if (val ~ /:/) {
        split(val, h, ":")
        printf "%sh %sm", h[1], h[2]
    } else {
        print val
    }
}'
