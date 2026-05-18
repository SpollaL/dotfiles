#!/bin/bash

ROOT="/home/splu5001/workspace/media-mmm-dev-local"

window_exists() {
  tmux list-windows -F "#{window_name}" | grep -qx "$1"
}

tmux rename-window "root"

if ! window_exists "app"; then
  tmux new-window -n "app"
  tmux send-keys "cd $ROOT/media-mmm-app-service && nvim ." Enter
  tmux split-window -h -l 35%
  tmux send-keys "cd $ROOT/media-mmm-app-service" Enter
  tmux select-pane -L
fi

if ! window_exists "data"; then
  tmux new-window -n "data"
  tmux send-keys "cd $ROOT/media-mmm-data-service && nvim ." Enter
  tmux split-window -h -l 35%
  tmux send-keys "cd $ROOT/media-mmm-data-service" Enter
  tmux select-pane -L
fi

if ! window_exists "pipeline"; then
  tmux new-window -n "pipeline"
  tmux send-keys "cd $ROOT/media-mmm-bayesian-pipeline && nvim ." Enter
  tmux split-window -h -l 35%
  tmux send-keys "cd $ROOT/media-mmm-bayesian-pipeline" Enter
  tmux select-pane -L
fi

if ! window_exists "mcp"; then
  tmux new-window -n "mcp"
  tmux send-keys "cd $ROOT/media-mmm-mcp && nvim ." Enter
  tmux split-window -h -l 35%
  tmux send-keys "cd $ROOT/media-mmm-mcp" Enter
  tmux select-pane -L
fi

if ! window_exists "sim-opt"; then
  tmux new-window -n "sim-opt"
  tmux send-keys "cd $ROOT/media-mmo-sim-opt && nvim ." Enter
  tmux split-window -h -l 35%
  tmux send-keys "cd $ROOT/media-mmo-sim-opt" Enter
  tmux select-pane -L
fi

if ! window_exists "k8s"; then
  tmux new-window -n "k8s"
  tmux send-keys "cd $ROOT" Enter
  tmux split-window -h
  tmux send-keys "cd $ROOT" Enter
  tmux split-window -v
  tmux send-keys "cd $ROOT" Enter
  tmux select-pane -t 1
fi

tmux select-window -t :root
cd "$ROOT"
exec nvim .
