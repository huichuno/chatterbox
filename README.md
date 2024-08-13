<a name="readme-top"></a>

# chatterbox

Build and run local LLMs on Intel iGPU with Ollama & Open WebUI

## Prerequisite

  * Install docker

    ```sh
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install docker
    sudo apt-get install docker-ce docker-ce-cli containerd.io

    # Add $USER to docker group and reboot system if needed
    sudo usermod -aG docker $USER
    newgrp $USER

    # Verify docker is installed successfully
    docker run hello-world
    ```

  * Install make

    ```sh
    sudo apt install make
    ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Quick Start

  ```sh
  git clone https://github.com/huichuno/chatterbox.git && cd chatterbox

  # list make options
  make help

  # run chatterbox and open-webui containers 
  make runall

  # make sure both containers are running
  docker ps

  # launch web browser and navigate to <host ip>:8080
  # signup and login

  ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Configuration

* The default model is set by DEFAULT_MODEL env variable. Current default model is set to llama3 8B model.

* Downloaded LLM models are stored in $HOME/ollama-models folder on the host system

* Open-webui backend data is stored in $HOME/open-webui folder on the host system

* Refer to the *Makefile* on all the environment variables default value

<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Test Environment

  * | Hardware                       | Operating System | Kernel |
    | ---                            | ---              | ---    |
    | Intel(R) Core(TM) Ultra 7 155H | Ubuntu 22.04     | 6.5.0  |

<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Misc

* Run benchmark. Download models before running benchmark.
  ```sh
  # Execute command below to run chatterbox container
  make run    # or `make runall`

  # Download model
  docker exec -it chatterbox ollama pull llama2

  # See benchmark option
  docker exec -it chatterbox python benchmark.py --help

  # Run benchmark
  docker exec -it chatterbox python benchmark.py > result.txt

  ```

* Run model on CPU only
  ```sh
  # Change <host ip> to host's ip address
  HOST_IP=<host ip>
  PORT=11435

  # Run ollama container (CPU only)
  docker run -d \
    -p ${PORT}:${PORT} \
    --add-host=host.docker.internal:host-gateway \
    -v ${HOME}/ollama-models:/ollama-models \
    -e OLLAMA_HOST=0.0.0.0:${PORT} \
    -e OLLAMA_MODELS=/ollama-models \
    --name ollama-cpu \
    ollama/ollama

  # Run open-webui container
  docker run -d \
    -p 3000:8080 \
    --add-host=host.docker.internal:host-gateway \
    -v ${HOME}/open-webui:/app/backend/data \
    -e OLLAMA_BASE_URL=http://${HOST_IP}:${PORT} \
    --name open-webui-cpu \
    --restart always \
    ghcr.io/open-webui/open-webui:main

  # Launch web browser and navigate to <host ip>:3000

  ```

* Manually load and keep the model in memory
  ```sh
  curl http://localhost:11434/api/generate -d '{
    "model": "llama3",
    "keep_alive": -1
  }'

  ```

* Manually interact with ollama
  ```sh
  curl http://localhost:11434/api/generate -d '{
    "model": "llama3",
    "prompt": "Why is the sky blue?",
    "stream": false
  }'

  ```
## Enable Model

  ```sh
  Method 1:

  Pull the model from the open webui (ex: nxphi47/seallm-7b-v2:q4_0)

  Method 2: 

  # Download the model gguf 

  # Create Modelfile in your local

  # Open the Modelfile in editor and put the path to the GGUF file
  From ./SeaLLM-7B-v2.q4_0.gguf

  # Create a model from Modelfile with this command
  ollama create SeaLLM -f Modelfile
  
  # Check if the model is created
  ollama list

  ```
<p align="right">(<a href="#readme-top">back to top</a>)</p>
