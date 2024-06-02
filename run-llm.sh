#!/bin/bash

set -m

# default port num. change port num if needed
PORT=11434

# start ollama server
./ollama serve &

sleep 0.5

# download default model
num=$(ollama list | grep -i $1 | wc -l)
if [ "$num" -eq "0" ]; then
  ollama pull $1
fi

json_data=$(
  jq \
  --null-input \
  --compact-output \
  --arg default_model "$1" \
  '{"model": $default_model, "keep_alive": -1}'
)

# load default model to memory at container startup
curl http://localhost:$PORT/api/generate -d "$json_data"

fg %1
