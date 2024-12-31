.DEFAULT_GOAL := help

ifeq (load,$(firstword $(MAKECMDGOALS)))
  LOAD_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(LOAD_ARGS):;@:)
endif

ifeq (cmd,$(firstword $(MAKECMDGOALS)))
  CMD_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(CMD_ARGS):;@:)
endif

prog: # ...
    # ...

all: clean run

.PHONY: run
run:
	@echo "Run 'chatterbox' container"
	@docker run -d --restart=always \
    --net=host \
    --device=/dev/dri \
    -p 11434:11434 \
    -v ${HOME}/ollama-models:/root/.ollama/models \
    -e PATH=/llm/ollama:${PATH} \
    -e OLLAMA_HOST=0.0.0.0 \
    -e OLLAMA_KEEP_ALIVE=-1 \
    -e no_proxy=localhost,127.0.0.1 \
    -e ZES_ENABLE_SYSMAN=1 \
    -e OLLAMA_INTEL_GPU=true \
    -e ONEAPI_DEVICE_SELECTOR=level_zero:0 \
    -e DEVICE=Arc \
    --shm-size="16g" \
    --memory="32G" \
    --name=chatterbox \
    intelanalytics/ipex-llm-inference-cpp-xpu:2.2.0-SNAPSHOT \
    /bin/bash -c "cd /llm/scripts/ && source ipex-llm-init --gpu --device Arc >> ipex-llm-init.log 2>&1 && bash start-ollama.sh && tail -f /llm/ollama/ollama.log"

.PHONY: runtts
runtts:
	@echo "Run 'openedai-speech' container."
	@docker compose -f ${PWD}/openedai-speech-service/docker-compose.yml up -d
	@echo "Use <host ip>:8000 to access TTS server."

.PHONY: runpipe
runpipe:
	@echo "Run 'pipelines' container."
	@docker run -d \
		-p 9099:9099 \
		-v ${HOME}/pipelines:/app/pipelines \
		--name pipelines \
		--restart always \
		ghcr.io/open-webui/pipelines:main

.PHONY: runall
runall: run runtts runpipe
	@echo "Run 'open-webui' container."
	@docker run -d \
		--network=host \
		-v ${HOME}/open-webui:/app/backend/data \
		-e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
		-e WHISPER_MODEL=deepdml/faster-whisper-large-v3-turbo-ct2 \
		-e AUDIO_TTS_ENGINE=openai \
		-e AUDIO_TTS_OPENAI_API_BASE_URL=http://localhost:8000/v1 \
		-e AUDIO_TTS_OPENAI_API_KEY=no-need \
		-e OPENAI_API_BASE_URL=http://localhost:9099 \
		-e OPENAI_API_KEY=0p3n-w3bu! \
		--name open-webui \
		--restart always \
		ghcr.io/open-webui/open-webui:v0.4.8
	@echo "Launch web browser & navigate to <host ip>:8080 to get started."

.PHONY: check
check:
	@echo "Run Dockerfile linting"
	@docker --version || (echo "'docker --version' return code: $$?. Make sure docker is installed"; exit 1)
	-@docker run --rm -i hadolint/hadolint < Dockerfile

.PHONY: log
log:
	@echo "Print 'chatterbox' container logs"
	@docker logs chatterbox

.PHONY: load
load: prog
	@echo "Loading model $(LOAD_ARGS), please wait.."
	@docker exec chatterbox ollama run $(LOAD_ARGS)
	@echo "Model loaded successfully"

.PHONY: cmd
cmd: prog
	@echo "Run command in container: $(CMD_ARGS)"
	@docker exec chatterbox $(CMD_ARGS)

.PHONY: start
start:
	@echo "Start containers"
	-@docker start chatterbox 2>/dev/null
	-@docker start open-webui 2>/dev/null
	-@docker start openedai-speech 2>/dev/null
	-@docker start pipelines 2>/dev/null

.PHONY: stop
stop:
	@echo "Stop running containers"
	-@docker stop chatterbox 2>/dev/null
	-@docker stop open-webui 2>/dev/null
	-@docker stop openedai-speech 2>/dev/null
	-@docker stop pipelines 2>/dev/null

.PHONY: clean
clean:
	@echo "Stop and remove containers"
	-@docker stop chatterbox 2>/dev/null
	-@docker rm -f chatterbox 2>/dev/null
	-@docker stop open-webui 2>/dev/null
	-@docker rm -f open-webui 2>/dev/null
	-@docker stop openedai-speech 2>/dev/null
	-@docker rm -f openedai-speech 2>/dev/null
	-@docker stop pipelines 2>/dev/null
	-@docker rm -f pipelines 2>/dev/null

.PHONY: help
help:
	@echo ""
	@echo "Targets:"
	@echo "  all    	- Run targets: clean & run"
	@echo "  check  	- Check Dockerfile"
	@echo "  stop		- Stop running containers"
	@echo "  clean  	- Stop and remove chatterbox container"
	@echo "  log    	- Print chatterbox container logs"
	@echo "  run    	- Run chatterbox container"
	@echo "  runtts 	- Run openedai-speech containers"
	@echo "  runpipe	- Run pipelines containers"
	@echo "  runall 	- Run chatterbox, open-webui, openedai-speech, and pipelines containers"
	@echo ""
	@echo "  load   	- DEBUG: Run LLM model, e.g. make load llama3, make load mistral, etc"
	@echo "  cmd    	- DEBUG: Run command in container, e.g. make cmd ollama list, etc"
	@echo "  help   	- Print this help"
	@echo ""



