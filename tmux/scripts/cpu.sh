#!/bin/bash
# CPU user% — two samples for accuracy (skips the misleading first top reading)
top -l 2 -n 0 | awk '/CPU usage/{u=$3} END{print u}'
