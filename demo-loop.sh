#!/usr/bin/env bash
# Usage: ./demo-loop.sh http://127.0.0.1:PORT
URL=${1:?Usage: ./demo-loop.sh <url>}

while true; do
  if out=$(curl -sf --max-time 2 "$URL/version"); then
    ver=$(echo "$out" | sed -E 's/.*"version":"([^"]*)".*/\1/')
    pod=$(echo "$out" | sed -E 's/.*"pod":"([^"]*)".*/\1/')
    echo "$(date +%T)  version=$ver  pod=$pod"
  else
    echo -e "$(date +%T)  \033[1;31mFAILED\033[0m"
  fi
  sleep 0.5
done
