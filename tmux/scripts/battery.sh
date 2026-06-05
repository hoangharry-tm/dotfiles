#!/bin/bash
# Battery percentage + charging icon (macOS)
info=$(pmset -g batt 2>/dev/null)
pct=$(echo "$info" | grep -Eo '[0-9]+%' | head -1)

if [ -z "$pct" ]; then
    echo "󱉝 --"
    exit
fi

if echo "$info" | grep -q 'charging'; then
    echo "󰂄 $pct"
elif echo "$info" | grep -q 'charged'; then
    echo "󰁹 $pct"
else
    echo "󰁾 $pct"
fi
