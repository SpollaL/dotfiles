#!/usr/bin/env bash

# Terminate already running bar instances
polybar-msg cmd quit
# killall -q polybar

# kait until Polybar has quit
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar on all connected monitors
polybar exampleeDP-1 &
polybar exampleHDMI-1

echo "Bars launched on all monitors..."