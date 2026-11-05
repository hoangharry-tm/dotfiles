#!/bin/bash
# Battery percentage + charging icon (macOS + Linux)
if [ "$(uname)" = Darwin ]; then
    info=$(pmset -g batt 2>/dev/null)
    pct=$(echo "$info" | grep -Eo '[0-9]+%' | head -1)
    if echo "$info" | grep -q 'charging'; then state=charging
    elif echo "$info" | grep -q 'charged'; then state=charged
    else state=discharging; fi
else
    # Sum across all batteries (some laptops have BAT0 + BAT1)
    now=0; full=0; state=discharging
    for b in /sys/class/power_supply/BAT*; do
        [ -r "$b/energy_now" ] && n=$b/energy_now f=$b/energy_full || { n=$b/charge_now f=$b/charge_full; }
        [ -r "$n" ] || continue
        now=$((now + $(cat "$n"))); full=$((full + $(cat "$f")))
        case "$(cat "$b/status")" in
            Charging) state=charging ;;
            Full|"Not charging") [ "$state" = charging ] || state=charged ;;
        esac
    done
    [ "$full" -gt 0 ] && pct="$((now * 100 / full))%"
fi

if [ -z "$pct" ]; then
    echo "󱉝 --"
    exit
fi

case "$state" in
    charging) echo "󰂄 $pct" ;;
    charged)  echo "󰁹 $pct" ;;
    *)        echo "󰁾 $pct" ;;
esac
